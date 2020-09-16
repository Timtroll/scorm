DO $$
BEGIN
    PERFORM eav_createfield( 'User', 'place', 'адрес', 'string', NULL );
    PERFORM eav_createfield( 'User', 'country', 'страна', 'string', NULL );
    PERFORM eav_createfield( 'User', 'birthday', 'дата рождения', 'datetime', NULL );
    PERFORM eav_createfield( 'User', 'patronymic', 'Отчество', 'string', NULL );
    PERFORM eav_createfield( 'User', 'name', 'Имя', 'string', NULL );
    PERFORM eav_createfield( 'User', 'surname', 'Фамилия', 'string', NULL );

    PERFORM eav_createfield( 'Discipline', 'label', 'Описание для отображения предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'description', 'Краткое содержание предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'content', 'Полное содержание предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'keywords', 'ключевые слова по предметам', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'alias', 'url страницы предмета', 'string', NULL );
    PERFORM eav_createfield( 'Discipline', 'seo', 'поле для seo предмета', 'string', NULL );

    PERFORM eav_createfield( 'Course', 'label', 'Описание для отображения курса', 'string', NULL );
    PERFORM eav_createfield( 'Course', 'description', 'Краткое содержание курса', 'string', NULL );
    PERFORM eav_createfield( 'Course', 'content', 'Полное содержание курса', 'string', NULL );
    PERFORM eav_createfield( 'Course', 'keywords', 'ключевые слова курса', 'string', NULL );
    PERFORM eav_createfield( 'Course', 'alias', 'url страницы курса', 'string', NULL );
    PERFORM eav_createfield( 'Course', 'seo', 'поле для seo курса', 'string', NULL );

    PERFORM eav_createfield( 'Theme', 'label', 'Описание для отображения темы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'description', 'Краткое содержание темы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'content', 'Полное содержание темы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'keywords', 'ключевые слова темы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'alias', 'url страницы темы', 'string', NULL );
    PERFORM eav_createfield( 'Theme', 'seo', 'поле для seo темы', 'string', NULL );

    PERFORM eav_createfield( 'Lesson', 'label', 'Описание для отображения', 'string', NULL );
    PERFORM eav_createfield( 'Lesson', 'description', 'Краткое содержание', 'string', NULL );
    PERFORM eav_createfield( 'Lesson', 'content', 'Полное содержание', 'string', NULL );
    PERFORM eav_createfield( 'Lesson', 'keywords', 'ключевые слова', 'string', NULL );
    PERFORM eav_createfield( 'Lesson', 'alias', 'url страницы', 'string', NULL );
    PERFORM eav_createfield( 'Lesson', 'seo', 'поле для seo', 'string', NULL );

    PERFORM eav_createfield( 'Task', 'label', 'Описание для отображения', 'string', NULL );
    PERFORM eav_createfield( 'Task', 'description', 'Краткое содержание', 'string', NULL );
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
