CREATE SEQUENCE IF NOT EXISTS "public".events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."events" (
    "id" int8 DEFAULT nextval('events_id_seq'::regclass) NOT NULL,
    "eav_id" int4 DEFAULT 0 NOT NULL,
    "time_start" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "time_end" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "events_pkey" PRIMARY KEY ("id", "eav_id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."events" OWNER TO "troll";