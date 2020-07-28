CREATE TABLE "public"."EAV_sets" (
    "alias" varchar(255) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default" NOT NULL,
    CONSTRAINT "EAV_sets_pkey" PRIMARY KEY ("alias")
)
WITH (OIDS=FALSE);