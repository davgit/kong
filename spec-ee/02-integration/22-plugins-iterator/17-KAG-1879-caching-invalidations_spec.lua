-- this software is copyright kong inc. and its licensors.
-- use of the software is subject to the agreement between your organization
-- and kong inc. if there is no such agreement, use is governed by and
-- subject to the terms of the kong master software license agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ end of license 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local helpers = require "spec.helpers"
local conf_loader = require "kong.conf_loader"
local factories = require "spec-ee.fixtures.factories.plugins"

local PluginFactory = factories.PluginFactory
local EntitiesFactory = factories.EntitiesFactory

-- the `off` strategy only works when the `postgres` strategy was run before.
for _, strategy in helpers.all_strategies({"postgres", "off"}) do

    describe("Plugins Iterator - Single scoping - #Service on #" .. strategy, function()
        local proxy_client, expected_header, ef, admin_client

        lazy_teardown(function()
            helpers.stop_kong()
            helpers.kill_all()
            assert(conf_loader(nil, {}))
        end)

        local declarative_config
        lazy_setup(function()
            proxy_client = helpers.proxy_client
            helpers.stop_kong()
            helpers.kill_all()
            assert(conf_loader(nil, {}))

            ef = EntitiesFactory:setup(strategy)
            local pf = PluginFactory:setup(ef)

            expected_header = pf:consumer_group()

            declarative_config = strategy == "off" and helpers.make_yaml_file() or nil
            assert(helpers.start_kong({
                declarative_config = declarative_config,
                database   = strategy,
                nginx_conf = "spec/fixtures/custom_nginx.template",
            }))
        end)

        before_each(function ()
            admin_client = helpers.admin_client()
        end)

        it("verify plugin execution when consumer is part of group and when it is not", function()
            local r = proxy_client():get("/anything", {
                headers = {
                    host = "route.test",
                    -- authenticate as `alice`
                    apikey = "alice",
                },
            })
            assert.response(r).has.status(200)
            -- verify that the expected plugin was executed
            assert.request(r).has_header(expected_header)
            -- verify that when the consumer leaves the group, the plugin is no longer excecuted.
            local ra = admin_client:send({
              method = "DELETE",
              path = "/consumer_groups/" .. ef.consumer_group_platinum_id .. "/consumers/" .. ef.alice_id
            })
            assert.response(ra).has.status(204)

            local r2 = proxy_client():get("/anything", {
                headers = {
                    host = "route.test",
                    -- authenticate as `alice`
                    apikey = "alice",
                },
            })
            assert.request(r2).has_not_header(expected_header)
            assert.response(r2).has.status(200)
        end)
    end)
end
