DROP TABLE IF EXISTS "public"."routes";
DROP SEQUENCE IF EXISTS "public".routes_id_seq; 
CREATE SEQUENCE "public".routes_id_seq;

CREATE TABLE "public"."routes" (
"id" int4 DEFAULT nextval('routes_id_seq'::regclass) NOT NULL,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"value" json NOT NULL,
"required" int4 DEFAULT 0,
"readOnly" int4 DEFAULT 0,
"editable" int4 DEFAULT 0,
"removable" int4 DEFAULT 0
)
WITH (OIDS=FALSE)
;

ALTER TABLE "public"."routes" OWNER TO "otrs";


CREATE UNIQUE INDEX "routes_label_name_idx" ON "public"."routes" USING btree ("label", "name");