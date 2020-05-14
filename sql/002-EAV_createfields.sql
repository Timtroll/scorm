DO $$
BEGIN
    PERFORM eav_createfield( 'user', 'city', 'город', 'string', NULL );
    PERFORM eav_createfield( 'user', 'country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'user', 'birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'user', 'phone', 'номер телефона', 'string', NULL );
    PERFORM eav_createfield( 'user', 'avatar', 'фото', 'string', NULL );
    PERFORM eav_createfield( 'user', 'groups', 'список ID групп', 'string', NULL );
    PERFORM eav_createfield( 'user', 'patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'user', 'name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'user', 'emailconfirmed', 'email подтвержден', 'string', NULL );
    PERFORM eav_createfield( 'user', 'users_id', 'Id users пользователя', 'int', NULL );
    PERFORM eav_createfield( 'user', 'status', 'активный/неактивный', 'boolean', NULL );
    PERFORM eav_createfield( 'user', 'phoneconfirmed', 'телефон подтвержден', 'boolean', NULL );
    PERFORM eav_createfield( 'user', 'surname', 'Фамилия', 'string', NULL );
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
) VALUES (TRUE, 0, 'user', NOW(), 'user_root', 0, 0);