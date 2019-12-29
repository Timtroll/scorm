DO $$
BEGIN
    RAISE NOTICE '0001-EAV-fixes.sql';
END;
$$;

BEGIN;

DROP FUNCTION IF EXISTS "public"."_is_column_exists"( _Schema varchar(255), _Table varchar(255), _Field varchar(255) );
CREATE OR REPLACE FUNCTION _is_column_exists( _Schema varchar(255), _Table varchar(255), _Field varchar(255) ) RETURNS boolean AS $$
DECLARE
    Result boolean;
BEGIN
    SELECT EXISTS( SELECT 1 FROM "information_schema"."columns" WHERE "table_schema" = _Schema AND "table_name" = _Table AND "column_name" = _Field ) INTO Result;
    RETURN Result;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions', 'address_id' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions"
        DROP CONSTRAINT "EAV_submodules_subscriptions_pkey" ,
        ADD COLUMN "address_id" int4 DEFAULT 0 NOT NULL,
        ADD CONSTRAINT "EAV_submodules_subscriptions_pkey" PRIMARY KEY ("owner_id", "sla_id", "service_id", "distance", "owner_type", "address_id");
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_owner_id_address_id_idx" ON "public"."EAV_submodules_subscriptions" ("owner_id", "address_id");

-- CREATE TABLE IF NOT EXISTS "public"."EAV_submodules_locations" (
-- "id" int4 NOT NULL,
-- "title" varchar(255) COLLATE "default",
-- "prefixed_address" varchar(255) COLLATE "default",
-- "clean_address" varchar(255) COLLATE "default",
-- "distance_from_root" int4,
-- "region" int4,
-- "city" int4,
-- "street" int4,
-- "count_users" int4,
-- "count_users_direct" int4,
-- "count_office" int4,
-- CONSTRAINT "EAV_submodules_locations_pkey" PRIMARY KEY ("id")
-- )
-- WITH (OIDS=FALSE)
-- ;
CREATE TABLE IF NOT EXISTS "public"."EAV_submodules_locations" (
    "id" int4 NOT NULL,
    "title" varchar(255) COLLATE "default",
    "prefixed_address" varchar(255) COLLATE "default",
    "clean_address" varchar(255) COLLATE "default",
    "distance_from_root" int4,
    "region" int4,
    "city" int4,
    "street" int4,
    "count_users" int4,
    "count_users_direct" int4,
    "count_office" int4,
    "count_users_published" int4,
    "count_users_published_direct" int4,
    "publish_alias" bool,
    "type_subscription_alias" bool,
    CONSTRAINT "EAV_submodules_locations_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."EAV_submodules_locations" OWNER TO "otrs";



CREATE INDEX IF NOT EXISTS "EAV_submodules_locations_region_city_idx" ON "public"."EAV_submodules_locations" USING btree ("region", "city");

CREATE INDEX IF NOT EXISTS "EAV_submodules_locations_region_city_street_idx" ON "public"."EAV_submodules_locations" USING btree ("region", "city", "street");

CREATE INDEX IF NOT EXISTS "EAV_submodules_locations_region_idx" ON "public"."EAV_submodules_locations" USING btree ("region");

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_locations', 'count_users_published' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_locations"
        ADD COLUMN "count_users_published" int4;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_locations', 'count_users_published_direct' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_locations"
        ADD COLUMN "count_users_published_direct" int4;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions_counts', 'bitmap' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions_counts"
        ADD COLUMN "bitmap" int4 DEFAULT 0 NOT NULL,
        DROP CONSTRAINT "EAV_submodules_subscriptions_counts_pkey",
        ADD CONSTRAINT "EAV_submodules_subscriptions_counts_pkey" PRIMARY KEY ( "item_id", "distance", "bitmap" );
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions_counts_with_service', 'bitmap' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_service"
        ADD COLUMN "bitmap" int4 DEFAULT 0 NOT NULL,
        DROP CONSTRAINT "EAV_submodules_subscriptions_counts_with_service_pkey",
        ADD CONSTRAINT "EAV_submodules_subscriptions_counts_with_service_pkey" PRIMARY KEY ( "item_id", "service_id", "distance", "bitmap" );
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions_counts_with_sla', 'bitmap' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_sla"
        ADD COLUMN "bitmap" int4 DEFAULT 0 NOT NULL,
        DROP CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_pkey",
        ADD CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_pkey" PRIMARY KEY ( "item_id", "sla_id", "distance", "bitmap" );
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions_counts_with_sla_and_service', 'bitmap' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_sla_and_service"
        ADD COLUMN "bitmap" int4 DEFAULT 0 NOT NULL,
        DROP CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_and_service_pkey",
        ADD CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_and_service_pkey" PRIMARY KEY ( "item_id", "sla_id", "service_id", "distance", "bitmap" );
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions', 'publish_alias' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions"
        ADD COLUMN "publish_alias" boolean DEFAULT NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT ( _is_column_exists( 'public', 'EAV_submodules_subscriptions', 'type_subscription_alias' ) ) THEN
        ALTER TABLE "public"."EAV_submodules_subscriptions"
        ADD COLUMN "type_subscription_alias" boolean DEFAULT NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMIT;
