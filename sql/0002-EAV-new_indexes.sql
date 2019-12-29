DO $$
BEGIN
    RAISE NOTICE '0002-EAV-new_indexes.sql';
END;
$$;

BEGIN;

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS btree_gin;

DROP INDEX IF EXISTS "EAV_items_id_import_type_title_idx";
DROP INDEX IF EXISTS "EAV_items_import_type_title_idx";
DROP INDEX IF EXISTS "EAV_items_publish_import_type_title_idx";

DROP INDEX IF EXISTS "EAV_data_string_field_id_data_idx";
DROP INDEX IF EXISTS "EAV_data_string_id_field_id_data_idx";

DROP INDEX IF EXISTS "EAV_data_string_id_field_id_data_idx_l";
DROP INDEX IF EXISTS "EAV_data_string_field_id_data_idx_l";
DROP INDEX IF EXISTS "EAV_items_publish_import_type_title_idx_l";
DROP INDEX IF EXISTS "EAV_items_import_type_title_idx_l";
DROP INDEX IF EXISTS "EAV_items_id_import_type_title_idx_l";
DROP INDEX IF EXISTS "eav_submodules_locations_trgm_prefixed_address_idx"; 

CREATE INDEX IF NOT EXISTS "EAV_submodules_locations_prefixed_address_gin_idx" ON "EAV_submodules_locations" USING GIN (lower("prefixed_address") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "EAV_submodules_locations_clean_address_gin_idx" ON "EAV_submodules_locations" USING GIN (lower("clean_address") gin_trgm_ops, count_users, count_office);
CREATE INDEX IF NOT EXISTS "EAV_items_import_type_title_gin_idx" ON "EAV_items" USING GIN ("import_type", lower("title") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "EAV_items_publish_import_type_title_gin_idx" ON "EAV_items" USING GIN (CAST("publish" AS integer), "import_type", lower("title") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "EAV_data_string_field_id_data_gin_idx" ON "EAV_data_string" USING GIN ("field_id", lower("data") gin_trgm_ops);

COMMIT;
