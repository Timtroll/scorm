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

    PERFORM eav_createfield( 'Theme', 'label', 'Описание для отображения', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'description', 'Краткое содержание', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'content', 'Полное содержание', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'attachment', 'ID файлов', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'keywords', 'ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'url', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'seo', 'поле для seo', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'status', 'Статус поля', 'string', NULL );

    -- PERFORM eav_createfield( 'Lesson', 'label', 'Описание для отображения', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'description', 'Краткое содержание', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'content', 'Полное содержание', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'attachment', 'ID файлов', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'keywords', 'ключевые слова', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'url', 'url страницы', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'seo', 'поле для seo', 'string', NULL );
    -- PERFORM eav_createfield( 'Lesson', 'status', 'Статус поля', 'string', NULL );

    -- PERFORM eav_createfield( 'Task', 'label', 'Описание для отображения', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'description', 'Краткое содержание', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'content', 'Полное содержание', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'attachment', 'ID файлов', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'keywords', 'ключевые слова', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'url', 'url страницы', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'seo', 'поле для seo', 'string', NULL );
    -- PERFORM eav_createfield( 'Task', 'status', 'Статус поля', 'string', NULL );

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

-----------
INSERT INTO "public"."EAV_items" (
        publish,
        import_id,
        type,
        date_created,
        title,
        parent,
        has_childs
) VALUES (TRUE, 0, 'Discipline', NOW(), 'discipline_root', 0, 0 );

-----------
INSERT INTO "public"."EAV_items" (
        publish,
        import_id,
        type,
        date_created,
        title,
        parent,
        has_childs
) VALUES (TRUE, 0, 'Theme', NOW(), 'theme_root', 0, 0 );

-----------
-- INSERT INTO "public"."EAV_items" (
--         publish,
--         import_id,
--         type,
--         date_created,
--         title,
--         parent,
--         has_childs
-- ) VALUES (TRUE, 0, 'Lesson', NOW(), 'lesson_root', 0, 0 );

-- ---------
-- INSERT INTO "public"."EAV_items" (
--         publish,
--         import_id,
--         type,
--         date_created,
--         title,
--         parent,
--         has_childs
-- ) VALUES (TRUE, 0, 'Task', NOW(), 'task_root', 0, 0 );

