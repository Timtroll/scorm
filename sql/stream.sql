--таблица
DROP TABLE IF EXISTS "public"."streams";
DROP SEQUENCE IF EXISTS "public".streams_id_seq; 

CREATE SEQUENCE "public".streams_id_seq;

CREATE TABLE "public"."streams" (
    "id" int4 DEFAULT nextval('streams_id_seq'::regclass) NOT NULL,
    "name" varchar(255) COLLATE "default" NOT NULL,
    "age" int2 DEFAULT 1 NOT NULL,
    "date" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "master_id" int4,
    "publish" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "streams_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."streams" OWNER TO "troll";
ALTER TABLE "public"."streams" ADD CONSTRAINT stream_name UNIQUE (name);