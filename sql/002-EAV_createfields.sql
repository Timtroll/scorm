DO $$
BEGIN
    PERFORM eav_createfield( 'User', 'place', 'адрес', 'string', NULL );
    PERFORM eav_createfield( 'User', 'country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'User', 'birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'User', 'patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'User', 'name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'User', 'surname', 'Фамилия', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'label', 'Описание для отображения', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'description', 'Краткое содержание', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'content', 'Полное содержание', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'attachment', 'ID файлов', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'keywords', 'ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'url', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'seo', 'поле для seo', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'status', 'Статус поля', 'string', NULL );
    -- PERFORM eav_createfield( 'Default', 'folder', 'Признак категории', 'boolean', NULL );
END;
$$;


/* Insert start data */

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
    -- has_childs,
    -- folder
-- ) VALUES (TRUE, 0, 'User', NOW(), 'user_root', 0, 0, TRUE);
) VALUES (TRUE, 0, 'User', NOW(), 'user_root', 0, 0 );

INSERT INTO "public"."EAV_links" (
    parent,
    id,
    distance
) VALUES (0, 1, 0);