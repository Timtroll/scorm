---таблица
DROP TABLE IF EXISTS "public"."groups";
DROP TRIGGER IF EXISTS "groups_ad" ON "public"."groups" CASCADE;
DROP SEQUENCE IF EXISTS "public".groups_id_seq; 

CREATE SEQUENCE "public".groups_id_seq;

CREATE TABLE "public"."groups" (
"id" int4 DEFAULT nextval('groups_id_seq'::regclass) NOT NULL,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"status" int2 DEFAULT 1 NOT NULL,
CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."groups" OWNER TO "troll";
ALTER TABLE "public"."groups" ADD CONSTRAINT name UNIQUE (name);


CREATE UNIQUE INDEX "groups_name_idx" ON "public"."groups" USING btree ("name");

----функция (рекурсивное удаление детей)
CREATE OR REPLACE FUNCTION "public"."groups_trigger_ad"() RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
DELETE FROM "public"."routes" WHERE "parent" = OLD.id;

RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

----триггер
CREATE TRIGGER "groups_ad" AFTER DELETE ON "public"."groups"
FOR EACH ROW
EXECUTE PROCEDURE "groups_trigger_ad"();
-- this file has an error