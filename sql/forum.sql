DROP SEQUENCE IF EXISTS "public".forum_messages_id_seq; 
CREATE SEQUENCE "public".forum_messages_id_seq;

CREATE TABLE "public"."forum_messages" (
"id" int4 DEFAULT nextval('forum_messages_id_seq'::regclass) NOT NULL,
"theme_id" int4 NOT NULL,
"user_id" int4 NOT NULL,
"anounce" bool,
"date_created" int4 NOT NULL,
"msg" text COLLATE "default" NOT NULL,
"rate" int4 NOT NULL,
CONSTRAINT "forum_messages_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_messages" OWNER TO "troll";
---------------------

CREATE TABLE "public"."forum_rates" (
"user_id" int4 NOT NULL,
"msg_id" int4 NOT NULL,
"like_value" int2 NOT NULL,
CONSTRAINT "forum_rates_pkey" PRIMARY KEY ("user_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_rates" OWNER TO "troll";
---------------------

DROP SEQUENCE IF EXISTS "public".forum_themes_id_seq; 
CREATE SEQUENCE "public".forum_themes_id_seq;

CREATE TABLE "public"."forum_themes" (
"id" int4 DEFAULT nextval('forum_themes_id_seq'::regclass) NOT NULL,
"user_id" int4 NOT NULL,
"title" text COLLATE "default" NOT NULL,
"url" varchar(255) COLLATE "default" NOT NULL,
"rate" int4 NOT NULL,
"date_created" int4 NOT NULL,
CONSTRAINT "forum_themes_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."forum_themes" OWNER TO "troll";
---------------------


