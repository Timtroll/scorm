CREATE SEQUENCE media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
;
ALTER SEQUENCE "media_id_seq" RESTART WITH 1;

CREATE TABLE "public"."media" (
    "id" int4 DEFAULT nextval('media_id_seq'::regclass) NOT NULL,
    "path" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "filename" varchar(48) COLLATE "default" NOT NULL,
    "extension" varchar(5) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default",
    "size" int4,
    "type" varchar(32) COLLATE "default",
    "mime" varchar(255) COLLATE "default",
    "description" varchar(4096) COLLATE "default",
    "order" int4 DEFAULT 0,
    "flags" int8,
    CONSTRAINT "media_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."media" OWNER TO "troll";

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
