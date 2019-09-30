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
"readonly" int4 DEFAULT 0,
"removable" int4 DEFAULT 1,
"status" int2 DEFAULT 1 NOT NULL
)
WITH (OIDS=FALSE)
;

ALTER TABLE "public"."settings" OWNER TO "troll";