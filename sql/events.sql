CREATE SEQUENCE IF NOT EXISTS "public".events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."events" (
    "id" int4 DEFAULT nextval('events_id_seq'::regclass) NOT NULL,
    "initial_id" int4 DEFAULT 0 NOT NULL,
    "time_start" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "comment" varchar(255) COLLATE "default" NOT NULL,
    "publish" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "events_pkey" PRIMARY KEY ("id", "eav_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."events" OWNER TO "troll";