DO $$
BEGIN
    RAISE NOTICE '0002-EAV-aftermath.sql';
END;
$$;

BEGIN;

--создание динамических полей EAV-а.
DROP FUNCTION IF EXISTS "public"."EAV_CreateField"( FSet varchar(255), FAlias varchar(255), FTitle varchar(255), FType varchar(255), FDefault varchar(255) );
CREATE OR REPLACE FUNCTION EAV_CreateField( FSet varchar(255), FAlias varchar(255), FTitle varchar(255), FType varchar(255), FDefault varchar(255) ) RETURNS void AS $$
DECLARE
    FieldID integer;
BEGIN
    SELECT "id" INTO FieldID FROM "public"."EAV_fields" WHERE "alias" = FAlias AND "set" = FSet::"public"."subscriptions_object_type";

    IF ( FieldID IS NULL ) THEN
        INSERT INTO "public"."EAV_fields" ( "alias", "title", "type", "default_value", "set" ) VALUES ( FAlias, FTitle, FType::"public"."subscriptions_field_type", FDefault, FSet::"public"."subscriptions_object_type" );
    ELSE
        RAISE NOTICE 'EAV field ( %, % ) already exists - %', FSet, FAlias, FieldID;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    PERFORM EAV_CreateField( 'user', 'TreeAddress', 'Адрес пользователя в виртуальном дереве', 'string', NULL );
    --любые поля EAV-а, кроме импортируемых из других баз, должны быть здесь, в связи с чем..
    PERFORM EAV_CreateField( 'Default', 'GroupLeader', 'GroupLeader', 'boolean', NULL );
    PERFORM EAV_CreateField( 'subscription', 'type_subscription', 'Тип подписки', 'boolean', NULL );
END;
$$;

COMMIT;
