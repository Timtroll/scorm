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
    "massEdit":  1,
    "sort":      {
      "name":  "id",
      "order": "asc"
    },
    "page":      {
      "current_page": 2,
      "per_page":     15,
      "from":         16,
      "to":           30,
      "total":        50,
      "last_page":    4
    }
  },
```

| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| editable | Number | Таблица доступна для редактирования | 1 |
| lib_id | Number | ID Родителя | - |
| massEdit | Number | Доступно массовое редактирование | 0 |
| sort | Object | Настройки сортировки | - |
| sort.name | String | Имя поля для сортировки | id |
| sort.order | String | Направление сортировки `asc`, `desc` | asc |
| page | Object | Настройки пагинации | - |
| page.current_page | Number | Текущая страница | - |
| page.per_page | Number | Количество элементов на странице | - |
| page.from | Number | Текущая страница - первый элемент | - |
| page.to | Number | Текущая страница - последний элемент | - |
| page.total | Number | Всего элементов | - |
| page.last_page | Number | Последняя страница | - |

## HEADER - Шапка таблицы 
```
 "header":   [
    {
      "key":         "number",
      "label":       "Число",
      "placeholder": "Number",
      "type":        "InputNumber",
      "mask":        "[0..9\\w ]+",
      "variable":    0,
      "editable":    0,
      "required":    1,
      "show":        1,
      "inline":      0,
      "selected":    []
    },
    ***
  },
```
| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| key | String | Ключ поля | - |
| label | String | Расшивровка поля | - |
| placeholder | String | Название placeholder в поле | - |
| type | String | Тип поля ввода | - |
| mask | RegExp | RegExp для поля | - |
| variable | Number | Тип пося может меняться | 0 |
| editable | Number | Разрешено редактирование полей колонки | 1 |
| required | Number | Поля колонки обязательны для заполнения | 0 |
| show | Number | Показать колонку в таблице | 1 |
| inline | Number | Разрешено инлайн редактирование колонки (только InputBoolean) | 0 |
| selected | Array | Глобальный список значений для всех полей колонки (только InputSelect) | - |

## BODY - Шапка таблицы 
```
 "body":     [
    {
      "id":   1011,
      "data": [
        {
          "name":     "fullDebugMode",
          "value":    "",
          "type":     "InputNumber",
          "selected": []
        }
      ]
    },
    ***
  ]
```
| Ключ | Тип | Описание | Значение по умолчанию |
|---|---|---|---|
| id | Number | ID строки | - |
| data | Array | Список ячеек строки | - |
| data.name | String | Ключ поля | - |
| data.value | -- | Значение поля | - |
| data.type | String | Тип поля учитывается если `header.variable = 1` | InputText |
| data.selected | Array | Список значений для поля (только InputSelect). Имеет больший приоритет, чем `header.selected` | - |
