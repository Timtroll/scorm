/*
Source Server         : freee.su
Source Server Version : 90614
Source Host           : localhost:5432
Source Database       : scorm
Source Schema         : public

Target Server Type    : PGSQL
Target Server Version : 90500
File Encoding         : 65001

Date: 2019-08-02 00:21:41
*/


-- ----------------------------
-- Type structure for "EAV_field_type"
-- ----------------------------
DROP TYPE IF EXISTS "EAV_field_type";
CREATE TYPE "public"."EAV_field_type" AS ENUM ('blob', 'boolean', 'int', 'string', 'datetime');;

-- ----------------------------
-- Type structure for "EAV_object_type"
-- ----------------------------
DROP TYPE IF EXISTS "EAV_object_type";
CREATE TYPE "public"."EAV_object_type" AS ENUM ('user', 'lesson');;

-- ----------------------------
-- Table structure for EAV_data_boolean
-- ----------------------------
DROP TABLE IF EXISTS "EAV_data_boolean";
CREATE TABLE "EAV_data_boolean" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" bool
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_data_boolean
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_data_datetime
-- ----------------------------
DROP TABLE IF EXISTS "EAV_data_datetime";
CREATE TABLE "EAV_data_datetime" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" timestamp(6)
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_data_datetime
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_data_int4
-- ----------------------------
DROP TABLE IF EXISTS "EAV_data_int4";
CREATE TABLE "EAV_data_int4" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" int4
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_data_int4
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_data_string
-- ----------------------------
DROP TABLE IF EXISTS "EAV_data_string";
CREATE TABLE "EAV_data_string" (
"id" int4 DEFAULT 0 NOT NULL,
"field_id" int4 DEFAULT 0 NOT NULL,
"data" varchar(255) COLLATE "default"
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_data_string
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_fields
-- ----------------------------
DROP TABLE IF EXISTS "EAV_fields";
CREATE TABLE "EAV_fields" (
-- "id" int4 DEFAULT 0 NOT NULL,
-- "alias" varchar(255) COLLATE "default" NOT NULL,
-- "title" varchar(255) COLLATE "default" NOT NULL,
-- "type" "EAV_field_type" DEFAULT 'blob'::"EAV_field_type",
-- "default_value" varchar(255) COLLATE "default",
-- "set" "EAV_object_type"
"id" int4 NOT NULL,
"alias" varchar(255) COLLATE "default" NOT NULL,
"title" varchar(255) COLLATE "default" NOT NULL,
"type" "EAV_field_type" DEFAULT 'blob'::"EAV_field_type",
"default_value" varchar(255) COLLATE "default",
"set" "EAV_object_type",
PRIMARY KEY(id)
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_fields
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_links
-- ----------------------------
DROP TABLE IF EXISTS "EAV_links";
CREATE TABLE "EAV_links" (
"parent" int4 DEFAULT 0 NOT NULL,
"id" int4 DEFAULT 0 NOT NULL,
"distance" int4 DEFAULT 0 NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_links
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_sets
-- ----------------------------
DROP TABLE IF EXISTS "EAV_sets";
CREATE TABLE "EAV_sets" (
"id" int4 DEFAULT 0 NOT NULL,
"alias" varchar(255) COLLATE "default" NOT NULL,
"title" varchar(255) COLLATE "default" NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_sets
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for EAV_submodules_subscriptions
-- ----------------------------
DROP TABLE IF EXISTS "EAV_submodules_subscriptions";
CREATE TABLE "EAV_submodules_subscriptions" (
"owner_id" int4 NOT NULL,
"sla_id" int4 NOT NULL,
"service_id" int4 NOT NULL,
"subscription_id" int4 DEFAULT 0 NOT NULL,
"distance" int2 DEFAULT 0 NOT NULL
)
WITH (OIDS=FALSE);

-- ----------------------------
-- Records of EAV_submodules_subscriptions
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Alter Sequences Owned By 
-- ----------------------------

-- ----------------------------
-- Indexes structure for table EAV_data_boolean
-- ----------------------------
CREATE INDEX "EAV_data_boolean_field_id_data_idx" ON "EAV_data_boolean" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_boolean_id_field_id_data_idx" ON "EAV_data_boolean" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_boolean_id_field_id_idx" ON "EAV_data_boolean" USING btree ("id", "field_id");

-- ----------------------------
-- Primary Key structure for table EAV_data_boolean
-- ----------------------------
ALTER TABLE "EAV_data_boolean" ADD PRIMARY KEY ("id", "field_id");

-- ----------------------------
-- Indexes structure for table EAV_data_datetime
-- ----------------------------
CREATE INDEX "EAV_data_datetime_field_id_data_idx" ON "EAV_data_datetime" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_datetime_id_field_id_data_idx" ON "EAV_data_datetime" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_datetime_id_field_id_idx" ON "EAV_data_datetime" USING btree ("id", "field_id");

-- ----------------------------
-- Primary Key structure for table EAV_data_datetime
-- ----------------------------
ALTER TABLE "EAV_data_datetime" ADD PRIMARY KEY ("id", "field_id");

-- ----------------------------
-- Indexes structure for table EAV_data_int4
-- ----------------------------
CREATE INDEX "EAV_data_int4_field_id_data_idx" ON "EAV_data_int4" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_int4_id_field_id_data_idx" ON "EAV_data_int4" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_int4_id_field_id_idx" ON "EAV_data_int4" USING btree ("id", "field_id");

-- ----------------------------
-- Primary Key structure for table EAV_data_int4
-- ----------------------------
ALTER TABLE "EAV_data_int4" ADD PRIMARY KEY ("id", "field_id");

-- ----------------------------
-- Indexes structure for table EAV_data_string
-- ----------------------------
CREATE INDEX "EAV_data_string_field_id_data_idx" ON "EAV_data_string" USING btree ("field_id", "data");
CREATE INDEX "EAV_data_string_id_field_id_data_idx" ON "EAV_data_string" USING btree ("id", "field_id", "data");
CREATE INDEX "EAV_data_string_id_field_id_idx" ON "EAV_data_string" USING btree ("id", "field_id");

-- ----------------------------
-- Primary Key structure for table EAV_data_string
-- ----------------------------
ALTER TABLE "EAV_data_string" ADD PRIMARY KEY ("id", "field_id");

-- ----------------------------
-- Primary Key structure for table EAV_fields
-- ----------------------------
ALTER TABLE "EAV_fields" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table EAV_links
-- ----------------------------
CREATE INDEX "EAV_links_id_distance_idx" ON "EAV_links" USING btree ("id", "distance");
CREATE INDEX "EAV_links_id_idx" ON "EAV_links" USING btree ("id");
CREATE INDEX "EAV_links_parent_distance_idx" ON "EAV_links" USING btree ("parent", "distance");
CREATE INDEX "EAV_links_parent_idx" ON "EAV_links" USING btree ("parent");

-- ----------------------------
-- Triggers structure for table EAV_links
-- ----------------------------
CREATE TRIGGER "EAV_links_trigger_ai" AFTER INSERT ON "EAV_links"
FOR EACH ROW
EXECUTE PROCEDURE "EAV_links_trigger_ai"();

-- ----------------------------
-- Primary Key structure for table EAV_links
-- ----------------------------
ALTER TABLE "EAV_links" ADD PRIMARY KEY ("parent", "id");

-- ----------------------------
-- Primary Key structure for table EAV_sets
-- ----------------------------
ALTER TABLE "EAV_sets" ADD PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table EAV_submodules_subscriptions
-- ----------------------------
CREATE INDEX "EAV_submodules_subscriptions_owner_id_distance_idx" ON "EAV_submodules_subscriptions" USING btree ("owner_id", "distance");
CREATE INDEX "EAV_submodules_subscriptions_owner_id_idx" ON "EAV_submodules_subscriptions" USING btree ("owner_id");
CREATE INDEX "EAV_submodules_subscriptions_service_id_distance_idx" ON "EAV_submodules_subscriptions" USING btree ("service_id", "distance");
CREATE INDEX "EAV_submodules_subscriptions_service_id_idx" ON "EAV_submodules_subscriptions" USING btree ("service_id");
CREATE INDEX "EAV_submodules_subscriptions_sla_id_distance_idx" ON "EAV_submodules_subscriptions" USING btree ("sla_id", "distance");
CREATE INDEX "EAV_submodules_subscriptions_sla_id_idx" ON "EAV_submodules_subscriptions" USING btree ("sla_id");
CREATE INDEX "EAV_submodules_subscriptions_subscription_id_distance_idx" ON "EAV_submodules_subscriptions" USING btree ("subscription_id", "distance");
CREATE INDEX "EAV_submodules_subscriptions_subscription_id_idx" ON "EAV_submodules_subscriptions" USING btree ("subscription_id");

-- ----------------------------
-- Primary Key structure for table EAV_submodules_subscriptions
-- ----------------------------
ALTER TABLE "EAV_submodules_subscriptions" ADD PRIMARY KEY ("owner_id", "sla_id", "service_id");
