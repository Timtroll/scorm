DO $$
BEGIN
    PERFORM eav_createfield( 'Default', 'alias', 'url объекта', 'string', NULL );
    PERFORM eav_createfield( 'Default', 'announce', 'Краткое содержание', 'string', NULL );
    PERFORM eav_createfield( 'Default', 'description', 'Полное описание', 'string', NULL );

    PERFORM eav_createfield( 'User', 'place', 'адрес', 'string', NULL );
    PERFORM eav_createfield( 'User', 'country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'User', 'birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'User', 'patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'User', 'name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'User', 'surname', 'Фамилия', 'string', NULL );

    PERFORM eav_createfield( 'Learning', 'is_lesson', 'Признак урока', 'boolean', NULL );

    PERFORM eav_createfield( 'Discipline', 'name', 'Название', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'label', 'Описание', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'content', 'Содержание', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'keywords', 'Ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'seo', 'seo', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'url', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'attachment', 'Вложенные файлы', 'string', NULL );

    PERFORM eav_createfield( 'Theme', 'name', 'Название', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'label', 'Описание', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'content', 'Содержание', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'keywords', 'Ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'seo', 'seo', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'url', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'attachment', 'Вложенные файлы', 'string', NULL );

    PERFORM eav_createfield( 'Task', 'name', 'Название', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'label', 'Описание', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'content', 'Содержание', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'keywords', 'Ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'attachment', 'Вложенные файлы', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'description', 'Описание', 'string', NULL );

    PERFORM eav_createfield( 'SEO', 'keywords', 'Ключевые слова, фразы', 'string', NULL );
    PERFORM eav_createfield( 'SEO', 'description', 'Описание', 'string', NULL );
    PERFORM eav_createfield( 'SEO', 'seo_title', 'SEO заголовок', 'string', NULL );

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
) VALUES (TRUE, 0, 'Learning', NOW(), 'learning_root', 0, 0 );

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'Discipline', NOW(), 'discipline_root', 0, 0 );

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'Theme', NOW(), 'theme_root', 0, 0 );

INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'Task', NOW(), 'task_root', 0, 0 );
-----------
INSERT INTO "public"."EAV_items" (
    publish,
    import_id,
    type,
    date_created,
    title,
    parent,
    has_childs
) VALUES (TRUE, 0, 'SEO', NOW(), 'seo_root', 0, 0 );
