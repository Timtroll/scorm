DROP SEQUENCE IF EXISTS "public".settings_id_seq; 
CREATE SEQUENCE "public".settings_id_seq;

CREATE TABLE "public"."settings" (
"id" int4 DEFAULT nextval('settings_id_seq'::regclass) NOT NULL,
"parent" int4,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"value" text COLLATE "default",
"type" varchar(255) COLLATE "default",
"placeholder" varchar(255) COLLATE "default",
"mask" varchar(255) COLLATE "default",
"selected" text COLLATE "default",
"required" int4 DEFAULT 1,
"readOnly" int4 DEFAULT 0,
"editable" int4 DEFAULT 1,
"removable" int4 DEFAULT 1
)
WITH (OIDS=FALSE)
;

ALTER TABLE "public"."settings" OWNER TO "troll";