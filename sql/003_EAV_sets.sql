CREATE TABLE "public"."EAV_sets" (
    "alias" varchar(255) COLLATE "default" NOT NULL,
    "title" varchar(255) COLLATE "default" NOT NULL,
    CONSTRAINT "EAV_sets_pkey" PRIMARY KEY ("alias"),
    CONSTRAINT "unique_field" UNIQUE ("alias", "title")
)
WITH (OIDS=FALSE);

ALTER TABLE ONLY "public"."EAV_sets_string"
    ADD CONSTRAINT "EAV_sets_string_pkey" PRIMARY KEY (id, field_id);

ALTER TABLE ONLY "public"."EAV_sets_string"
    ADD CONSTRAINT "EAV_sets_string_pkey" PRIMARY KEY (id, field_id);

CREATE INDEX "EAV_sets_boolean_field_id_data_idx" ON "public"."EAV_sets_boolean" USING btree (field_id, data);

CREATE INDEX "EAV_sets_datetime_field_id_data_idx" ON "public"."EAV_sets_datetime" USING btree (field_id, data);
