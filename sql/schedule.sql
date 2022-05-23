CREATE SEQUENCE IF NOT EXISTS "public".schedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."schedule" (
    "id" int4 DEFAULT nextval('schedule_id_seq'::regclass) NOT NULL,
    "teacher_id" int4 DEFAULT 0 NOT NULL,
    "course_id" int4 DEFAULT 0 NOT NULL,
    "time_start" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "time_start_sec" int4 DEFAULT 0 NOT NULL,
    "duration" int4 DEFAULT 0 NOT NULL,
    "publish" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "schedule_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."schedule" OWNER TO "troll";