DROP TABLE IF EXISTS "public"."routes";
DROP SEQUENCE IF EXISTS "public".routes_id_seq; 
CREATE SEQUENCE "public".routes_id_seq;

CREATE TABLE "public"."routes" (
"id" int4 DEFAULT nextval('routes_id_seq'::regclass) NOT NULL,
"parent" int4,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"value" json,
"status" int2 DEFAULT 1 NOT NULL
)
WITH (OIDS=FALSE)
;

ALTER TABLE "public"."routes" OWNER TO "troll";


CREATE UNIQUE INDEX "routes_label_name_idx" ON "public"."routes" USING btree ("label", "name");
