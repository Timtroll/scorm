-- -- ----------------------------
-- -- Table structure for groups
-- -- ----------------------------
-- DROP TABLE IF EXISTS "public"."groups";
-- CREATE TABLE "public"."groups" (
--     "id" int4 DEFAULT nextval('groups_id_seq'::regclass) NOT NULL,
--     "label" varchar(255) COLLATE "default" NOT NULL,
--     "name" varchar(255) COLLATE "default" NOT NULL,
--     "status" int2 DEFAULT 1 NOT NULL
-- )
-- WITH (OIDS=FALSE)

-- ;

-- -- ----------------------------
-- -- Records of groups
-- -- ----------------------------
-- INSERT INTO "public"."groups" VALUES ('1', 'Администратор', 'admin', '1');
-- INSERT INTO "public"."groups" VALUES ('2', 'Студенты', 'students', '1');
-- INSERT INTO "public"."groups" VALUES ('3', 'Ректоры', 'rectors', '1');
-- INSERT INTO "public"."groups" VALUES ('4', 'Менеджеры', 'managers', '1');

-- -- ----------------------------
-- -- Alter Sequences Owned By 
-- -- ----------------------------

-- -- ----------------------------
-- -- Indexes structure for table groups
-- -- ----------------------------
-- CREATE UNIQUE INDEX "groups_name_idx" ON "public"."groups" USING btree ("name");

-- -- ----------------------------
-- -- Triggers structure for table groups
-- -- ----------------------------
-- CREATE TRIGGER "groups_ad" AFTER DELETE ON "public"."groups"
-- FOR EACH ROW
-- EXECUTE PROCEDURE "groups_trigger_ad"();

-- -- ----------------------------
-- -- Uniques structure for table groups
-- -- ----------------------------
-- ALTER TABLE "public"."groups" ADD UNIQUE ("name");

-- -- ----------------------------
-- -- Primary Key structure for table groups
-- -- ----------------------------
-- ALTER TABLE "public"."groups" ADD PRIMARY KEY ("id");
