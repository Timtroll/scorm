# Типы полей ввода

| Component name | Статус | Дополнительные параметры | Описание |
|---|---|---|---|
| `InputText` | реализовано | | поле ввода Текст |
| `InputNumber` | реализовано | | поле ввода Число |
| `InputDateTime` | не реализовано | `date_time_format` - формат | поле ввода Даты и времени |
| `InputSelect` | реализовано | `multiple` - множественный выбор | поле ввода Select |
| `InputTextarea` | реализовано | | поле ввода Многострочный текст |
| `InputReachText` | не реализовано | | поле ввода Форматированный текст |
| `InputBoolean` | реализовано | | поле ввода Чекбокс |
| `InputRadio` | реализовано | | поле ввода Радио батоны |
| `InputList` | реализовано | | поле ввода Список значений с одним параметром |
| `InputDoubleList` | реализовано | | поле ввода Список типа ключ, значение |

## Общие параметры полей ввода

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `readonly` | Boolean | 1 | Запрещено редактирование поля
| `type` | String | "InputText" | Название используемого компонента
| `name` | String | "" | Системное название поля
| `label` | String | "" | Заголовок поля
| `placeholder` | String | "" | Плейсхолдер
| `mask` | String | "" | RegEx маска для валидации поля
| `value` | Any | "" | Значения поля
| `values` | Array | "" | Значения для выбора

## Дополнительные параметры полей ввода

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `multiple` | Boolean | 0 | Разрешен множественный выбор
