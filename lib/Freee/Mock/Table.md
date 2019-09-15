# Table 

 [JSON таблицы](Table.json)
### Структура данных
```
{
  "settings": {},
  "header":   [],
  "body":     []
}
```
| Ключ | Тип | Описание | 
|---|---|---|
| settings | Object | Настройки таблицы |
| header | Array | Шапка таблицы |
| header | Array | Содержимое таблицы |

## SETTINGS - Настройки таблицы 
```
"settings": {
  "editable":  1,
  "lib_id":    101,
  "variableType":  0,
  "sort":      {
    "name":  "id",
    "order": "asc"
  },
  "page":      {
    "current_page": 2,
    "per_page":     15,
    "total":        50
  }
},
```

| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| editable | Number | Таблица доступна для редактирования | 1 |
| lib_id | Number | ID Родителя | - |
| variableType | Number/String | Название ключа поля, в котором, можно менять тип поля | 0 |
| sort | Object | Настройки сортировки | - |
| sort.name | String | Имя поля для сортировки | id |
| sort.order | String | Направление сортировки `asc`, `desc` | asc |
| page | Object | Настройки пагинации | - |
| page.current_page | Number | Текущая страница | - |
| page.per_page | Number | Количество элементов на странице | - |
| page.total | Number | Всего элементов | - |

## HEADER - Шапка таблицы 
```
"header":   [
  {
    "key":         "number",
    "label":       "Число",
    "editable":    0,
    "required":    1,
    "show":        1,
    "inline":      0
  },
  ***
},
```
| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| key | String | Ключ поля | - |
| label | String | Расшивровка поля | - |
| editable | Number | Разрешено редактирование полей колонки | 1 |
| required | Number | Поля колонки обязательны для заполнения | 0 |
| show | Number | Показать колонку в таблице | 1 |
| inline | Number | Разрешено инлайн редактирование колонки (только InputBoolean) | 0 |

## BODY - Контент таблицы 
```
"body":     [
  {
    "id":   1011,
    "data": [
      {
        "name":        "fullDebugMode",
        "label":       "Число",
        "placeholder": "Number",
        "mask":        "[0..9\\w ]+",
        "type":        "InputNumber",
        "value":       "",
        "selected":    []
      }
    ]
  }
]
```
| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| id | Number | ID строки | - |
| data | Array | Список ячеек строки | - |
| data.name | String | Ключ поля | - |
| data.placeholder | String | Текст в placeholder поля  | - |
| data.mask | RegExp | RegExp для поля | - |
| data.value | -- | Значение поля | - |
| data.type | String | Тип поля учитывается если `header.variable = 1` | InputText |
| data.selected | Array | Список значений для поля (только InputSelect). Имеет больший приоритет, чем `header.selected` | - |

# ЗАПРОСЫ

1. `*/*_set` - Получить таблицу
2. `*/*_set_proto` - Получить прототип строки
3. `*/*_add` - Добавить строку таблицы
4. `*/*_save` - Сохранить строку таблицы
5. `*/*_save_mass` - Сохранить значение поля у нескольких строк таблицы 
6. `*/*_delete` - Удалить строку таблицы
