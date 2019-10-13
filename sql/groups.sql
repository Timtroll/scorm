DROP TABLE IF EXISTS "public"."groups";

DROP SEQUENCE IF EXISTS "public".groups_id_seq; 
CREATE SEQUENCE "public".groups_id_seq;

CREATE TABLE "public"."groups" (
"id" int4 DEFAULT nextval('groups_id_seq'::regclass) NOT NULL,
"label" varchar(255) COLLATE "default" NOT NULL,
"name" varchar(255) COLLATE "default" NOT NULL,
"status" int4 DEFAULT 1
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."groups" OWNER TO "troll";

CREATE UNIQUE INDEX "groups_name_idx" ON "public"."groups" USING btree ("name");