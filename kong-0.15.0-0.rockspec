package = "kong"
version = "0.15.0-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/Kong/kong",
  tag = "0.15.0"
}
description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "MIT"
}
dependencies = {
  "inspect == 3.1.1",
  "luasec == 0.7",
  "luasocket == 3.0-rc1",
  "penlight == 1.5.4",
  "lua-resty-http == 0.12",
  "lua-resty-jit-uuid == 0.0.7",
  "multipart == 0.5.5",
  "version == 0.2",
  "kong-lapis == 1.6.0.1",
  "lua-cassandra == 1.3.3",
  "pgmoon == 1.9.0",
  "luatz == 0.3",
  "http == 0.2",
  "lua_system_constants == 0.1.2",
  "lua-resty-iputils == 0.3.0",
  "luaossl == 20181207",
  "luasyslog == 1.0.0",
  "lua_pack == 1.0.5",
  "lua-resty-dns-client == 2.2.0",
  "lua-resty-worker-events == 0.3.3",
  "lua-resty-mail == 1.0.0",
  "lua-resty-mediador == 0.1.2",
  "lua-resty-redis-connector == 0.03",
  "lua-resty-healthcheck == 0.6.0",
  "lua-resty-cookie == 0.1.0",
  "lua-resty-mlcache == 2.2.0",
  "lua-resty-rsa == 0.04",
  "lyaml == 6.2.3",
  "bcrypt == 2.1",
  -- external Kong plugins
  "kong-plugin-azure-functions ~> 0.3",
  "kong-plugin-zipkin ~> 0.1",
  "kong-plugin-serverless-functions ~> 0.2",
  "kong-prometheus-plugin ~> 0.3",
  "kong-plugin-session == 0.1.1-1",
}
build = {
  type = "builtin",
  modules = {
    ["kong"] = "kong/init.lua",
    ["kong.meta"] = "kong/meta.lua",
    ["kong.cache"] = "kong/cache.lua",
    ["kong.global"] = "kong/global.lua",
    ["kong.router"] = "kong/router.lua",
    ["kong.api_router"] = "kong/api_router.lua",
    ["kong.reports"] = "kong/reports.lua",
    ["kong.constants"] = "kong/constants.lua",
    ["kong.singletons"] = "kong/singletons.lua",
    ["kong.conf_loader"] = "kong/conf_loader.lua",
    ["kong.globalpatches"] = "kong/globalpatches.lua",
    ["kong.error_handlers"] = "kong/error_handlers.lua",

    ["kong.cluster_events"] = "kong/cluster_events.lua",
    ["kong.cluster_events.strategies.cassandra"] = "kong/cluster_events/strategies/cassandra.lua",
    ["kong.cluster_events.strategies.postgres"] = "kong/cluster_events/strategies/postgres.lua",

    ["kong.enterprise_edition"] = "kong/enterprise_edition/init.lua",
    ["kong.enterprise_edition.admin.emails"] = "kong/enterprise_edition/admin/emails.lua",
    ["kong.enterprise_edition.admins_helpers"] = "kong/enterprise_edition/admins_helpers.lua",
    ["kong.enterprise_edition.api_helpers"] = "kong/enterprise_edition/api_helpers.lua",
    ["kong.enterprise_edition.audit_log"] = "kong/enterprise_edition/audit_log.lua",
    ["kong.enterprise_edition.conf_loader"] = "kong/enterprise_edition/conf_loader.lua",
    ["kong.enterprise_edition.consumer_reset_secret_helpers"] = "kong/enterprise_edition/consumer_reset_secret_helpers.lua",
    ["kong.enterprise_edition.crud_helpers"] = "kong/enterprise_edition/crud_helpers.lua",
    ["kong.enterprise_edition.dao.enums"] = "kong/enterprise_edition/dao/enums.lua",
    ["kong.enterprise_edition.dao.factory"] = "kong/enterprise_edition/dao/factory.lua",
    ["kong.enterprise_edition.dao.migrations.core.postgres"] = "kong/enterprise_edition/dao/migrations/core/postgres.lua",
    ["kong.enterprise_edition.dao.migrations.core.cassandra"] = "kong/enterprise_edition/dao/migrations/core/cassandra.lua",
    ["kong.enterprise_edition.dao.schemas.consumer_reset_secrets"] = "kong/enterprise_edition/dao/schemas/consumer_reset_secrets.lua",
    ["kong.enterprise_edition.dao.schemas.token_statuses"] = "kong/enterprise_edition/dao/schemas/token_statuses.lua",
    ["kong.enterprise_edition.dao.schemas.workspace_entity_counters"] = "kong/enterprise_edition/dao/schemas/workspace_entity_counters.lua",
    ["kong.enterprise_edition.feature_flags"] = "kong/enterprise_edition/feature_flags.lua",
    ["kong.enterprise_edition.jwt"] = "kong/enterprise_edition/jwt.lua",
    ["kong.enterprise_edition.license_helpers"] = "kong/enterprise_edition/license_helpers.lua",
    ["kong.enterprise_edition.meta"] = "kong/enterprise_edition/meta.lua",
    ["kong.enterprise_edition.oas_config"] = "kong/enterprise_edition/oas_config.lua",
    ["kong.enterprise_edition.plugin_overwrite"] = "kong/enterprise_edition/plugin_overwrite.lua",
    ["kong.enterprise_edition.proxies"] = "kong/enterprise_edition/proxies.lua",
    ["kong.enterprise_edition.redis"] = "kong/enterprise_edition/redis/init.lua",
    ["kong.enterprise_edition.smtp_client"] = "kong/enterprise_edition/smtp_client.lua",
    ["kong.enterprise_edition.utils"] = "kong/enterprise_edition/utils.lua",

    ["kong.templates.nginx"] = "kong/templates/nginx.lua",
    ["kong.templates.nginx_kong"] = "kong/templates/nginx_kong.lua",
    ["kong.templates.nginx_kong_stream"] = "kong/templates/nginx_kong_stream.lua",
    ["kong.templates.kong_defaults"] = "kong/templates/kong_defaults.lua",

    ["kong.resty.ctx"] = "kong/resty/ctx.lua",
    ["kong.resty.config"] = "kong/resty/config.lua",
    ["kong.resty.getssl"] = "kong/resty/getssl.lua",
    ["kong.vendor.classic"] = "kong/vendor/classic.lua",

    ["kong.cmd"] = "kong/cmd/init.lua",
    ["kong.cmd.roar"] = "kong/cmd/roar.lua",
    ["kong.cmd.stop"] = "kong/cmd/stop.lua",
    ["kong.cmd.quit"] = "kong/cmd/quit.lua",
    ["kong.cmd.start"] = "kong/cmd/start.lua",
    ["kong.cmd.check"] = "kong/cmd/check.lua",
    ["kong.cmd.reload"] = "kong/cmd/reload.lua",
    ["kong.cmd.restart"] = "kong/cmd/restart.lua",
    ["kong.cmd.prepare"] = "kong/cmd/prepare.lua",
    ["kong.cmd.migrations"] = "kong/cmd/migrations.lua",
    ["kong.cmd.health"] = "kong/cmd/health.lua",
    ["kong.cmd.version"] = "kong/cmd/version.lua",
    ["kong.cmd.utils.log"] = "kong/cmd/utils/log.lua",
    ["kong.cmd.utils.kill"] = "kong/cmd/utils/kill.lua",
    ["kong.cmd.utils.env"] = "kong/cmd/utils/env.lua",
    ["kong.cmd.utils.migrations"] = "kong/cmd/utils/migrations.lua",
    ["kong.cmd.utils.tty"] = "kong/cmd/utils/tty.lua",
    ["kong.cmd.utils.nginx_signals"] = "kong/cmd/utils/nginx_signals.lua",
    ["kong.cmd.utils.prefix_handler"] = "kong/cmd/utils/prefix_handler.lua",

    ["kong.api"] = "kong/api/init.lua",
    ["kong.api.api_helpers"] = "kong/api/api_helpers.lua",
    ["kong.api.arguments"] = "kong/api/arguments.lua",
    ["kong.api.crud_helpers"] = "kong/api/crud_helpers.lua",
    ["kong.api.endpoints"] = "kong/api/endpoints.lua",
    ["kong.api.routes.kong"] = "kong/api/routes/kong.lua",
    ["kong.api.routes.apis"] = "kong/api/routes/apis.lua",
    ["kong.api.routes.consumers"] = "kong/api/routes/consumers.lua",
    ["kong.api.routes.plugins"] = "kong/api/routes/plugins.lua",
    ["kong.api.routes.routes"] = "kong/api/routes/routes.lua",
    ["kong.api.routes.services"] = "kong/api/routes/services.lua",
    ["kong.api.routes.cache"] = "kong/api/routes/cache.lua",
    ["kong.api.routes.upstreams"] = "kong/api/routes/upstreams.lua",
    ["kong.api.routes.targets"] = "kong/api/routes/targets.lua",
    ["kong.api.routes.certificates"] = "kong/api/routes/certificates.lua",
    ["kong.api.routes.snis"] = "kong/api/routes/snis.lua",
    ["kong.api.routes.rbac" ] = "kong/api/routes/rbac.lua",
    ["kong.api.routes.vitals" ] = "kong/api/routes/vitals.lua",
    ["kong.api.routes.workspaces"] = "kong/api/routes/workspaces.lua",
    ["kong.api.routes.portal"] = "kong/api/routes/portal.lua",
    ["kong.api.routes.files"] = "kong/api/routes/files.lua",
    ["kong.api.routes.admins"] = "kong/api/routes/admins.lua",
    ["kong.api.routes.audit"] = "kong/api/routes/audit.lua",
    ["kong.api.routes.oas_config"] = "kong/api/routes/oas_config.lua",

    ["kong.tools.cluster_ca"] = "kong/tools/cluster_ca.lua",
    ["kong.tools.ip"] = "kong/tools/ip.lua",
    ["kong.tools.ciphers"] = "kong/tools/ciphers.lua",
    ["kong.tools.dns"] = "kong/tools/dns.lua",
    ["kong.tools.utils"] = "kong/tools/utils.lua",
    ["kong.tools.public"] = "kong/tools/public.lua",
    ["kong.tools.printable"] = "kong/tools/printable.lua",
    ["kong.tools.responses"] = "kong/tools/responses.lua",
    ["kong.tools.timestamp"] = "kong/tools/timestamp.lua",

    ["kong.tools.public.rate-limiting"] = "kong/tools/public/rate-limiting/init.lua",
    ["kong.tools.public.rate-limiting.strategies.cassandra"] = "kong/tools/public/rate-limiting/strategies/cassandra.lua",
    ["kong.tools.public.rate-limiting.strategies.postgres"] = "kong/tools/public/rate-limiting/strategies/postgres.lua",
    ["kong.tools.public.rate-limiting.strategies.redis"] = "kong/tools/public/rate-limiting/strategies/redis.lua",
    ["kong.tools.public.rate-limiting"] = "kong/tools/public/rate-limiting/init.lua",

    -- XXX merge - files added or modified by enterprise, all of which no longer exist
    -- upstream (in 0.15.0)
    ["kong.db.migrations.enterprise"] = "kong/db/migrations/enterprise/init.lua",
    ["kong.db.migrations.enterprise.000_base"] = "kong/db/migrations/enterprise/000_base.lua",
    ["kong.db.strategies.cassandra.routes"] = "kong/db/strategies/cassandra/routes.lua",

    ["kong.runloop.handler"] = "kong/runloop/handler.lua",
    ["kong.runloop.certificate"] = "kong/runloop/certificate.lua",
    ["kong.runloop.mesh"] = "kong/runloop/mesh.lua",
    ["kong.runloop.plugins_iterator"] = "kong/runloop/plugins_iterator.lua",
    ["kong.runloop.balancer"] = "kong/runloop/balancer.lua",

    ["kong.dao.errors"] = "kong/dao/errors.lua",
    ["kong.dao.schemas_validation"] = "kong/dao/schemas_validation.lua",
    ["kong.dao.schemas.apis"] = "kong/dao/schemas/apis.lua",

    ["kong.dao.schemas.consumer_types"] = "kong/dao/schemas/consumer_types.lua",
    ["kong.dao.schemas.consumer_statuses"] = "kong/dao/schemas/consumer_statuses.lua",
    ["kong.dao.schemas.credentials"] = "kong/dao/schemas/credentials.lua",
    ["kong.db.schema.entities.rbac_users"] = "kong/db/schema/entities/rbac_users.lua",
    ["kong.db.schema.entities.rbac_user_roles"] = "kong/db/schema/entities/rbac_user_roles.lua",
    ["kong.db.schema.entities.rbac_roles"] = "kong/db/schema/entities/rbac_roles.lua",
    ["kong.db.schema.entities.rbac_role_endpoints"] = "kong/db/schema/entities/rbac_role_endpoints.lua",
    ["kong.db.schema.entities.rbac_role_entities"] = "kong/db/schema/entities/rbac_role_entities.lua",
    ["kong.dao.schemas.files"] = "kong/dao/schemas/files.lua",
    ["kong.db.schema.entities.files"] = "kong/db/schema/entities/files.lua",
    ["kong.db.schema.entities.consumers_rbac_users_map"] = "kong/db/schema/entities/consumers_rbac_users_map.lua",

    ["kong.dao.db"] = "kong/dao/db/init.lua",
    ["kong.dao.db.cassandra"] = "kong/dao/db/cassandra.lua",
    ["kong.dao.db.postgres"] = "kong/dao/db/postgres.lua",
    ["kong.dao.dao"] = "kong/dao/dao.lua",
    ["kong.dao.factory"] = "kong/dao/factory.lua",
    ["kong.dao.model_factory"] = "kong/dao/model_factory.lua",
    ["kong.dao.migrations.helpers"] = "kong/dao/migrations/helpers.lua",
    ["kong.dao.migrations.cassandra"] = "kong/dao/migrations/cassandra.lua",
    ["kong.dao.migrations.postgres"] = "kong/dao/migrations/postgres.lua",
    ["kong.dao.schemas.audit_objects"] = "kong/dao/schemas/audit_objects.lua",
    ["kong.dao.schemas.audit_requests"] = "kong/dao/schemas/audit_requests.lua",

    ["kong.rbac"] = "kong/rbac/init.lua",
    ["kong.rbac.migrations.01_defaults"] = "kong/rbac/migrations/01_defaults.lua",
    ["kong.rbac.migrations.02_admins"] = "kong/rbac/migrations/02_admins.lua",
    ["kong.rbac.migrations.03_user_default_role"] = "kong/rbac/migrations/03_user_default_role.lua",
    ["kong.rbac.migrations.04_kong_admin_basic_auth"] = "kong/rbac/migrations/04_kong_admin_basic_auth.lua",
    ["kong.rbac.migrations.05_super_admin"] = "kong/rbac/migrations/05_super_admin.lua",

    ["kong.workspaces"] = "kong/workspaces/init.lua",
    ["kong.workspaces.helper"] = "kong/workspaces/helper.lua",
    ["kong.workspaces.dao_wrappers"] = "kong/workspaces/dao_wrappers.lua",

    ["kong.portal"] = "kong/portal/init.lua",
    ["kong.portal.api"] = "kong/portal/api.lua",
    ["kong.portal.dao_helpers"] = "kong/portal/dao_helpers.lua",
    ["kong.portal.crud_helpers"] = "kong/portal/crud_helpers.lua",
    ["kong.portal.utils"] = "kong/portal/utils.lua",
    ["kong.portal.migrations.01_initial_files"] = "kong/portal/migrations/01_initial_files.lua",
    ["kong.portal.emails"] = "kong/portal/emails.lua",
    ["kong.portal.gui"] = "kong/portal/gui.lua",
    ["kong.portal.auth"] = "kong/portal/auth.lua",
    ["kong.portal.renderer"] = "kong/portal/renderer.lua",
    ["kong.portal.gui_helpers"] = "kong/portal/gui_helpers.lua",

    ["kong.vitals"] = "kong/vitals/init.lua",
    ["kong.vitals.cassandra.strategy"] = "kong/vitals/cassandra/strategy.lua",
    ["kong.vitals.postgres.strategy"] = "kong/vitals/postgres/strategy.lua",
    ["kong.vitals.postgres.table_rotater"] = "kong/vitals/postgres/table_rotater.lua",
    ["kong.vitals.prometheus.strategy"] = "kong/vitals/prometheus/strategy.lua",
    ["kong.vitals.prometheus.statsd.logger"] = "kong/vitals/prometheus/statsd/logger.lua",
    ["kong.vitals.prometheus.statsd.handler"] = "kong/vitals/prometheus/statsd/handler.lua",
    ["kong.vitals.influxdb.strategy"] = "kong/vitals/influxdb/strategy.lua",
    ["kong.db"] = "kong/db/init.lua",
    ["kong.db.errors"] = "kong/db/errors.lua",
    ["kong.db.iteration"] = "kong/db/iteration.lua",
    ["kong.db.dao"] = "kong/db/dao/init.lua",
    ["kong.db.dao.certificates"] = "kong/db/dao/certificates.lua",
    ["kong.db.dao.snis"] = "kong/db/dao/snis.lua",
    ["kong.db.dao.targets"] = "kong/db/dao/targets.lua",
    ["kong.db.dao.plugins"] = "kong/db/dao/plugins.lua",
    ["kong.db.dao.rbac_roles"] = "kong/db/dao/rbac_roles.lua",
    ["kong.db.dao.rbac_users"] = "kong/db/dao/rbac_users.lua",
    ["kong.db.schema"] = "kong/db/schema/init.lua",
    ["kong.db.schema.entities.apis"] = "kong/db/schema/entities/apis.lua",
    ["kong.db.schema.entities.cluster_ca"] = "kong/db/schema/entities/cluster_ca.lua",
    ["kong.db.schema.entities.consumers"] = "kong/db/schema/entities/consumers.lua",
    ["kong.db.schema.entities.routes"] = "kong/db/schema/entities/routes.lua",
    ["kong.db.schema.entities.services"] = "kong/db/schema/entities/services.lua",
    ["kong.db.schema.entities.certificates"] = "kong/db/schema/entities/certificates.lua",
    ["kong.db.schema.entities.snis"] = "kong/db/schema/entities/snis.lua",
    ["kong.db.schema.entities.upstreams"] = "kong/db/schema/entities/upstreams.lua",
    ["kong.db.schema.entities.targets"] = "kong/db/schema/entities/targets.lua",
    ["kong.db.schema.entities.plugins"] = "kong/db/schema/entities/plugins.lua",
    ["kong.db.schema.entities.workspaces"] = "kong/db/schema/entities/workspaces.lua",
    ["kong.db.schema.entities.workspace_entities"] = "kong/db/schema/entities/workspace_entities.lua",
    ["kong.db.schema.others.migrations"] = "kong/db/schema/others/migrations.lua",
    ["kong.db.schema.entity"] = "kong/db/schema/entity.lua",
    ["kong.db.schema.metaschema"] = "kong/db/schema/metaschema.lua",
    ["kong.db.schema.typedefs"] = "kong/db/schema/typedefs.lua",
    ["kong.db.strategies"] = "kong/db/strategies/init.lua",
    ["kong.db.strategies.connector"] = "kong/db/strategies/connector.lua",
    ["kong.db.strategies.cassandra"] = "kong/db/strategies/cassandra/init.lua",
    ["kong.db.strategies.cassandra.connector"] = "kong/db/strategies/cassandra/connector.lua",
    ["kong.db.strategies.cassandra.plugins"] = "kong/db/strategies/cassandra/plugins.lua",
    ["kong.db.strategies.cassandra.services"] = "kong/db/strategies/cassandra/services.lua",
    ["kong.db.strategies.postgres"] = "kong/db/strategies/postgres/init.lua",
    ["kong.db.strategies.postgres.plugins"] = "kong/db/strategies/postgres/plugins.lua",
    ["kong.db.strategies.postgres.connector"] = "kong/db/strategies/postgres/connector.lua",

    ["kong.db.strategies.postgres.services"] = "kong/db/strategies/postgres/services.lua",
    ["kong.db.strategies.postgres.routes"] = "kong/db/strategies/postgres/routes.lua",

    ["kong.db.migrations.state"] = "kong/db/migrations/state.lua",
    ["kong.db.migrations.helpers"] = "kong/db/migrations/helpers.lua",
    ["kong.db.migrations.core"] = "kong/db/migrations/core/init.lua",
    ["kong.db.migrations.core.000_base"] = "kong/db/migrations/core/000_base.lua",
    ["kong.db.migrations.core.001_14_to_15"] = "kong/db/migrations/core/001_14_to_15.lua",

    ["kong.pdk"] = "kong/pdk/init.lua",
    ["kong.pdk.private.checks"] = "kong/pdk/private/checks.lua",
    ["kong.pdk.private.phases"] = "kong/pdk/private/phases.lua",
    ["kong.pdk.client"] = "kong/pdk/client.lua",
    ["kong.pdk.ctx"] = "kong/pdk/ctx.lua",
    ["kong.pdk.ip"] = "kong/pdk/ip.lua",
    ["kong.pdk.log"] = "kong/pdk/log.lua",
    ["kong.pdk.service"] = "kong/pdk/service.lua",
    ["kong.pdk.service.request"] = "kong/pdk/service/request.lua",
    ["kong.pdk.service.response"] = "kong/pdk/service/response.lua",
    ["kong.pdk.router"] = "kong/pdk/router.lua",
    ["kong.pdk.request"] = "kong/pdk/request.lua",
    ["kong.pdk.response"] = "kong/pdk/response.lua",
    ["kong.pdk.table"] = "kong/pdk/table.lua",
    ["kong.pdk.node"] = "kong/pdk/node.lua",

    ["kong.plugins.base_plugin"] = "kong/plugins/base_plugin.lua",

    ["kong.plugins.basic-auth.migrations.cassandra"] = "kong/plugins/basic-auth/migrations/cassandra.lua",
    ["kong.plugins.basic-auth.migrations.postgres"] = "kong/plugins/basic-auth/migrations/postgres.lua",
    ["kong.plugins.basic-auth.migrations"] = "kong/plugins/basic-auth/migrations/init.lua",
    ["kong.plugins.basic-auth.migrations.000_base_basic_auth"] = "kong/plugins/basic-auth/migrations/000_base_basic_auth.lua",
    ["kong.plugins.basic-auth.migrations.001_14_to_15"] = "kong/plugins/basic-auth/migrations/001_14_to_15.lua",
    ["kong.plugins.basic-auth.crypto"] = "kong/plugins/basic-auth/crypto.lua",
    ["kong.plugins.basic-auth.handler"] = "kong/plugins/basic-auth/handler.lua",
    ["kong.plugins.basic-auth.access"] = "kong/plugins/basic-auth/access.lua",
    ["kong.plugins.basic-auth.schema"] = "kong/plugins/basic-auth/schema.lua",
    ["kong.plugins.basic-auth.api"] = "kong/plugins/basic-auth/api.lua",
    ["kong.plugins.basic-auth.daos"] = "kong/plugins/basic-auth/daos.lua",
    ["kong.plugins.basic-auth.basicauth_credentials"] = "kong/plugins/basic-auth/basicauth_credentials.lua",

    ["kong.plugins.key-auth.migrations.cassandra"] = "kong/plugins/key-auth/migrations/cassandra.lua",
    ["kong.plugins.key-auth.migrations.postgres"] = "kong/plugins/key-auth/migrations/postgres.lua",
    ["kong.plugins.key-auth.migrations"] = "kong/plugins/key-auth/migrations/init.lua",
    ["kong.plugins.key-auth.migrations.000_base_key_auth"] = "kong/plugins/key-auth/migrations/000_base_key_auth.lua",
    ["kong.plugins.key-auth.migrations.001_14_to_15"] = "kong/plugins/key-auth/migrations/001_14_to_15.lua",
    ["kong.plugins.key-auth.handler"] = "kong/plugins/key-auth/handler.lua",
    ["kong.plugins.key-auth.schema"] = "kong/plugins/key-auth/schema.lua",
    ["kong.plugins.key-auth.api"] = "kong/plugins/key-auth/api.lua",
    ["kong.plugins.key-auth.daos"] = "kong/plugins/key-auth/daos.lua",

    ["kong.plugins.oauth2.migrations.cassandra"] = "kong/plugins/oauth2/migrations/cassandra.lua",
    ["kong.plugins.oauth2.migrations.postgres"] = "kong/plugins/oauth2/migrations/postgres.lua",
    ["kong.plugins.oauth2.migrations"] = "kong/plugins/oauth2/migrations/init.lua",
    ["kong.plugins.oauth2.migrations.000_base_oauth2"] = "kong/plugins/oauth2/migrations/000_base_oauth2.lua",
    ["kong.plugins.oauth2.migrations.001_14_to_15"] = "kong/plugins/oauth2/migrations/001_14_to_15.lua",
    ["kong.plugins.oauth2.handler"] = "kong/plugins/oauth2/handler.lua",
    ["kong.plugins.oauth2.access"] = "kong/plugins/oauth2/access.lua",
    ["kong.plugins.oauth2.schema"] = "kong/plugins/oauth2/schema.lua",
    ["kong.plugins.oauth2.daos"] = "kong/plugins/oauth2/daos.lua",
    ["kong.plugins.oauth2.api"] = "kong/plugins/oauth2/api.lua",

    ["kong.plugins.log-buffering.json_producer"] = "kong/plugins/log-buffering/json_producer.lua",
    ["kong.plugins.log-buffering.lua_producer"] = "kong/plugins/log-buffering/lua_producer.lua",
    ["kong.plugins.log-buffering.buffer"] = "kong/plugins/log-buffering/buffer.lua",

    ["kong.plugins.log-serializers.basic"] = "kong/plugins/log-serializers/basic.lua",

    ["kong.plugins.tcp-log.handler"] = "kong/plugins/tcp-log/handler.lua",
    ["kong.plugins.tcp-log.schema"] = "kong/plugins/tcp-log/schema.lua",
    ["kong.plugins.tcp-log.migrations.cassandra"] = "kong/plugins/tcp-log/migrations/cassandra.lua",
    ["kong.plugins.tcp-log.migrations.postgres"] = "kong/plugins/tcp-log/migrations/postgres.lua",

    ["kong.plugins.udp-log.handler"] = "kong/plugins/udp-log/handler.lua",
    ["kong.plugins.udp-log.schema"] = "kong/plugins/udp-log/schema.lua",

    ["kong.plugins.http-log.handler"] = "kong/plugins/http-log/handler.lua",
    ["kong.plugins.http-log.schema"] = "kong/plugins/http-log/schema.lua",
    ["kong.plugins.http-log.sender"] = "kong/plugins/http-log/sender.lua",

    ["kong.plugins.file-log.handler"] = "kong/plugins/file-log/handler.lua",
    ["kong.plugins.file-log.schema"] = "kong/plugins/file-log/schema.lua",

    ["kong.plugins.galileo.migrations.cassandra"] = "kong/plugins/galileo/migrations/cassandra.lua",
    ["kong.plugins.galileo.migrations.postgres"] = "kong/plugins/galileo/migrations/postgres.lua",
    ["kong.plugins.galileo.producer"] = "kong/plugins/galileo/producer.lua",
    ["kong.plugins.galileo.handler"] = "kong/plugins/galileo/handler.lua",
    ["kong.plugins.galileo.sender"] = "kong/plugins/galileo/sender.lua",
    ["kong.plugins.galileo.schema"] = "kong/plugins/galileo/schema.lua",
    ["kong.plugins.galileo.alf"] = "kong/plugins/galileo/alf.lua",

    ["kong.plugins.rate-limiting.migrations.cassandra"] = "kong/plugins/rate-limiting/migrations/cassandra.lua",
    ["kong.plugins.rate-limiting.migrations.postgres"] = "kong/plugins/rate-limiting/migrations/postgres.lua",
    ["kong.plugins.rate-limiting.migrations"] = "kong/plugins/rate-limiting/migrations/init.lua",
    ["kong.plugins.rate-limiting.migrations.000_base_rate_limiting"] = "kong/plugins/rate-limiting/migrations/000_base_rate_limiting.lua",
    ["kong.plugins.rate-limiting.migrations.001_14_to_15"] = "kong/plugins/rate-limiting/migrations/001_14_to_15.lua",
    ["kong.plugins.rate-limiting.handler"] = "kong/plugins/rate-limiting/handler.lua",
    ["kong.plugins.rate-limiting.schema"] = "kong/plugins/rate-limiting/schema.lua",
    ["kong.plugins.rate-limiting.daos"] = "kong/plugins/rate-limiting/daos.lua",
    ["kong.plugins.rate-limiting.policies"] = "kong/plugins/rate-limiting/policies/init.lua",
    ["kong.plugins.rate-limiting.policies.cluster"] = "kong/plugins/rate-limiting/policies/cluster.lua",

    ["kong.plugins.response-ratelimiting.migrations.cassandra"] = "kong/plugins/response-ratelimiting/migrations/cassandra.lua",
    ["kong.plugins.response-ratelimiting.migrations.postgres"] = "kong/plugins/response-ratelimiting/migrations/postgres.lua",
    ["kong.plugins.response-ratelimiting.migrations"] = "kong/plugins/response-ratelimiting/migrations/init.lua",
    ["kong.plugins.response-ratelimiting.migrations.000_base_response_rate_limiting"] = "kong/plugins/response-ratelimiting/migrations/000_base_response_rate_limiting.lua",
    ["kong.plugins.response-ratelimiting.migrations.001_14_to_15"] = "kong/plugins/response-ratelimiting/migrations/001_14_to_15.lua",
    ["kong.plugins.response-ratelimiting.handler"] = "kong/plugins/response-ratelimiting/handler.lua",
    ["kong.plugins.response-ratelimiting.access"] = "kong/plugins/response-ratelimiting/access.lua",
    ["kong.plugins.response-ratelimiting.header_filter"] = "kong/plugins/response-ratelimiting/header_filter.lua",
    ["kong.plugins.response-ratelimiting.log"] = "kong/plugins/response-ratelimiting/log.lua",
    ["kong.plugins.response-ratelimiting.schema"] = "kong/plugins/response-ratelimiting/schema.lua",
    ["kong.plugins.response-ratelimiting.daos"] = "kong/plugins/response-ratelimiting/daos.lua",
    ["kong.plugins.response-ratelimiting.policies"] = "kong/plugins/response-ratelimiting/policies/init.lua",
    ["kong.plugins.response-ratelimiting.policies.cluster"] = "kong/plugins/response-ratelimiting/policies/cluster.lua",

    ["kong.plugins.request-size-limiting.handler"] = "kong/plugins/request-size-limiting/handler.lua",
    ["kong.plugins.request-size-limiting.schema"] = "kong/plugins/request-size-limiting/schema.lua",

    ["kong.plugins.request-transformer.migrations.cassandra"] = "kong/plugins/request-transformer/migrations/cassandra.lua",
    ["kong.plugins.request-transformer.migrations.postgres"] = "kong/plugins/request-transformer/migrations/postgres.lua",
    ["kong.plugins.request-transformer.handler"] = "kong/plugins/request-transformer/handler.lua",
    ["kong.plugins.request-transformer.access"] = "kong/plugins/request-transformer/access.lua",
    ["kong.plugins.request-transformer.schema"] = "kong/plugins/request-transformer/schema.lua",

    ["kong.plugins.response-transformer.migrations.cassandra"] = "kong/plugins/response-transformer/migrations/cassandra.lua",
    ["kong.plugins.response-transformer.migrations.postgres"] = "kong/plugins/response-transformer/migrations/postgres.lua",
    ["kong.plugins.response-transformer.handler"] = "kong/plugins/response-transformer/handler.lua",
    ["kong.plugins.response-transformer.body_transformer"] = "kong/plugins/response-transformer/body_transformer.lua",
    ["kong.plugins.response-transformer.header_transformer"] = "kong/plugins/response-transformer/header_transformer.lua",
    ["kong.plugins.response-transformer.schema"] = "kong/plugins/response-transformer/schema.lua",
    ["kong.plugins.response-transformer.feature_flags.limit_body"] = "kong/plugins/response-transformer/feature_flags/limit_body.lua",

    ["kong.plugins.cors.handler"] = "kong/plugins/cors/handler.lua",
    ["kong.plugins.cors.schema"] = "kong/plugins/cors/schema.lua",
    ["kong.plugins.cors.migrations.cassandra"] = "kong/plugins/cors/migrations/cassandra.lua",
    ["kong.plugins.cors.migrations.postgres"] = "kong/plugins/cors/migrations/postgres.lua",

    ["kong.plugins.ip-restriction.handler"] = "kong/plugins/ip-restriction/handler.lua",
    ["kong.plugins.ip-restriction.schema"] = "kong/plugins/ip-restriction/schema.lua",
    ["kong.plugins.ip-restriction.migrations.cassandra"] = "kong/plugins/ip-restriction/migrations/cassandra.lua",
    ["kong.plugins.ip-restriction.migrations.postgres"] = "kong/plugins/ip-restriction/migrations/postgres.lua",

    ["kong.plugins.acl.migrations.cassandra"] = "kong/plugins/acl/migrations/cassandra.lua",
    ["kong.plugins.acl.migrations.postgres"] = "kong/plugins/acl/migrations/postgres.lua",
    ["kong.plugins.acl.migrations"] = "kong/plugins/acl/migrations/init.lua",
    ["kong.plugins.acl.migrations.000_base_acl"] = "kong/plugins/acl/migrations/000_base_acl.lua",
    ["kong.plugins.acl.migrations.001_14_to_15"] = "kong/plugins/acl/migrations/001_14_to_15.lua",
    ["kong.plugins.acl.handler"] = "kong/plugins/acl/handler.lua",
    ["kong.plugins.acl.schema"] = "kong/plugins/acl/schema.lua",
    ["kong.plugins.acl.api"] = "kong/plugins/acl/api.lua",
    ["kong.plugins.acl.daos"] = "kong/plugins/acl/daos.lua",
    ["kong.plugins.acl.groups"] = "kong/plugins/acl/groups.lua",
    ["kong.plugins.acl.acls"] = "kong/plugins/acl/acls.lua",

    ["kong.plugins.correlation-id.handler"] = "kong/plugins/correlation-id/handler.lua",
    ["kong.plugins.correlation-id.schema"] = "kong/plugins/correlation-id/schema.lua",

    ["kong.plugins.jwt.migrations.cassandra"] = "kong/plugins/jwt/migrations/cassandra.lua",
    ["kong.plugins.jwt.migrations.postgres"] = "kong/plugins/jwt/migrations/postgres.lua",
    ["kong.plugins.jwt.migrations"] = "kong/plugins/jwt/migrations/init.lua",
    ["kong.plugins.jwt.migrations.000_base_jwt"] = "kong/plugins/jwt/migrations/000_base_jwt.lua",
    ["kong.plugins.jwt.migrations.001_14_to_15"] = "kong/plugins/jwt/migrations/001_14_to_15.lua",
    ["kong.plugins.jwt.handler"] = "kong/plugins/jwt/handler.lua",
    ["kong.plugins.jwt.schema"] = "kong/plugins/jwt/schema.lua",
    ["kong.plugins.jwt.api"] = "kong/plugins/jwt/api.lua",
    ["kong.plugins.jwt.daos"] = "kong/plugins/jwt/daos.lua",
    ["kong.plugins.jwt.jwt_parser"] = "kong/plugins/jwt/jwt_parser.lua",
    ["kong.plugins.jwt.asn_sequence"] = "kong/plugins/jwt/asn_sequence.lua",

    ["kong.plugins.hmac-auth.migrations.cassandra"] = "kong/plugins/hmac-auth/migrations/cassandra.lua",
    ["kong.plugins.hmac-auth.migrations.postgres"] = "kong/plugins/hmac-auth/migrations/postgres.lua",
    ["kong.plugins.hmac-auth.migrations"] = "kong/plugins/hmac-auth/migrations/init.lua",
    ["kong.plugins.hmac-auth.migrations.000_base_hmac_auth"] = "kong/plugins/hmac-auth/migrations/000_base_hmac_auth.lua",
    ["kong.plugins.hmac-auth.migrations.001_14_to_15"] = "kong/plugins/hmac-auth/migrations/001_14_to_15.lua",
    ["kong.plugins.hmac-auth.handler"] = "kong/plugins/hmac-auth/handler.lua",
    ["kong.plugins.hmac-auth.access"] = "kong/plugins/hmac-auth/access.lua",
    ["kong.plugins.hmac-auth.schema"] = "kong/plugins/hmac-auth/schema.lua",
    ["kong.plugins.hmac-auth.api"] = "kong/plugins/hmac-auth/api.lua",
    ["kong.plugins.hmac-auth.daos"] = "kong/plugins/hmac-auth/daos.lua",

    ["kong.plugins.ldap-auth.migrations.cassandra"] = "kong/plugins/ldap-auth/migrations/cassandra.lua",
    ["kong.plugins.ldap-auth.migrations.postgres"] = "kong/plugins/ldap-auth/migrations/postgres.lua",
    ["kong.plugins.ldap-auth.handler"] = "kong/plugins/ldap-auth/handler.lua",
    ["kong.plugins.ldap-auth.access"] = "kong/plugins/ldap-auth/access.lua",
    ["kong.plugins.ldap-auth.schema"] = "kong/plugins/ldap-auth/schema.lua",
    ["kong.plugins.ldap-auth.ldap"] = "kong/plugins/ldap-auth/ldap.lua",
    ["kong.plugins.ldap-auth.asn1"] = "kong/plugins/ldap-auth/asn1.lua",

    ["kong.plugins.syslog.handler"] = "kong/plugins/syslog/handler.lua",
    ["kong.plugins.syslog.schema"] = "kong/plugins/syslog/schema.lua",

    ["kong.plugins.loggly.handler"] = "kong/plugins/loggly/handler.lua",
    ["kong.plugins.loggly.schema"] = "kong/plugins/loggly/schema.lua",

    ["kong.plugins.datadog.migrations.cassandra"] = "kong/plugins/datadog/migrations/cassandra.lua",
    ["kong.plugins.datadog.migrations.postgres"] = "kong/plugins/datadog/migrations/postgres.lua",
    ["kong.plugins.datadog.handler"] = "kong/plugins/datadog/handler.lua",
    ["kong.plugins.datadog.schema"] = "kong/plugins/datadog/schema.lua",
    ["kong.plugins.datadog.statsd_logger"] = "kong/plugins/datadog/statsd_logger.lua",

    ["kong.plugins.statsd.migrations.cassandra"] = "kong/plugins/statsd/migrations/cassandra.lua",
    ["kong.plugins.statsd.migrations.postgres"] = "kong/plugins/statsd/migrations/postgres.lua",
    ["kong.plugins.statsd.handler"] = "kong/plugins/statsd/handler.lua",
    ["kong.plugins.statsd.schema"] = "kong/plugins/statsd/schema.lua",
    ["kong.plugins.statsd.statsd_logger"] = "kong/plugins/statsd/statsd_logger.lua",

    ["kong.plugins.bot-detection.handler"] = "kong/plugins/bot-detection/handler.lua",
    ["kong.plugins.bot-detection.schema"] = "kong/plugins/bot-detection/schema.lua",
    ["kong.plugins.bot-detection.rules"] = "kong/plugins/bot-detection/rules.lua",

    ["kong.plugins.aws-lambda.handler"] = "kong/plugins/aws-lambda/handler.lua",
    ["kong.plugins.aws-lambda.schema"] = "kong/plugins/aws-lambda/schema.lua",
    ["kong.plugins.aws-lambda.v4"] = "kong/plugins/aws-lambda/v4.lua",

    ["kong.plugins.request-termination.handler"] = "kong/plugins/request-termination/handler.lua",
    ["kong.plugins.request-termination.schema"] = "kong/plugins/request-termination/schema.lua",
  }
}
