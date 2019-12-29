DO $$
BEGIN
    RAISE NOTICE '0001-EAV-fixes.sql';
END;
$$;

DROP FUNCTION IF EXISTS "public"."_is_column_exists"( _Schema varchar(255), _Table varchar(255), _Field varchar(255) );
CREATE OR REPLACE FUNCTION _is_column_exists( _Schema varchar(255), _Table varchar(255), _Field varchar(255) ) RETURNS boolean AS $$
DECLARE
    Result boolean;
BEGIN
    SELECT EXISTS( SELECT 1 FROM "information_schema"."columns" WHERE "table_schema" = _Schema AND "table_name" = _Table AND "column_name" = _Field ) INTO Result;
    RETURN Result;
END;
$$ LANGUAGE plpgsql;