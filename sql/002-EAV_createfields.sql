DO $$
BEGIN
    PERFORM eav_createfield( 'User', 'place', 'адрес', 'string', NULL );
    PERFORM eav_createfield( 'User', 'country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'User', 'birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'User', 'patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'User', 'name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'User', 'surname', 'Фамилия', 'string', NULL );

    PERFORM eav_createfield( 'Discipline', 'annonce', 'Краткое содержание предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'content', 'Полное содержание предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'keywords', 'ключевые слова по предметам', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'alias', 'url страницы предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'seo', 'поле для seo предмета', 'string', NULL );

    PERFORM eav_createfield( 'Task', 'annonce', 'Краткое содержание', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'content', 'Полное содержание', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'keywords', 'ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'alias', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'seo', 'поле для seo', 'string', NULL );

    -- PERFORM eav_createfield( 'Default', 'folder', 'Признак категории', 'boolean', NULL );
END;
$$;


/* Insert Sets */

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'User', NOW(), 'user_root', 0, 0 );

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'Discipline', NOW(), 'learning_root', 0, 0 );

-----------
INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'Task', NOW(), 'task_root', 0, 0 );
