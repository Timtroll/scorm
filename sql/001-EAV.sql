CREATE SEQUENCE IF NOT EXISTS "public".eav_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE "public".eav_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
-- ALTER SEQUENCE "eav_fields_id_seq" RESTART WITH 1;
-- ALTER SEQUENCE "eav_items_id_seq" RESTART WITH 1;

CREATE TYPE "public"."EAV_field_type" AS ENUM (
    'blob',
    'boolean',
    'int',
    'string',
    'datetime'
);

CREATE TYPE "public"."EAV_object_type" AS ENUM (
    'User',
    'Discipline',
    'Theme',
    'Default'
);

CREATE TABLE "public"."EAV_data_boolean" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data boolean
);

CREATE TABLE "public"."EAV_data_boolean_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data boolean
);

CREATE TABLE "public"."EAV_data_datetime" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data timestamp without time zone
);

CREATE TABLE "public"."EAV_data_datetime_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data timestamp without time zone
);

CREATE TABLE "public"."EAV_data_int4" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data integer
);

CREATE TABLE "public"."EAV_data_int4_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data integer
);

CREATE TABLE "public"."EAV_data_string" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data character varying(4096)
);

CREATE TABLE "public"."EAV_data_string_history" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    date_changed timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data character varying(4096)
);

CREATE TABLE "public"."EAV_fields" (
    id integer DEFAULT nextval('public.eav_fields_id_seq'::regclass) NOT NULL,
    alias character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    type "public"."EAV_field_type" DEFAULT 'blob'::"public"."EAV_field_type",
    default_value character varying(255),
    set "public"."EAV_object_type"
);

CREATE TABLE "public"."EAV_items" (
    id integer DEFAULT nextval('public.eav_items_id_seq'::regclass) NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    import_id integer DEFAULT 0,
    type "public"."EAV_object_type",
    import_source varchar,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    title character varying(4096),
    parent integer,
    has_childs integer DEFAULT 0
    -- import_source "public".import_source
);

CREATE TABLE "public"."EAV_links" (
    parent integer DEFAULT 0 NOT NULL,
    id integer DEFAULT 0 NOT NULL,
    distance integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY "public"."EAV_data_boolean"
    ADD CONSTRAINT "EAV_data_boolean_pkey" PRIMARY KEY (id, field_id);

ALTER TABLE ONLY "public"."EAV_data_datetime"
    ADD CONSTRAINT "EAV_data_datetime_pkey" PRIMARY KEY (id, field_id);

ALTER TABLE ONLY "public"."EAV_data_int4"
    ADD CONSTRAINT "EAV_data_int4_pkey" PRIMARY KEY (id, field_id);

ALTER TABLE ONLY "public"."EAV_data_string"
    ADD CONSTRAINT "EAV_data_string_pkey" PRIMARY KEY (id, field_id);

ALTER TABLE ONLY "public"."EAV_fields"
    ADD CONSTRAINT "EAV_fields_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "public"."EAV_items"
    ADD CONSTRAINT "EAV_items_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "public"."EAV_links"
    ADD CONSTRAINT "EAV_links_pkey" PRIMARY KEY (parent, id);

ALTER TABLE ONLY "public"."EAV_fields"
   ADD CONSTRAINT unique_field UNIQUE (alias, set);

CREATE FUNCTION "public"."EAV_links_trigger_ai"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
        IF ( _iSelf.type = _iParent.type ) THEN
            UPDATE "public"."EAV_items" SET "parent" = NEW.parent WHERE "id" = NEW.id;
            END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE FUNCTION "public"."EAV_items_trigger_ai"() RETURNS trigger
    AS $$
BEGIN
    INSERT INTO "public"."EAV_links" ( parent, id, distance ) VALUES (0, NEW.id, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION "public"._is_column_exists(_schema character varying, _table character varying, _field character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    Result boolean;
BEGIN
    SELECT EXISTS( SELECT 1 FROM "information_schema"."columns" WHERE "table_schema" = _Schema AND "table_name" = _Table AND "column_name" = _Field ) INTO Result;
    RETURN Result;
END;
$$;

CREATE FUNCTION "public".eav_createfield(fset character varying, falias character varying, ftitle character varying, ftype character varying, fdefault character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    FieldID integer;
BEGIN
    SELECT "id" INTO FieldID FROM "public"."EAV_fields" WHERE "alias" = FAlias AND "set" = FSet::"public"."EAV_object_type";

    IF ( FieldID IS NULL ) THEN
        INSERT INTO "public"."EAV_fields" ( "alias", "title", "type", "default_value", "set" ) VALUES ( FAlias, FTitle, FType::"public"."EAV_field_type", FDefault, FSet::"public"."EAV_object_type" );
    ELSE
        RAISE NOTICE 'EAV field ( %, % ) already exists - %', FSet, FAlias, FieldID;
    END IF;
END;
$$;


CREATE FUNCTION "public".eav_getfieldid(_set character varying, _alias character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT "id" FROM "public"."EAV_fields" WHERE "set" = _set::"EAV_object_type" AND "alias" = _alias;
$$;


CREATE FUNCTION "public".eav_getrootid(_type character varying) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
    SELECT "id" FROM "public"."EAV_items" WHERE "type" = _type::"EAV_object_type" AND "parent" = 0;
$$;

CREATE INDEX "EAV_data_boolean_field_id_data_idx" ON "public"."EAV_data_boolean" USING btree (field_id, data);

CREATE INDEX "EAV_data_datetime_field_id_data_idx" ON "public"."EAV_data_datetime" USING btree (field_id, data);

CREATE INDEX "EAV_data_int4_field_id_data_idx" ON "public"."EAV_data_int4" USING btree (field_id, data);

CREATE UNIQUE INDEX "EAV_items_id_has_childs_idx" ON "public"."EAV_items" USING btree (id, has_childs);

CREATE UNIQUE INDEX "EAV_items_id_type_has_childs_idx" ON "public"."EAV_items" USING btree (id, type, has_childs);

CREATE UNIQUE INDEX "EAV_items_id_publish_has_childs_idx" ON "public"."EAV_items" USING btree (id, publish, has_childs);

CREATE UNIQUE INDEX "EAV_items_id_publish_type_has_childs_idx" ON "public"."EAV_items" USING btree (id, publish, type, has_childs);

CREATE INDEX "EAV_items_import_id_type_idx" ON "public"."EAV_items" USING btree (import_id, type);

CREATE INDEX "EAV_links_id_distance_idx" ON "public"."EAV_links" USING btree (id, distance);

CREATE INDEX "EAV_links_id_idx" ON "public"."EAV_links" USING btree (id);

CREATE INDEX "EAV_links_parent_distance_idx" ON "public"."EAV_links" USING btree (parent, distance);

CREATE INDEX "EAV_links_parent_idx" ON "public"."EAV_links" USING btree (parent);

CREATE INDEX "EAV_lower_data_string_field_id_data_idx" ON "public"."EAV_data_string" USING btree (field_id, lower((data)::text));

CREATE TRIGGER "EAV_links_trigger_ai" AFTER INSERT ON "public"."EAV_links" FOR EACH ROW EXECUTE PROCEDURE "public"."EAV_links_trigger_ai"();

CREATE TRIGGER "EAV_items_trigger_ai" AFTER INSERT ON "public"."EAV_items" FOR EACH ROW EXECUTE PROCEDURE "public"."EAV_items_trigger_ai"();

CREATE INDEX "EAV_data_string_field_id_data_gin_idx" ON "public"."EAV_data_string" USING gin (field_id, lower((data)::text) "public".gin_trgm_ops);

CREATE INDEX "EAV_items_type_title_gin_idx" ON "public"."EAV_items" USING gin (type, lower((title)::text) "public".gin_trgm_ops);

CREATE INDEX "EAV_items_publish_type_title_gin_idx" ON "public"."EAV_items" USING gin (((publish)::integer), type, lower((title)::text) "public".gin_trgm_ops);

