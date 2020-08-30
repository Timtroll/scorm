-- связь юзеров и групп 
CREATE TABLE "public"."user_groups" (
"user_id" int4 DEFAULT 0 NOT NULL,
"group_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_groups_pkey" PRIMARY KEY ("user_id", "group_id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_groups" OWNER TO "troll";
ALTER SEQUENCE "user_groups_pkey" RESTART WITH 1;
