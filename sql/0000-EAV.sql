DO $$
BEGIN
    RAISE NOTICE '0000-EAV.sql';
END;
$$;

DO $$
BEGIN
    CREATE TYPE public.eav_field_type AS ENUM (
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
    CREATE TYPE public.eav_object_type AS ENUM (
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
    type public.eav_field_type DEFAULT 'blob'::public.eav_field_type,
    default_value character varying(255),
    set public.eav_object_type,
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
    import_type public.eav_object_type,
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

CREATE EXTENSION hstore;

CREATE EXTENSION pg_trgm WITH SCHEMA "pg_catalog";