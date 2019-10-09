--таблица
DROP TABLE IF EXISTS "public"."routes" CASCADE;
DROP TRIGGER IF EXISTS "settings_ad" ON "public"."settings" CASCADE;
DROP SEQUENCE IF EXISTS "public".settings_id_seq CASCADE; 

CREATE SEQUENCE "public".settings_id_seq;

CREATE TABLE "public"."settings" (
"id" int4 DEFAULT nextval('settings_id_seq'::regclass) NOT NULL,
"parent" int4,
"name" varchar(255) COLLATE "default" NOT NULL,
"label" varchar(255) COLLATE "default" NOT NULL,
"placeholder" varchar(255) COLLATE "default",
"type" varchar(255) COLLATE "default",
"mask" varchar(255) COLLATE "default",
"value" text COLLATE "default",
"selected" text COLLATE "default",
"required" int4 DEFAULT 1,
"readonly" int4 DEFAULT 0,
"status" int2 DEFAULT 1 NOT NULL
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."settings" OWNER TO "troll";


---функция (рекурсивное удаление детей)
CREATE OR REPLACE FUNCTION "public"."settings_trigger_ad"() RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
DELETE FROM "public"."settings" WHERE "parent" = OLD.id;

RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

---триггер
CREATE TRIGGER "settings_ad" AFTER DELETE ON "public"."settings"
FOR EACH ROW
EXECUTE PROCEDURE "settings_trigger_ad"();