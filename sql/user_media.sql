CREATE TYPE "public"."social" AS ENUM (
    'vk',
    'fb',
    'google',
    'yandex',
    'twitter'
);

CREATE SEQUENCE users_pkey
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."users" (
    "id" int4 DEFAULT nextval('users_pkey'::regclass) NOT NULL,
    "email" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "password" varchar(32) COLLATE "default" DEFAULT NULL::character varying,
    "eav_id" int4 DEFAULT 0 NOT NULL,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "time_access" timestamptz(6),
    "time_update" timestamptz(6),
    "timezone" int2 DEFAULT 3,
    CONSTRAINT "users_pkey1" PRIMARY KEY ("id")
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



--------------------------
CREATE SEQUENCE media_pkey
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
;

CREATE TABLE "public"."media" (
    "id" int4 DEFAULT nextval('media_pkey'::regclass) NOT NULL,
    "path" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "filename" varchar(32) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default",
    "size" int4,
    "type" varchar(32) COLLATE "default",
    "mime" varchar(255) COLLATE "default",
    "description" varchar(4096) COLLATE "default",
    "order" int4 DEFAULT 0,
    "flags" int8,
    CONSTRAINT "media_pkey1" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."media" OWNER TO "troll";
------------------------

CREATE TABLE "public"."media_version" (
    "id" int4 NOT NULL,
    "key" varchar(255) COLLATE "default" NOT NULL,
    "data" jsonb,
    "path" varchar(255) COLLATE "default" NOT NULL,
    "filename" varchar(32) COLLATE "default" NOT NULL,
    CONSTRAINT "media_version_pkey" PRIMARY KEY ("id", "key")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."media_version" OWNER TO "troll";

CREATE TABLE "public"."universal_links" (
    "a_link_id" int4 NOT NULL,
    "a_link_type" int4 NOT NULL,
    "b_link_id" int4 NOT NULL,
    "b_link_type" int4 NOT NULL,
    "owner_id" int4,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "univeral_links_pkey" PRIMARY KEY ("a_link_id", "a_link_type", "b_link_id", "b_link_type")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."universal_links" OWNER TO "troll";


CREATE TABLE "public"."universal_links_types" (
    "id" int4 NOT NULL,
    "alias" varchar(255) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    CONSTRAINT "universal_links_types_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."universal_links_types" OWNER TO "troll";



CREATE INDEX "a" ON "public"."universal_links" USING btree ("a_link_id", "a_link_type");

CREATE INDEX "ao" ON "public"."universal_links" USING btree ("a_link_id", "a_link_type", "owner_id");

CREATE INDEX "b" ON "public"."universal_links" USING btree ("b_link_id", "b_link_type");

CREATE INDEX "bo" ON "public"."universal_links" USING btree ("b_link_id", "b_link_type", "owner_id");

CREATE INDEX "ota" ON "public"."universal_links" USING btree ("a_link_type", "owner_id");

CREATE INDEX "otb" ON "public"."universal_links" USING btree ("b_link_type", "owner_id");

