DO $$
BEGIN
    PERFORM eav_createfield( 'User', 'City', 'город', 'string', NULL );
    PERFORM eav_createfield( 'User', 'Country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'User', 'Birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'User', 'Phone', 'номер телефона', 'string', NULL );
    PERFORM eav_createfield( 'User', 'Patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'User', 'Name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'User', 'Surname', 'Фамилия', 'string', NULL );
END;
$$;


/* Insert start data */

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    import_type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'User', NOW(), 'User_root', 0, 0);

INSERT INTO "public"."EAV_links" (
    parent,
    id,
    distance
) VALUES (0, 1, 0);