DROP TABLE IF EXISTS "public"."forum_groups";
DROP SEQUENCE IF EXISTS "public".forum_groups_id_seq; 
DROP TRIGGER IF EXISTS "groups_ad" ON "public"."forum_groups" CASCADE;

CREATE SEQUENCE "public".forum_groups_id_seq;
-- ALTER SEQUENCE "forum_groups_id_seq" RESTART WITH 1;

CREATE TABLE "public"."forum_groups" (
"id" int4 DEFAULT nextval('forum_groups_id_seq'::regclass) NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"title" varchar(255) COLLATE "default" NOT NULL,
"date_created" int4 NOT NULL,
"date_edited" int4 NOT NULL,
"status" int2 DEFAULT 1 NOT NULL,
CONSTRAINT "forum_groups_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_groups" OWNER TO "troll";

---функция (рекурсивное удаление тем группы)
CREATE OR REPLACE FUNCTION "public"."groups_trigger_ad"() RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
DELETE FROM "public"."forum_themes" WHERE "group_id" = OLD.id;

RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

---триггер
CREATE TRIGGER "groups_ad" AFTER DELETE ON "public"."forum_groups"
FOR EACH ROW
EXECUTE PROCEDURE "groups_trigger_ad"();
---------------------

DROP TABLE IF EXISTS "public"."forum_messages";
DROP SEQUENCE IF EXISTS "public".forum_messages_id_seq; 

CREATE SEQUENCE "public".forum_messages_id_seq;
-- ALTER SEQUENCE "forum_messages_id_seq" RESTART WITH 1;

CREATE TABLE "public"."forum_messages" (
"id" int4 DEFAULT nextval('forum_messages_id_seq'::regclass) NOT NULL,
"theme_id" int4 NOT NULL,
"user_id" int4 NOT NULL,
"anounce" varchar(255) COLLATE "default" NOT NULL,
"date_created" int4 NOT NULL,
"date_edited" int4 NOT NULL,
"msg" varchar(255) COLLATE "default" NOT NULL,
"rate" int4 NOT NULL,
"status" int2 DEFAULT 1 NOT NULL,
CONSTRAINT "forum_messages_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_messages" OWNER TO "troll";
---------------------

DROP TABLE IF EXISTS "public"."forum_rates";

CREATE TABLE "public"."forum_rates" (
"user_id" int4 NOT NULL,
"msg_id" int4 NOT NULL,
"like_value" int2 NOT NULL,
CONSTRAINT "forum_rates_pkey" PRIMARY KEY ("user_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_rates" OWNER TO "troll";
---------------------

DROP TABLE IF EXISTS "public"."forum_themes";
DROP SEQUENCE IF EXISTS "public".forum_themes_id_seq; 
DROP TRIGGER IF EXISTS "themes_ad" ON "public"."forum_themes" CASCADE;

CREATE SEQUENCE "public".forum_themes_id_seq;
-- ALTER SEQUENCE "forum_themes_id_seq" RESTART WITH 1;

CREATE TABLE "public"."forum_themes" (
"id" int4 DEFAULT nextval('forum_themes_id_seq'::regclass) NOT NULL,
"user_id" int4 NOT NULL,
"group_id" int4 NOT NULL,
"title" varchar(255) COLLATE "default" NOT NULL,
"url" varchar(255) COLLATE "default" NOT NULL,
"rate" int4 NOT NULL,
"date_created" int4 NOT NULL,
"date_edited" int4 NOT NULL,
"status" int2 DEFAULT 1 NOT NULL,
CONSTRAINT "forum_themes_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_themes" OWNER TO "troll";


---функция (рекурсивное удаление сообщений темы)
CREATE OR REPLACE FUNCTION "public"."themes_trigger_ad"() RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
DELETE FROM "public"."forum_messages" WHERE "theme_id" = OLD.id;

RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

---триггер
CREATE TRIGGER "themes_ad" AFTER DELETE ON "public"."forum_themes"
FOR EACH ROW
EXECUTE PROCEDURE "themes_trigger_ad"();
---------------------
