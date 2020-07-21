CREATE TYPE "public"."social" AS ENUM (
    'vk',
    'fb',
    'google',
    'yandex',
    'twitter'
);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."users" (
    "id" int4 DEFAULT nextval('users_id_seq'::regclass) NOT NULL,
    "publish" boolean DEFAULT false NOT NULL,
    "email" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "phone" varchar(16) COLLATE "default" DEFAULT NULL::character varying,
    "password" varchar(32) COLLATE "default" DEFAULT NULL::character varying,
    "eav_id" int4 DEFAULT 0 NOT NULL,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "time_access" timestamptz(6),
    "time_update" timestamptz(6),
    "timezone" int2 DEFAULT 3,
    "groups" varchar(255) DEFAULT NULL,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."users" OWNER TO "troll";

CREATE TABLE "public"."users_flags" (
    "user_id" int4 NOT NULL,
    "key" varchar(32) COLLATE "default" NOT NULL,
    "mask" int8 DEFAULT 0,
    CONSTRAINT "users_flags_pkey" PRIMARY KEY ("user_id", "key")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."users_flags" OWNER TO "troll";

CREATE TABLE "public"."users_social" (
    "user_id" int4 NOT NULL,
    "social" "public"."social" NOT NULL,
    "access_token" varchar(4096) COLLATE "default" DEFAULT NULL::character varying NOT NULL,
    "social_id" varchar(32) COLLATE "default" DEFAULT NULL::character varying,
    "social_profile" jsonb,
    CONSTRAINT "users_social_pkey" PRIMARY KEY ("user_id", "social")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."users_social" OWNER TO "troll";

---функция ( синхронизация статуса пользователя в users и EAV_items )
CREATE OR REPLACE FUNCTION "public"."users_trigger_set"() RETURNS "pg_catalog"."trigger" AS $BODY$
BEGIN
UPDATE "public"."EAV_items" SET "publish" = NEW.publish WHERE "id" = OLD.id;

RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

CREATE TRIGGER "users_set"
AFTER UPDATE OF "publish" ON "public"."users"
FOR EACH ROW
WHEN ( OLD.publish IS DISTINCT FROM NEW.publish )
EXECUTE PROCEDURE "users_trigger_set"();

-- связь юзеров и групп 
CREATE TABLE "public"."user_groups" (
"user_id" int4 DEFAULT 0 NOT NULL,
"group_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_groups_pkey" PRIMARY KEY ("user_id", "group_id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_groups" OWNER TO "troll";
---------------------