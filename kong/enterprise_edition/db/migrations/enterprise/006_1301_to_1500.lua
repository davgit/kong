local function pg_delete_we_orphan(entity)
  return [[
    DELETE FROM workspace_entities WHERE entity_id IN (
      SELECT entity_id FROM (
        SELECT * from workspace_entities WHERE entity_type=']] .. entity .. [['
      ) t1 LEFT JOIN ]] .. entity .. [[ t2
      ON t2.id::text = t1.entity_id
      WHERE t2.id IS NULL
    );
  ]]
end

local function pg_fix_we_counters(entity)
  return [[
    UPDATE workspace_entity_counters AS wec
      SET count = we.count FROM (
        SELECT d.workspace_id AS workspace_id,
               d.entity_type AS entity_type,
               coalesce(c.count, 0) AS count
        FROM (
          SELECT id AS workspace_id, ']] .. entity .. [['::text AS entity_type
          FROM workspaces
        ) AS d LEFT JOIN (
        SELECT workspace_id, entity_type, COUNT(DISTINCT entity_id)
          FROM workspace_entities
          WHERE entity_type = ']] .. entity .. [['
          GROUP BY workspace_id, entity_type
        ) c
        ON d.workspace_id = c.workspace_id
      ) AS we
    WHERE wec.workspace_id = we.workspace_id
    AND wec.entity_type = we.entity_type;
  ]]
end

return {
  postgres = {
    up = [[
      -- XXX: EE keep run_on for now
      DO $$
      BEGIN
        ALTER TABLE IF EXISTS ONLY "plugins" ADD "run_on" TEXT;
      EXCEPTION WHEN duplicate_column THEN
        -- Do nothing, accept existing state
      END;
      $$;
    ]],
    teardown = function(connector)
      -- XXX: EE keep run_on for now
      -- We run both on up and teardown because of two possible conditions:
      --    - upgrade from kong CE: run_on gets _was_ deleted on teardown.
      --                            We run mig. up on new kong-ee, no run_on
      --                            column added, so it fails to start.
      --                            That's why we want it on up.
      --
      --    - upgrade from kong EE: run_on gets deleted on teardown by CE mig,
      --                            so up migration does not do anything since
      --                            it's already there.
      --                            That's why we want it on teardown
      assert(connector:query([[
        DO $$
        BEGIN
          ALTER TABLE IF EXISTS ONLY "plugins" ADD "run_on" TEXT;
        EXCEPTION WHEN duplicate_column THEN
          -- Do nothing, accept existing state
        END;
        $$;
      ]]))

      -- List of entities that are workspaceable and have ttl
      local entities = {
        "keyauth_credentials",
        "oauth2_tokens",
        "oauth2_authorization_codes",
      }

      for _, entity in ipairs(entities) do
        -- delete orphan workspace_entities
        assert(connector:query(pg_delete_we_orphan(entity)))
        -- re-do workspace_entity_counters
        assert(connector:query(pg_fix_we_counters(entity)))
      end
    end,
  },

  cassandra = {
    up = [[
      -- XXX: EE keep run_on for now
      ALTER TABLE plugins ADD run_on TEXT;
    ]],
    teardown = function(connector)
      -- XXX: EE keep run_on for now, ignore error
      connector:query([[
        ALTER TABLE plugins ADD run_on TEXT;
      ]])
    end,
  }
}
