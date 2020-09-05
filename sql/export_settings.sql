CREATE SEQUENCE export_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
-- ALTER SEQUENCE "export_settings_id_seq" RESTART WITH 1;

CREATE TABLE "public"."export_settings" (
    "id" int4 DEFAULT nextval('export_settings_id_seq'::regclass) NOT NULL,
    "title" varchar(255) COLLATE "default",
    "filename" varchar(48) COLLATE "default" NOT NULL,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "export_settings_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."export_settings" OWNER TO "troll";
