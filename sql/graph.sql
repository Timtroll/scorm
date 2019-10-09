DROP TABLE IF EXISTS "public"."EAV_links";
DROP TABLE IF EXISTS "public"."EAV_links";
DROP TABLE IF EXISTS "public"."EAV_fields";
DROP TABLE IF EXISTS "public"."EAV_items";
DROP TABLE IF EXISTS "public"."EAV_data_boolean";
DROP TABLE IF EXISTS "public"."EAV_data_boolean_history";
DROP TABLE IF EXISTS "public"."EAV_data_datetime";
DROP TABLE IF EXISTS "public"."EAV_data_datetime_history";
DROP TABLE IF EXISTS "public"."EAV_data_int4" CASCADE ;
DROP TABLE IF EXISTS "public"."EAV_data_int4_history";
DROP TABLE IF EXISTS "public"."EAV_data_string_history";
DROP TABLE IF EXISTS "public"."EAV_data_string";

DROP SEQUENCE IF EXISTS "public".eav_items_id_seq CASCADE;
DROP SEQUENCE IF EXISTS "public".eav_fields_id_seq CASCADE; 
DROP SEQUENCE IF EXISTS "public".EAV_field_type CASCADE; 
DROP SEQUENCE IF EXISTS "public".EAV_object_type CASCADE; 

DROP TYPE IF EXISTS "subscriptions_field_type";
DROP TYPE IF EXISTS "EAV_field_type" CASCADE;
DROP TYPE IF EXISTS "subscriptions_object_type";
DROP TYPE IF EXISTS "EAV_object_type";

CREATE TYPE "public"."EAV_field_type" AS ENUM ('blob', 'boolean', 'int', 'string', 'datetime');
ALTER TYPE "public"."EAV_field_type" OWNER TO "troll";

CREATE TYPE "public"."EAV_object_type" AS ENUM ('user');
ALTER TYPE "public"."EAV_object_type" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_links" (
"parent" int4 DEFAULT 0 NOT NULL,
"id" int4 DEFAULT 0 NOT NULL,
"distance" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "EAV_links_pkey" PRIMARY KEY ("parent", "id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."EAV_links" OWNER TO "troll";

CREATE OR REPLACE FUNCTION "public"."EAV_links_trigger_ai"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
    _row record;
BEGIN
    FOR _row IN 
        SELECT * FROM "EAV_links" WHERE "id" = NEW.parent
    LOOP
            INSERT INTO "public"."EAV_links" ( "id", "parent", "distance" ) VALUES ( NEW.id, _row.parent, _row.distance + 1 ) 
            ON CONFLICT 
            ON CONSTRAINT "EAV_links_pkey" DO UPDATE SET "distance" = _row.distance + 1;
    END LOOP;

     UPDATE "public"."EAV_items" SET "has_childs" = "has_childs" + 1 WHERE "id" = NEW.parent;
     UPDATE "public"."EAV_items" SET "parent" = NEW.parent WHERE "id" = NEW.id;
    RETURN NEW;
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100;

ALTER FUNCTION "public"."EAV_links_trigger_ai"() OWNER TO "troll";

CREATE TRIGGER "EAV_links_trigger_ai" AFTER INSERT ON "public"."EAV_links"
FOR EACH ROW
EXECUTE PROCEDURE "EAV_links_trigger_ai"();


/* */
CREATE SEQUENCE "public".eav_fields_id_seq;
CREATE SEQUENCE "public".EAV_field_type;
CREATE SEQUENCE "public".EAV_object_type;

CREATE TABLE "public"."EAV_fields" (
"id" int4 DEFAULT nextval('eav_fields_id_seq'::regclass) NOT NULL,
"alias" varchar(255) COLLATE "default" NOT NULL,
"title" varchar(255) COLLATE "default" NOT NULL,
"type" "public"."EAV_field_type" DEFAULT 'blob',
"default_value" varchar(255) COLLATE "default",
"set" "public"."EAV_object_type",
CONSTRAINT "EAV_fields_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_fields" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_string_history" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"date_changed" timestamptz(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
"data" varchar(255) COLLATE "default",
CONSTRAINT "EAV_data_string_history_pkey" PRIMARY KEY ("id", "field_id", "date_changed")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_string_history" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_string" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" varchar(255) COLLATE "default",
CONSTRAINT "EAV_data_string_pkey" PRIMARY KEY ("id", "field_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_string" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_int4_history" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"date_changed" timestamptz(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
"data" int4,
CONSTRAINT "EAV_data_int4_history_pkey" PRIMARY KEY ("id", "field_id", "date_changed")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_int4_history" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_int4" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" int4,
CONSTRAINT "EAV_data_int4_pkey" PRIMARY KEY ("id", "field_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_int4" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_datetime_history" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"date_changed" timestamptz(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
"data" timestamp(6),
CONSTRAINT "EAV_data_datetime_history_pkey" PRIMARY KEY ("id", "field_id", "date_changed")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_datetime_history" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_datetime" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" timestamp(6),
CONSTRAINT "EAV_data_datetime_pkey" PRIMARY KEY ("id", "field_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_datetime" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_boolean_history" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"date_changed" timestamptz(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
"data" bool,
CONSTRAINT "EAV_data_boolean_history_pkey" PRIMARY KEY ("id", "field_id", "date_changed")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_boolean_history" OWNER TO "troll";


/* */
CREATE TABLE "public"."EAV_data_boolean" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" bool,
CONSTRAINT "EAV_data_boolean_pkey" PRIMARY KEY ("id", "field_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_data_boolean" OWNER TO "troll";


/* */
CREATE SEQUENCE "public".eav_items_id_seq;

CREATE TABLE "public"."EAV_items" (
"id" int4 DEFAULT nextval('eav_items_id_seq'::regclass) NOT NULL,
"publish" bool DEFAULT false NOT NULL,
"import_id" int4 DEFAULT 0,
"import_type" "public"."EAV_object_type",
"date_created" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
"date_updated" date,
"title" varchar(255) COLLATE "default",
"parent" int4,
"has_childs" int4 DEFAULT 0,
CONSTRAINT "EAV_items_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."EAV_items" OWNER TO "troll";

CREATE UNIQUE INDEX "EAV_items_id_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "has_childs");
CREATE UNIQUE INDEX "EAV_items_id_import_type_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "import_type", "has_childs");
CREATE INDEX "EAV_items_id_import_type_title_idx" ON "public"."EAV_items" USING btree ("id", "import_type", "title");
CREATE UNIQUE INDEX "EAV_items_id_publish_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "publish", "has_childs");
CREATE UNIQUE INDEX "EAV_items_id_publish_import_type_has_childs_idx" ON "public"."EAV_items" USING btree ("id", "publish", "import_type", "has_childs");
CREATE INDEX "EAV_items_import_id_import_type_idx" ON "public"."EAV_items" USING btree ("import_id", "import_type");
CREATE INDEX "EAV_items_import_type_title_idx" ON "public"."EAV_items" USING btree ("import_type", "title");
CREATE INDEX "EAV_items_publish_import_type_title_idx" ON "public"."EAV_items" USING btree ("publish", "import_type", "title");

CREATE INDEX "EAV_data_string_field_id_data_idx" ON "public"."EAV_data_string" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_string_id_field_id_data_idx" ON "public"."EAV_data_string" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_string_id_field_id_idx" ON "public"."EAV_data_string" USING btree ("id", "field_id");

CREATE INDEX "EAV_data_boolean_field_id_data_idx" ON "public"."EAV_data_boolean" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_boolean_id_field_id_data_idx" ON "public"."EAV_data_boolean" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_boolean_id_field_id_idx" ON "public"."EAV_data_boolean" USING btree ("id", "field_id");
CREATE INDEX "EAV_data_datetime_field_id_data_idx" ON "public"."EAV_data_datetime" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_datetime_id_field_id_data_idx" ON "public"."EAV_data_datetime" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_datetime_id_field_id_idx" ON "public"."EAV_data_datetime" USING btree ("id", "field_id");
CREATE INDEX "EAV_data_int4_field_id_data_idx" ON "public"."EAV_data_int4" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_int4_id_field_id_data_idx" ON "public"."EAV_data_int4" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_int4_id_field_id_idx" ON "public"."EAV_data_int4" USING btree ("id", "field_id");
CREATE UNIQUE INDEX "EAV_fields_set_alias_idx" ON "public"."EAV_fields" USING btree ("set", "alias");
CREATE INDEX "EAV_links_id_distance_idx" ON "public"."EAV_links" USING btree ("id", "distance");
CREATE INDEX "EAV_links_id_idx" ON "public"."EAV_links" USING btree ("id");
CREATE INDEX "EAV_links_parent_distance_idx" ON "public"."EAV_links" USING btree ("parent", "distance");
CREATE INDEX "EAV_links_parent_idx" ON "public"."EAV_links" USING btree ("parent");
