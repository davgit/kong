--- Module with performance test tools
-- @module spec.helpers.perf

local pl_tablex = require("pl.tablex")

local logger = require("spec.helpers.perf.logger")
local utils = require("spec.helpers.perf.utils")
local git = require("spec.helpers.perf.git")
local charts = require("spec.helpers.perf.charts")
local read_all_env = require("kong.components.cli.utils.env").read_all

local my_logger = logger.new_logger("[controller]")

utils.register_busted_hook()

charts.register_busted_hook()

-- how many times for each "driver" operation
local RETRY_COUNT = 3
local DRIVER
local DRIVER_NAME
local LAST_KONG_VERSION

-- Real user facing functions
local driver_functions = {
  "start_worker", "start_kong", "stop_kong", "setup", "setup_kong", "teardown",
  "get_start_load_cmd", "get_start_stapxx_cmd", "get_wait_stapxx_cmd",
  "generate_flamegraph", "save_error_log", "get_admin_uri",
  "save_pgdump", "load_pgdump", "get_based_version", "remote_execute",
}

local function check_driver_sanity(mod)
  if type(mod) ~= "table" then
    error("Driver must return a table")
  end

  for _, func in ipairs(driver_functions) do
    if not mod[func] then
      error("Driver " .. debug.getinfo(mod.new, "S").source ..
            " must implement function " .. func, 2)
    end
  end
end

local known_drivers = { "docker", "terraform" }

--- Set the driver to use.
-- @function use_driver
-- @tparam string name name of the driver to use
-- @tparam[opt] table opts config parameters passed to the driver
-- @return nothing. Throws an error if any.
local function use_driver(name, opts)
  name = name or "docker"

  if not pl_tablex.find(known_drivers, name) then
    local err = ("Unknown perf test driver \"%s\", expect one of \"%s\""):format(
      name, table.concat(known_drivers, "\", \"")
    )
    error(err, 2)
  end

  local pok, mod = pcall(require, "spec.helpers.perf.drivers." .. name)

  if not pok then
    error(("Unable to load perf test driver %s: %s"):format(name, mod))
  end

  check_driver_sanity(mod)

  DRIVER = mod.new(opts)
  DRIVER_NAME = name
end

--- Set driver operation retry count
-- @function set_retry_count
-- @tparam number try the number of retries for each driver operation
-- @return nothing.
local function set_retry_count(try)
  if type(try) ~= "number" then
    error("expect a number, got " .. type(try))
  end
  RETRY_COUNT = try
end

--- Setup a default perf test instance.
-- Creates an instance that's ready to use on most common cases including Github Actions
-- @function use_defaults
-- @return nothing.
local function use_defaults()
  logger.set_log_level(ngx.DEBUG)
  set_retry_count(3)

  local driver = os.getenv("PERF_TEST_DRIVER") or "docker"
  local use_daily_image = os.getenv("PERF_TEST_USE_DAILY_IMAGE")
  local ssh_user

  if driver == "terraform" then
    local seperate_db_node = not not os.getenv("PERF_TEST_SEPERATE_DB_NODE")

    local tf_provider = os.getenv("PERF_TEST_TERRAFORM_PROVIDER") or "equinix-metal"
    local tfvars = {}
    if tf_provider == "equinix-metal" then
      tfvars =  {
        -- Kong Benchmarking
        metal_project_id = os.getenv("PERF_TEST_METAL_PROJECT_ID"),
        -- TODO: use an org token
        metal_auth_token = os.getenv("PERF_TEST_METAL_AUTH_TOKEN"),
        metal_plan = os.getenv("PERF_TEST_METAL_PLAN"), -- "c3.small.x86"
        -- metal_region = ["sv15", "sv16", "la4"], -- not support setting from lua for now
        metal_os = os.getenv("PERF_TEST_METAL_OS"), -- "ubuntu_20_04",
      }
    elseif tf_provider == "digitalocean" then
      tfvars =  {
        do_project_name = os.getenv("PERF_TEST_DIGITALOCEAN_PROJECT_NAME"), -- "Benchmark",
        do_token = os.getenv("PERF_TEST_DIGITALOCEAN_TOKEN"),
        do_size = os.getenv("PERF_TEST_DIGITALOCEAN_SIZE"), -- "c2-8vpcu-16gb",
        do_region = os.getenv("PERF_TEST_DIGITALOCEAN_REGION"), --"sfo3",
        do_os = os.getenv("PERF_TEST_DIGITALOCEAN_OS"), -- "ubuntu-20-04-x64",
      }
    elseif tf_provider == "aws-ec2" then
      tfvars =  {
        aws_region = os.getenv("PERF_TEST_AWS_REGION"), -- "us-east-2",
        ec2_instance_type = os.getenv("PERF_TEST_EC2_INSTANCE_TYPE"), -- "c5a.2xlarge",
        ec2_os = os.getenv("PERF_TEST_EC2_OS"), -- "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*",
      }
      ssh_user = "ubuntu"
    elseif tf_provider == "bring-your-own" then
      tfvars =  {
        kong_ip = os.getenv("PERF_TEST_BYO_KONG_IP"),
        kong_internal_ip = os.getenv("PERF_TEST_BYO_KONG_INTERNAL_IP"), -- fallback to kong_ip
        db_ip = os.getenv("PERF_TEST_BYO_DB_IP"),
        db_internal_ip = os.getenv("PERF_TEST_BYO_DB_INTERNAL_IP"), -- fallback to db_ip
        worker_ip = os.getenv("PERF_TEST_BYO_WORKER_IP"),
        worker_internal_ip = os.getenv("PERF_TEST_BYO_WORKER_INTERNAL_IP"), -- fallback to worker_ip
        ssh_key_path = os.getenv("PERF_TEST_BYO_SSH_KEY_PATH") or "root",
      }
      ssh_user = os.getenv("PERF_TEST_BYO_SSH_USER")
    end

    tfvars.seperate_db_node = seperate_db_node

    use_driver("terraform", {
      provider = tf_provider,
      tfvars = tfvars,
      use_daily_image = use_daily_image,
      seperate_db_node = seperate_db_node,
      ssh_user = ssh_user,
    })
  else
    use_driver(driver, {
      use_daily_image = use_daily_image,
    })
  end
end

local function invoke_driver(method, ...)
  if not DRIVER then
    error("No driver selected, call use_driver first", 2)
  end

  if not DRIVER[method] then
    my_logger.warn(method, " not implemented by driver ", DRIVER_NAME)
    return
  end

  local happy
  local r, err
  for i = 1, RETRY_COUNT + 1 do
    r, err = DRIVER[method](DRIVER, ...)
    if not err then
      happy = true
      break
    end

    my_logger.warn("failed in ", method, ": ", err or "nil", ", tries: ", i)
  end

  if not happy then
    error(method .. " finally failed" .. (RETRY_COUNT > 0 and " after " .. RETRY_COUNT .. " retries" or ""), 2)
  end

  return r
end

local _M = {
  use_driver = use_driver,
  set_retry_count = set_retry_count,
  use_defaults = use_defaults,

  new_logger = logger.new_logger,
  set_log_level = logger.set_log_level,

  setenv = utils.setenv,
  unsetenv = utils.unsetenv,
  execute = utils.execute,
  wait_output = utils.wait_output,
  parse_docker_image_labels = utils.parse_docker_image_labels,
  clear_loaded_package = utils.clear_loaded_package,

  git_checkout = git.git_checkout,
  git_restore = git.git_restore,
  get_kong_version = git.get_kong_version,
}

--- Start the worker (nginx) with given conf with multiple ports.
-- @tparam string conf the Nginx snippet under server{} context
-- @tparam[opt=1] number port_count number of ports the upstream listens to
-- @return upstream_uri string or table if `port_count` is more than 1
function _M.start_worker(conf, port_count)
  port_count = port_count or 1
  local ret = invoke_driver("start_worker", conf, port_count)
  return port_count == 1 and ret[1] or ret
end

--- Start Kong with given version and conf.
-- @tparam[opt] table kong_confs Kong configuration as a lua table
-- @tparam[opt] table driver_confs driver configuration as a lua table
-- @return nothing. Throws an error if any.
function _M.start_kong(kong_confs, driver_confs)
  kong_confs = kong_confs or {}
  for k, v in pairs(read_all_env()) do
    k = k:match("^KONG_([^=]+)")
    k = k and k:lower()
    if k then
      kong_confs[k] = os.getenv("KONG_" .. k:upper())
    end
  end
  return invoke_driver("start_kong", kong_confs, driver_confs or {})
end

--- Stop Kong.
-- @param ... args passed to the driver "stop_kong" command
-- @return nothing. Throws an error if any.
function _M.stop_kong(...)
  return invoke_driver("stop_kong", ...)
end

--- Setup environment.
-- This is not necessary if `setup_kong` is called
-- @return nothing. Throws an error if any.
function _M.setup()
  return invoke_driver("setup")
end

--- Installs Kong. Setup env vars and return the configured helpers utility
-- @tparam string version Kong version
-- @return table the `helpers` utility as if it's require("spec.helpers")
function _M.setup_kong(version)
  LAST_KONG_VERSION = version
  return invoke_driver("setup_kong", version)
end

--- Cleanup the test.
-- @tparam[opt=false] boolean full teardown all stuff, including those will make next test spin up faster
-- @return nothing. Throws an error if any.
function _M.teardown(full)
  LAST_KONG_VERSION = nil
  return invoke_driver("teardown", full)
end

local load_thread
local load_should_stop

--- Start to send load to Kong.
-- @tparam table opts options table
-- @tparam[opt="/"] string opts.path request path
-- @tparam[opt="http://kong-ip:kong-port/"] string opts.uri base URI except path
-- @tparam[opt=1000] number opts.connections connection count
-- @tparam[opt=5] number opts.threads request thread count
-- @tparam[opt=10] number opts.duration perf test duration in seconds
-- @tparam[opt] string opts.script content of wrk script
-- @tparam[opt] string opts.kong_name specify the kong name to send load to; will automatically pick one if not specified
-- @return nothing. Throws an error if any.
function _M.start_load(opts)
  if load_thread then
    error("load is already started, stop it using wait_result() first", 2)
  end

  local path = opts.path or ""
  -- strip leading /
  if path:sub(1, 1) == "/" then
    path = path:sub(2)
  end

  local prog = opts.wrk2 and "wrk2" or "wrk"
  if opts.wrk2 then
    if DRIVER_NAME ~= "terraform" then
      error("wrk2 not supported in docker driver", 2)
    elseif not opts.rate then
      error("wrk2 requires rate", 2)
    end
  end

  local load_cmd_stub = prog .. " -c " .. (opts.connections or 1000) ..
                        " -t " .. (opts.threads or 5) ..
                        " -d " .. (opts.duration or 10) .. "s" ..
                        (opts.wrk2 and " -R " .. opts.rate or "") ..
                        " %s " .. -- script place holder
                        " %s/" .. path ..
                        " --latency"

  local load_cmd = invoke_driver("get_start_load_cmd", load_cmd_stub, opts.script, opts.uri, opts.kong_name)
  load_should_stop = false

  load_thread = ngx.thread.spawn(function()
    return utils.execute(load_cmd,
        {
          stop_signal = function() if load_should_stop then return 9 end end,
        })
  end)
end

local stapxx_thread
local stapxx_should_stop

--- Start to send load to Kong.
-- @tparam string sample_name stapxx sample name
-- @tparam string arg extra arguments passed to stapxx script
-- @tparam table driver_confs driver configuration as a lua table
-- @return nothing. Throws an error if any.
function _M.start_stapxx(sample_name, arg, driver_confs)
  if stapxx_thread then
    error("stapxx is already started, stop it using wait_result() first", 2)
  end

  local start_cmd = invoke_driver("get_start_stapxx_cmd", sample_name, arg, driver_confs or {})
  stapxx_should_stop = false

  stapxx_thread = ngx.thread.spawn(function()
    return utils.execute(start_cmd,
        {
          stop_signal = function() if stapxx_should_stop then return 3 end end,
        })
  end)

  local wait_cmd = invoke_driver("get_wait_stapxx_cmd")
  if not utils.wait_output(wait_cmd, "stap_", 30) then
    return false, "timeout waiting systemtap probe to load"
  end

  return true
end

--- Wait for the load test to finish.
-- @treturn string the test report text
function _M.wait_result()
  if not load_thread then
    error("load haven't been started or already collected, " ..
          "start it using start_load() first", 2)
  end

  -- local timeout = opts and opts.timeout or 3
  -- local ok, res, err

  -- ngx.update_time()
  -- local s = ngx.now()
  -- while not found and ngx.now() - s <= timeout do
  --   ngx.update_time()
  --   ngx.sleep(0.1)
  --   if coroutine.status(self.load_thread) ~= "running" then
  --     break
  --   end
  -- end
  -- print(coroutine.status(self.load_thread), coroutine.running(self.load_thread))

  -- if coroutine.status(self.load_thread) == "running" then
  --   self.load_should_stop = true
  --   return false, "timeout waiting for load to stop (" .. timeout .. "s)"
  -- end

  if stapxx_thread then
    local ok, res, err = ngx.thread.wait(stapxx_thread)
    stapxx_should_stop = true
    stapxx_thread = nil
    if not ok or err then
      my_logger.warn("failed to wait stapxx to finish: ",
        (res or "nil"),
        " err: " .. (err or "nil"))
    end
    my_logger.debug("stap++ output: ", res)
  end

  local ok, res, err = ngx.thread.wait(load_thread)
  load_should_stop = true
  load_thread = nil

  if not ok or err then
    error("failed to wait result: " .. (res or "nil") ..
          " err: " .. (err or "nil"))
  end

  return res
end

local function sum(t)
  local s = 0
  for _, i in ipairs(t) do
    if type(i) == "number" then
      s = s + i
    end
  end

  return s
end

-- Note: could also use custom lua code in wrk
local nan = 0/0
local function parse_wrk_result(r)
  local rps = string.match(r, "Requests/sec:%s+([%d%.]+)")
  rps = tonumber(rps)
  local count = string.match(r, "([%d]+)%s+requests in")
  count = tonumber(count)

  local lat_avg, avg_m, lat_max, max_m = string.match(r, "Latency%s+([%d%.]+)([mu]?)s%s+[%d%.]+[mu]?s%s+([%d%.]+)([mu]?)s")
  lat_avg = tonumber(lat_avg or nan) * (avg_m == "u" and 0.001 or (avg_m == "m" and 1 or 1000))
  lat_max = tonumber(lat_max or nan) * (max_m == "u" and 0.001 or (max_m == "m" and 1 or 1000))

  local p90, p90_m = string.match(r, "90%%%s+([%d%.]+)([mu]?)s")
  local p99, p99_m = string.match(r, "99%%%s+([%d%.]+)([mu]?)s")
  p90 = tonumber(p90 or nan) * (p90_m == "u" and 0.001 or (p90_m == "m" and 1 or 1000))
  p99 = tonumber(p99 or nan) * (p99_m == "u" and 0.001 or (p99_m == "m" and 1 or 1000))

  return rps, count, lat_avg, lat_max, p90, p99
end

--- Compute average of RPS and latency from multiple wrk output.
-- @tparam table results the table holds raw wrk outputs
-- @tparam string suite xaxis suite name
-- @treturn string The human readable result of average RPS and latency
function _M.combine_results(results, suite)
  local count = #results
  if count == 0 then
    return "(no results)"
  end

  local rpss = table.new(count, 0)
  local latencies_avg = table.new(count, 0)
  local latencies_max = table.new(count, 0)
  local latencies_p90 = table.new(count, 0)
  local latencies_p99 = table.new(count, 0)
  local count = 0

  for i, result in ipairs(results) do
    local r, c, la, lm, p90, p99 = parse_wrk_result(result)
    rpss[i] = r
    count = count + c
    latencies_avg[i] = la * c
    latencies_max[i] = lm
    latencies_p90[i] = p90
    latencies_p99[i] = p99
  end

  local rps = sum(rpss) / 3
  local latency_avg = sum(latencies_avg) / count
  local latency_max = math.max(unpack(latencies_max))

  if LAST_KONG_VERSION then
    charts.ingest_combined_results(LAST_KONG_VERSION, {
      rpss = rpss,
      rps = rps,
      latencies_p90 = latencies_p90,
      latencies_p99 = latencies_p99,
      latency_max = latency_max,
      latency_avg = latency_avg,
    }, suite)
  end

  return ([[
RPS     Avg: %3.2f
Latency Avg: %3.2fms    Max: %3.2fms
   P90 (ms): %s
   P99 (ms): %s
  ]]):format(rps, latency_avg, latency_max, table.concat(latencies_p90, ", "), table.concat(latencies_p99, ", "))
end

--- Wait until the systemtap probe is loaded.
-- @tparam[opt=20] number timeout in seconds
function _M.wait_stap_probe(timeout)
  return invoke_driver("wait_stap_probe", timeout or 20)
end

--- Generate the flamegraph and return SVG.
-- @tparam string filename the target filename to store the generated SVG.
-- @tparam[opt] string title the title for flamegraph
-- @tparam[opt] string opts the command line options string (not a table) for `flamegraph.pl`
-- @return Nothing. Throws an error if any.
function _M.generate_flamegraph(filename, title, opts)
  if not filename then
    error("filename must be specified for generate_flamegraph")
  end
  if string.sub(filename, #filename-3, #filename):lower() ~= ".svg" then
    filename = filename .. ".svg"
  end

  if not title then
    title = "Flame graph"
  end

  -- If current test is git-based, also attach the Kong binary package
  -- version it based on
  if git.is_git_repo() and git.is_git_based() then
    -- use driver to get the version; driver could implement version override
    -- based on setups (like using the daily image)
    local v = invoke_driver("get_based_version")
    title = title .. " (based on " .. v .. ")"
  end

  local out = invoke_driver("generate_flamegraph", title, opts)

  local f, err = io.open(filename, "w")
  if not f then
    error("failed to open " .. filename .. " for writing flamegraph: " .. err)
  end

  f:write(out)
  f:close()

  my_logger.debug("flamegraph written to ", filename)
end

--- Enable or disable charts generation.
-- @tparam[opt=false] boolean enabled enable or not
-- @return Nothing. Throws an error if any.
function _M.enable_charts(enabled)
  return enabled and charts.on() or charts.off()
end


--- Save Kong error log locally.
-- @tparam string filename filename where to save the log
-- @return Nothing. Throws an error if any.
function _M.save_error_log(filename)
  if not filename then
    error("filename must be specified for save_error_log")
  end

  invoke_driver("save_error_log", filename)

  my_logger.debug("Kong error log written to ", filename)
end

--- Get the Admin URI accessible from worker.
-- @tparam[opt] string kong_name specify the kong name; will automatically pick one if not specified
-- @return Nothing. Throws an error if any.
function _M.get_admin_uri(kong_name)
  return invoke_driver("get_admin_uri", kong_name)
end

--- Save a .sql file of the database.
-- @tparam string path the .sql file path to save to
-- @return Nothing. Throws an error if any.
function _M.save_pgdump(path)
  return invoke_driver("save_pgdump", path)
end

--- Load a .sql file into the database.
-- @tparam string path the .sql file path
-- @tparam[opt=false] boolean dont_patch_service set to true to skip update all services to upstream started by this framework
-- @return Nothing. Throws an error if any.
function _M.load_pgdump(path, dont_patch_service)
  return invoke_driver("load_pgdump", path, dont_patch_service)
end

--- Execute command on remote instance.
-- @tparam string node_type the node to exeute the command on, can be; "kong", "db", or "worker"
-- @tparam array cmds array of commands to execute
-- @tparam boolean continue_on_error if true, will continue on error
function _M.remote_execute(node_type, cmds, continue_on_error)
  return invoke_driver("remote_execute", node_type, cmds, continue_on_error)
end

return _M
