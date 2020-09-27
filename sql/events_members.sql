CREATE TABLE "public"."events_members" (
    "event_id" int8 NOT NULL,
    "users_id" int4 NOT NULL,
    "role" bit(5) NOT NULL, -- роль в событии
    "confirmed" boolean DEFAULT false NOT NULL -- роль в событии
)
WITH (OIDS=FALSE);
ALTER TABLE "public"."events_members" OWNER TO "troll";