DO $$
BEGIN
    RAISE NOTICE '0000-EAV.sql';
END;
$$;

BEGIN;

DO $$
BEGIN
    CREATE TYPE public.subscriptions_field_type AS ENUM (
        'blob',
        'boolean',
        'int',
        'string',
        'datetime'
    );
EXCEPTION 
    WHEN duplicate_object THEN null;
END$$;

DO $$
BEGIN
    CREATE TYPE public.subscriptions_object_type AS ENUM (
        'service',
        'office',
        'user',
        'subscription',
        'sla',
        'address',
        'Default',
        'location'
    );
EXCEPTION 
    WHEN duplicate_object THEN null;
END$$;

CREATE OR REPLACE FUNCTION public."EAV_submodules_subscriptions_trigger_any"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    _row record;
        _delta int4;
        
BEGIN
---insert only..
    IF TG_OP = 'INSERT' THEN
        FOR _row IN 
            SELECT * FROM "EAV_links" WHERE "id" = NEW.owner_id
        LOOP
                INSERT INTO "public"."EAV_submodules_subscriptions_counts" ( "item_id", "distance", "count" ) VALUES ( _row.parent, _row.distance+1, 1 ) 
                ON CONFLICT 
                ON CONSTRAINT "EAV_submodules_subscriptions_counts_pkey" DO UPDATE SET "count" = EXCLUDED."count" + 1;
        END LOOP;

        INSERT INTO "public"."EAV_submodules_subscriptions_counts" ( "item_id", "distance", "count" ) VALUES ( NEW.owner_id, 0, 1 ) 
        ON CONFLICT 
        ON CONSTRAINT "EAV_submodules_subscriptions_counts_pkey" DO UPDATE SET "count" = EXCLUDED."count" + 1;
        
        RETURN NEW;
        ELSIF TG_OP = 'DELETE' THEN
              RETURN OLD;
        ELSIF TG_OP = 'UPDATE' THEN
              RETURN NEW;
    END IF;
END;
$$;


CREATE TABLE IF NOT EXISTS public."EAV_data_boolean" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data boolean,
    PRIMARY KEY(id, field_id)
);


CREATE TABLE IF NOT EXISTS public."EAV_data_boolean_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data boolean
);


CREATE TABLE IF NOT EXISTS public."EAV_data_datetime" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data timestamp without time zone,
    PRIMARY KEY(id, field_id)
);


CREATE TABLE IF NOT EXISTS public."EAV_data_datetime_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data timestamp without time zone
);


CREATE TABLE IF NOT EXISTS public."EAV_data_int4" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data integer,
    PRIMARY KEY(id, field_id)
);


CREATE TABLE IF NOT EXISTS public."EAV_data_int4_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data integer
);


CREATE TABLE IF NOT EXISTS public."EAV_data_string" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data character varying(4096),
    PRIMARY KEY(id, field_id)
);

CREATE TABLE IF NOT EXISTS public."EAV_data_string_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data character varying(4096)
);

CREATE SEQUENCE IF NOT EXISTS public.eav_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE IF NOT EXISTS public."EAV_fields" (
    id integer DEFAULT nextval('public.eav_fields_id_seq'::regclass) NOT NULL,
    alias character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    type public.subscriptions_field_type DEFAULT 'blob'::public.subscriptions_field_type,
    default_value character varying(255),
    set public.subscriptions_object_type,
    CONSTRAINT unique_field UNIQUE(alias, set)
);

CREATE SEQUENCE IF NOT EXISTS public.eav_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE IF NOT EXISTS public."EAV_items" (
    id integer DEFAULT nextval('public.eav_items_id_seq'::regclass) NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    import_id integer DEFAULT 0,
    import_type public.subscriptions_object_type,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated date,
    title character varying(4096),
    parent integer,
    has_childs integer DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public."EAV_links" (
    parent integer DEFAULT 0 NOT NULL,
    id integer DEFAULT 0 NOT NULL,
    distance integer DEFAULT 0 NOT NULL,
    PRIMARY KEY ("parent", "id")
);

CREATE TABLE IF NOT EXISTS public."EAV_submodules_subscriptions" (
    owner_id integer NOT NULL,
    sla_id integer NOT NULL,
    service_id integer NOT NULL,
    subscription_id integer DEFAULT 0 NOT NULL,
    distance smallint DEFAULT 0 NOT NULL,
    owner_type public.subscriptions_object_type NOT NULL,
    deny boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS public."EAV_submodules_subscriptions_counts" (
    item_id integer NOT NULL,
    distance smallint NOT NULL,
    count integer DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS public."EAV_submodules_subscriptions_counts_with_service" (
    item_id integer NOT NULL,
    service_id integer NOT NULL,
    distance smallint NOT NULL,
    count integer DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS public."EAV_submodules_subscriptions_counts_with_sla" (
    item_id integer NOT NULL,
    sla_id integer NOT NULL,
    distance smallint NOT NULL,
    count integer DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS public."EAV_submodules_subscriptions_counts_with_sla_and_service" (
    item_id integer NOT NULL,
    service_id integer NOT NULL,
    sla_id integer NOT NULL,
    distance smallint NOT NULL,
    count integer DEFAULT 0 NOT NULL
);

CREATE INDEX IF NOT EXISTS "EAV_links_id_distance_idx" ON "public"."EAV_links" USING btree ("id", "distance");
CREATE INDEX IF NOT EXISTS "EAV_links_id_idx" ON "public"."EAV_links" USING btree ("id");
CREATE INDEX IF NOT EXISTS "EAV_links_parent_distance_idx" ON "public"."EAV_links" USING btree ("parent", "distance");
CREATE INDEX IF NOT EXISTS "EAV_links_parent_idx" ON "public"."EAV_links" USING btree ("parent");

CREATE INDEX IF NOT EXISTS "EAV_data_boolean_field_id_data_idx" ON "public"."EAV_data_boolean" USING btree ("field_id", "data");
CREATE INDEX IF NOT EXISTS "EAV_data_datetime_field_id_data_idx" ON "public"."EAV_data_datetime" USING btree ("field_id", "data");
CREATE INDEX IF NOT EXISTS "EAV_data_int4_field_id_data_idx" ON "public"."EAV_data_int4" USING btree ("field_id", "data");
CREATE INDEX IF NOT EXISTS "EAV_data_string_field_id_data_idx" ON "public"."EAV_data_string" USING btree ("field_id", "data");
 
CREATE UNIQUE INDEX IF NOT EXISTS "EAV_items_id_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "has_childs");
CREATE UNIQUE INDEX IF NOT EXISTS "EAV_items_id_import_type_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "import_type", "has_childs");
CREATE INDEX IF NOT EXISTS "EAV_items_id_import_type_title_idx" ON "public"."EAV_items" USING btree ("id", "import_type", "title");
CREATE UNIQUE INDEX IF NOT EXISTS "EAV_items_id_publish_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "publish", "has_childs");
CREATE UNIQUE INDEX IF NOT EXISTS "EAV_items_id_publish_import_type_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "publish", "import_type", "has_childs");
CREATE INDEX IF NOT EXISTS "EAV_items_import_id_import_type_idx" ON "public"."EAV_items" USING btree ("import_id", "import_type");
CREATE INDEX IF NOT EXISTS "EAV_items_import_type_title_idx" ON "public"."EAV_items" USING btree ("import_type", "title");
CREATE INDEX IF NOT EXISTS "EAV_items_publish_import_type_title_idx" ON "public"."EAV_items" USING btree ("publish", "import_type", "title");

CREATE OR REPLACE FUNCTION "public"."EAV_links_trigger_ai"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
    _row record;
    _iParent record;
    _iSelf record;
BEGIN
    IF ( NEW.distance = 0 ) THEN
        FOR _row IN 
            SELECT * FROM "public"."EAV_links" WHERE "id" = NEW.parent
        LOOP
            INSERT INTO "public"."EAV_links" ( "id", "parent", "distance" ) VALUES ( NEW.id, _row.parent, _row.distance + 1 ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "distance" = _row.distance + 1;
        END LOOP;

        UPDATE "public"."EAV_items" SET "has_childs" = "has_childs" + 1 WHERE "id" = NEW.parent;
        SELECT * INTO _iParent FROM "public"."EAV_items" WHERE "id" = NEW.parent;
        SELECT * INTO _iSelf FROM "public"."EAV_items" WHERE "id" = NEW.id;
        IF ( _iSelf.import_type = _iParent.import_type ) THEN
            UPDATE "public"."EAV_items" SET "parent" = NEW.parent WHERE "id" = NEW.id;
            END IF;
    END IF;
    RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100
;

ALTER FUNCTION "public"."EAV_links_trigger_ai"() OWNER TO "otrs";

DROP TRIGGER IF EXISTS "EAV_links_trigger_ai" ON "public"."EAV_links";
CREATE TRIGGER "EAV_links_trigger_ai" AFTER INSERT ON "public"."EAV_links"
FOR EACH ROW
EXECUTE PROCEDURE "EAV_links_trigger_ai"();


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO otrs;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO otrs;

--Add EAV primary keys, maybe other constraints

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_items" ADD PRIMARY KEY ("id");
        EXCEPTION
            WHEN duplicate_table THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_fields" ADD PRIMARY KEY ("id");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" ADD PRIMARY KEY ("item_id", "service_id", "sla_id", "distance");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_sla" ADD PRIMARY KEY ("item_id", "sla_id", "distance");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_submodules_subscriptions_counts_with_service" ADD PRIMARY KEY ("item_id", "service_id", "distance");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_submodules_subscriptions_counts" ADD PRIMARY KEY ("item_id", "distance");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;

DO $$
    BEGIN
        BEGIN
            ALTER TABLE "public"."EAV_submodules_subscriptions" ADD PRIMARY KEY ("owner_id", "sla_id", "service_id", "distance", "owner_type");
        EXCEPTION
            WHEN duplicate_object THEN RAISE NOTICE '%, skipping', SQLERRM USING ERRCODE = SQLSTATE;
        END;
    END
$$;


CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_owner_id_distance_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("owner_id", "distance");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_owner_id_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("owner_id");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_service_id_distance_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("service_id", "distance");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_service_id_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("service_id");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_sla_id_distance_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("sla_id", "distance");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_sla_id_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("sla_id");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_subscription_id_distance_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("subscription_id", "distance");
CREATE INDEX IF NOT EXISTS "EAV_submodules_subscriptions_subscription_id_idx" ON "public"."EAV_submodules_subscriptions" USING btree ("subscription_id");

CREATE EXTENSION hstore;

CREATE OR REPLACE FUNCTION "public"."EAV_submodules_subscriptions_trigger_any"() RETURNS "pg_catalog"."trigger" AS $BODY$

DECLARE
    _row record;
    _bitmap_current int array[8];
    _bitmap_old int array[8];
    _process_bitmap_updates boolean := false;
    _type_subscription_field_id int := 0;
    _bitmap int := 0;
    _i int := 0;
    _bma_o int [];
    _bma_c int [];
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN

        IF NEW."publish_alias" IS NULL THEN
            _bitmap_current[1] := 0;
        ELSIF NEW."publish_alias" THEN
            _bitmap_current[1] := 2;
        ELSE
            _bitmap_current[1] := 1;
        END IF;

        IF NEW."type_subscription_alias" IS NULL THEN
            _bitmap_current[2] := 0;
        ELSIF NEW."type_subscription_alias" THEN
            _bitmap_current[2] := 8;
        ELSE
            _bitmap_current[2] := 4;
        END IF;

        IF NEW."deny" THEN
            _bitmap_current[3] := 32;
        ELSE
            _bitmap_current[3] := 16;
        END IF;
        
        --combinations
        _bitmap_current[4] := _bitmap_current[3] | _bitmap_current[2];
        _bitmap_current[5] := _bitmap_current[3] | _bitmap_current[1];
        _bitmap_current[6] := _bitmap_current[2] | _bitmap_current[1];
        _bitmap_current[7] := _bitmap_current[3] | _bitmap_current[2] | _bitmap_current[1];
        _bitmap_current[8] := 0;

        SELECT "id" INTO _type_subscription_field_id FROM "public"."EAV_fields" WHERE "alias" = 'type_subscription' AND "set" = 'subscription';
        UPDATE "public"."EAV_items" SET "publish" = NEW."publish_alias" WHERE "id" = NEW."subscription_id";
        INSERT INTO "public"."EAV_data_boolean" ( "id", "field_id", "data" ) VALUES ( NEW."subscription_id", _type_subscription_field_id, NEW."type_subscription_alias" )
        ON CONFLICT
        ON CONSTRAINT "EAV_data_boolean_pkey" DO UPDATE SET "data" = NEW."type_subscription_alias";
    END IF;
    
    IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN

        IF OLD."publish_alias" IS NULL THEN
            _bitmap_old[1] := 0;
        ELSIF OLD."publish_alias" THEN
            _bitmap_old[1] := 2;
        ELSE
            _bitmap_old[1] := 1;
        END IF;

        IF OLD."type_subscription_alias" IS NULL THEN
            _bitmap_old[2] := 0;
        ELSIF OLD."type_subscription_alias" THEN
            _bitmap_old[2] := 8;
        ELSE
            _bitmap_old[2] := 4;
        END IF;

        IF OLD."deny" THEN
            _bitmap_old[3] := 32;
        ELSE
            _bitmap_old[3] := 16;
        END IF;

        _bitmap_old[4] := _bitmap_old[3] | _bitmap_old[2];
        _bitmap_old[5] := _bitmap_old[3] | _bitmap_old[1];
        _bitmap_old[6] := _bitmap_old[2] | _bitmap_old[1];
        _bitmap_old[7] := _bitmap_old[3] | _bitmap_old[2] | _bitmap_old[1];
        _bitmap_old[8] := 0;
    END IF;

    IF TG_OP = 'INSERT' THEN
        PERFORM "public"."EAV_submodules_subscriptions_trigger_any_CountsIncrementHelper"( hstore( NEW ), _bitmap_current );

        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM "public"."EAV_submodules_subscriptions_trigger_any_CountsDecrementHelper"( hstore( OLD ), _bitmap_old );

        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        FOREACH _bitmap IN ARRAY _bitmap_old 
        LOOP
            _i := _i + 1;
            IF ( _bitmap_old[ _i ] != _bitmap_current[ _i ] ) THEN
                _process_bitmap_updates = true;
                _bma_o = array_append( _bma_o, _bitmap_old[ _i ] );
                _bma_c = array_append( _bma_c, _bitmap_current[ _i ] );
            END IF;
        END LOOP;

        IF _process_bitmap_updates THEN
            PERFORM "public"."EAV_submodules_subscriptions_trigger_any_CountsDecrementHelper"( hstore( OLD ), _bma_o );
            PERFORM "public"."EAV_submodules_subscriptions_trigger_any_CountsIncrementHelper"( hstore( NEW ), _bma_c );
        END IF;

        RETURN NEW;
    END IF;
END;$BODY$
    LANGUAGE 'plpgsql' VOLATILE COST 100
;

CREATE OR REPLACE FUNCTION "public"."EAV_submodules_subscriptions_trigger_any_CountsDecrementHelper" ( _DATA hstore, _bitmap_old int[] ) RETURNS void AS $BODY$
DECLARE
    _row record;
    _bitmap int;
BEGIN
    FOR _row IN 
        SELECT * FROM "EAV_links" WHERE "id" = (_DATA->'owner_id')::integer
    LOOP
        FOREACH _bitmap IN ARRAY _bitmap_old 
        LOOP
            UPDATE "public"."EAV_submodules_subscriptions_counts" SET "count" = "count" - 1 WHERE "item_id" = _row.parent AND "distance" = _row.distance + 1 AND "bitmap" = _bitmap;
            UPDATE "public"."EAV_submodules_subscriptions_counts_with_service" SET "count" = "count" - 1 WHERE "item_id" = _row.parent AND "service_id" = (_DATA->'service_id')::integer AND "distance" = _row.distance + 1 AND "bitmap" = _bitmap;
            UPDATE "public"."EAV_submodules_subscriptions_counts_with_sla" SET "count" = "count" - 1 WHERE "item_id" = _row.parent AND "sla_id" = (_DATA->'sla_id')::integer AND "distance" = _row.distance + 1 AND "bitmap" = _bitmap;
            UPDATE "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" SET "count" = "count" - 1 WHERE "item_id" = _row.parent AND "sla_id" = (_DATA->'sla_id')::integer AND "service_id" = (_DATA->'service_id')::integer AND "distance" = _row.distance + 1 AND "bitmap" = _bitmap;
        END LOOP;
    END LOOP;

    FOREACH _bitmap IN ARRAY _bitmap_old 
    LOOP
        UPDATE "public"."EAV_submodules_subscriptions_counts" SET "count" = "count" - 1 WHERE "item_id" = (_DATA->'owner_id')::integer AND "distance" = 0 AND "count" > 0 AND "bitmap" = _bitmap;
        UPDATE "public"."EAV_submodules_subscriptions_counts_with_service" SET "count" = "count" - 1 WHERE "item_id" = (_DATA->'owner_id')::integer AND "service_id" = (_DATA->'service_id')::integer AND "distance" = 0 AND "count" > 0 AND "bitmap" = _bitmap;
        UPDATE "public"."EAV_submodules_subscriptions_counts_with_sla" SET "count" = "count" - 1 WHERE "item_id" = (_DATA->'owner_id')::integer AND "sla_id" = (_DATA->'sla_id')::integer AND "distance" = 0 AND "count" > 0 AND "bitmap" = _bitmap;
        UPDATE "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" SET "count" = "count" - 1 WHERE "item_id" = (_DATA->'owner_id')::integer AND "sla_id" = (_DATA->'sla_id')::integer AND "service_id" = (_DATA->'service_id')::integer AND "distance" = 0 AND "count" > 0 AND "bitmap" = _bitmap;
    END LOOP;
END;$BODY$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION "public"."EAV_submodules_subscriptions_trigger_any_CountsIncrementHelper" ( _DATA hstore, _bitmap_current int[] ) RETURNS void AS $BODY$
DECLARE
    _row record;
    _bitmap int;
BEGIN
    FOR _row IN 
        SELECT * FROM "EAV_links" WHERE "id" = (_DATA->'owner_id')::integer
    LOOP
        FOREACH _bitmap IN ARRAY _bitmap_current 
        LOOP
            INSERT INTO "public"."EAV_submodules_subscriptions_counts" ( "item_id", "distance", "count", "bitmap" ) VALUES ( _row.parent, _row.distance+1, 1, _bitmap ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_submodules_subscriptions_counts_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts"."count" + 1;

            INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_sla" ( "item_id", "sla_id", "distance", "count", "bitmap" ) VALUES ( _row.parent, (_DATA->'sla_id')::integer, _row.distance+1, 1, _bitmap ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_sla"."count" + 1;

            INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_service" ( "item_id", "service_id", "distance", "count", "bitmap" ) VALUES ( _row.parent, (_DATA->'service_id')::integer, _row.distance+1, 1, _bitmap ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_service_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_service"."count" + 1;

            INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" ( "item_id", "sla_id", "service_id", "distance", "count", "bitmap" ) VALUES ( _row.parent, (_DATA->'sla_id')::integer, (_DATA->'service_id')::integer, _row.distance+1, 1, _bitmap ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_and_service_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_sla_and_service"."count" + 1;
        END LOOP;
    END LOOP;

    FOREACH _bitmap IN ARRAY _bitmap_current 
    LOOP
        INSERT INTO "public"."EAV_submodules_subscriptions_counts" ( "item_id", "distance", "count", "bitmap" ) VALUES ( (_DATA->'owner_id')::integer, 0, 1, _bitmap ) 
        ON CONFLICT 
        ON CONSTRAINT "EAV_submodules_subscriptions_counts_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts"."count" + 1;

        INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_sla" ( "item_id", "sla_id", "distance", "count", "bitmap" ) VALUES ( (_DATA->'owner_id')::integer, (_DATA->'sla_id')::integer, 0, 1, _bitmap ) 
        ON CONFLICT 
        ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_sla"."count" + 1;

        INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_service" ( "item_id", "service_id", "distance", "count", "bitmap" ) VALUES ( (_DATA->'owner_id')::integer, (_DATA->'service_id')::integer, 0, 1, _bitmap ) 
        ON CONFLICT 
        ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_service_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_service"."count" + 1;

        INSERT INTO "public"."EAV_submodules_subscriptions_counts_with_sla_and_service" ( "item_id", "sla_id", "service_id", "distance", "count", "bitmap" ) VALUES ( (_DATA->'owner_id')::integer, (_DATA->'sla_id')::integer, (_DATA->'service_id')::integer, 0, 1, _bitmap ) 
        ON CONFLICT 
        ON CONSTRAINT "EAV_submodules_subscriptions_counts_with_sla_and_service_pkey" DO UPDATE SET "count" = "EAV_submodules_subscriptions_counts_with_sla_and_service"."count" + 1;
    END LOOP;

END;$BODY$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS "EAV_submodules_subscriptions_any" ON "public"."EAV_submodules_subscriptions";
CREATE TRIGGER "EAV_submodules_subscriptions_any" AFTER INSERT OR UPDATE OR DELETE ON "public"."EAV_submodules_subscriptions"
FOR EACH ROW
EXECUTE PROCEDURE "EAV_submodules_subscriptions_trigger_any"();

COMMIT;


BEGIN;
    CREATE EXTENSION pg_trgm WITH SCHEMA "pg_catalog";
COMMIT;

