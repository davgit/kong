-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local utils = require "kong.tools.utils"
local constants = require "kong.constants"
local set_header = kong.service.request.set_header

local split = utils.split
local lower = string.lower
local kong = kong

local _M = {}

function _M.set_groups(groups)
  if not groups then
    return
  end

  ngx.ctx.authenticated_groups = groups
  set_header(constants.HEADERS.AUTHENTICATED_GROUPS, table.concat(groups, ", "))
end

-- Ensure that the groups the user is in match the properties that were
-- configured in the plugin. Group matching is case insensitive.
-- @tparam table|string groups - groups returned from ldap search request
--   e.g. { "CN=test-group-1,CN=Users,DC=addomain,DC=creativehashtags,DC=com",
--          "CN=test-group-2,CN=Users,DC=addomain,DC=creativehashtags,DC=com",
--          "CN=Test-Group-3,CN=Users,DC=addomain,DC=creativehashtags,DC=com", }
-- @tparam string gbase_dn - group base dn
--   e.g. CN=Users,DC=addomain,DC=creativehashtags,DC=com
-- @tparam string gattribute - group name attribute e.g. CN
-- @treturns table|nil - array of groups that pass validation, nil if all
-- invalid. Groups retains case based on what is in the record.
--   e.g. { "test-group-1", "test-group-2", "Test-Group-3" }
function _M.validate_groups(groups, gbase_dn, gattribute)
  local group_names = {}

  -- coerce groups to array since search returns a string when user belongs
  -- to only one group
  if type(groups) == "string" then
    groups = {groups}
  end

  for _, groupdn in ipairs(groups) do
    kong.log.debug("validating group: " .. groupdn)

    -- `groupdn` must be prefixed with `<gattribute>=` (case insensitive)
    --
    -- e.g.
    --
    -- gattribute = "CN"
    -- groupdn = "CN=test-group-1,CN=Users,DC=addomain,DC=creativehashtags,DC=com
    -- OK
    --
    -- gattribute = "CN"
    -- groupdn = "OU=test-group-2,CN=Users,DC=addomain,DC=creativehashtags,DC=com
    -- BAD
    --
    -- gattribute = "CN"
    -- groupdn = "CN= ,CN=Users,DC=addomain,DC=creativehashtags,DC=com",
    -- OK

    local prefix_match = "^" .. lower(gattribute):gsub("([^%w])", "%%%1")
                             .. "%=[%w-_+:@%s.]+%,"
    local is_prefix = string.match(lower(groupdn), prefix_match)

    -- `groupdn` must be suffixed with `gbase_dn` (case insensitive)
    --
    -- e.g.
    --
    -- gbase_dn = "DC=addomain,DC=creativehashtags,DC=com"
    -- groupdn = "CN=test-group-1,CN=Users,DC=addomain,DC=creativehashtags,DC=com",
    -- OK
    --
    -- gbase_dn = "DC=addomain,DC=creativehashtags,DC=com"
    -- groupdn = "CN=test-group-2,CN=Users,DC=creativehashtags,DC=com",
    -- BAD
    --
    -- gbase_dn = "DC=addomain,DC=creativehashtags,DC=com"
    -- groupdn = "DC=addomain,DC=creativehashtags,DC=com,CN=test-group-3,CN=Users"
    -- BAD

    local suffix_match = lower(gbase_dn):gsub("([^%w])", "%%%1") .. "$"
    local is_suffix = string.match(lower(groupdn), suffix_match)

    if is_prefix and is_prefix ~= "" and is_prefix ~= gbase_dn and
       is_suffix and is_suffix ~= "" then
      -- pick off group name from full dn
      local group_name = split(split(is_prefix, lower(gattribute) .. "=")[2],
                               ",")[1]
      -- use group from record, not lowercased version
      local group_name_original = split(split(groupdn, ",")[1], "=")[2]

      if group_name and group_name == lower(group_name_original) then
        group_names[#group_names + 1] = group_name_original
      end
    else
      kong.log.debug('"'.. groupdn .. '"' .. ' is not a valid group')
    end
  end

  if not group_names[1] then
    return nil
  end

  return group_names
end


return _M
