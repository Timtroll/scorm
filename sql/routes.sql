DROP TABLE IF EXISTS "public"."routes";

DROP SEQUENCE IF EXISTS "public".routes_id_seq; 
CREATE SEQUENCE "public".routes_id_seq;
-- ALTER SEQUENCE "routes_id_seq" RESTART WITH 1;

CREATE TABLE "public"."routes" (
"id" int4 DEFAULT nextval('routes_id_seq'::regclass) NOT NULL,
"parent" int4,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"list" int2 DEFAULT 1 NOT NULL,
"add" int2 DEFAULT 1 NOT NULL,
"edit" int2 DEFAULT 1 NOT NULL,
"delete" int2 DEFAULT 1 NOT NULL,
"status" int2 DEFAULT 1 NOT NULL
)
WITH (OIDS=FALSE);

--CREATE UNIQUE INDEX "routes_label_name_idx" ON "public"."routes" USING btree ("label", "name");
-- ALTER TABLE "public"."routes" OWNER TO "troll";