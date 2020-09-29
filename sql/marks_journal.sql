CREATE SEQUENCE IF NOT EXISTS "public".marks_journal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."marks_journal" (
    "id" int8 DEFAULT nextval('marks_journal_id_seq'::regclass) NOT NULL,
    "user_id" int4 NOT NULL,
    "event_id" int8 NOT NULL,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "mark" INT NOT NULL,
    "k" NUMERIC DEFAULT 1, -- коэфициент оценки
    CONSTRAINT "marks_journal_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."marks_journal" OWNER TO "troll";