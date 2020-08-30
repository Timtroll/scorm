CREATE SEQUENCE universal_links_types_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE "public"."universal_links" (
    "a_link_id" int4 NOT NULL,
    "a_link_type" int4 NOT NULL,
    "b_link_id" int4 NOT NULL,
    "b_link_type" int4 NOT NULL,
    "owner_id" int4,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "univeral_links_pkey" PRIMARY KEY ("a_link_id", "a_link_type", "b_link_id", "b_link_type")
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."universal_links" OWNER TO "troll";
ALTER SEQUENCE "universal_links" RESTART WITH 1;


CREATE TABLE "public"."universal_links_types" (
    "id" int4 DEFAULT nextval('universal_links_types_seq'::regclass) NOT NULL,
    "alias" varchar(255) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    CONSTRAINT "universal_links_types_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."universal_links_types" OWNER TO "troll";
ALTER SEQUENCE "universal_links_types_pkey" RESTART WITH 1;


CREATE INDEX "a" ON "public"."universal_links" USING btree ("a_link_id", "a_link_type");

CREATE INDEX "ao" ON "public"."universal_links" USING btree ("a_link_id", "a_link_type", "owner_id");

CREATE INDEX "b" ON "public"."universal_links" USING btree ("b_link_id", "b_link_type");

CREATE INDEX "bo" ON "public"."universal_links" USING btree ("b_link_id", "b_link_type", "owner_id");

CREATE INDEX "ota" ON "public"."universal_links" USING btree ("a_link_type", "owner_id");

CREATE INDEX "otb" ON "public"."universal_links" USING btree ("b_link_type", "owner_id");

/* Insert start data */

INSERT INTO "public"."universal_links_types" (alias, title) VALUES('Avatar', 'Аватар');
INSERT INTO "public"."universal_links_types" (alias, title) VALUES('EmailConfirmed', 'EmailConfirmed');
INSERT INTO "public"."universal_links_types" (alias, title) VALUES('PhoneConfirmed', 'PhoneConfirmed');