package Freee::Mock::GetLeafs;

use utf8;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $get_leafs );


our @ISA = qw( Exporter );
our @EXPORT = qw( $get_leafs);
our @EXPORT_OK = qw( $get_leafs );
our $pref;

$get_leafs = {
  "settings"=> {
    "editable"=> 1,
    "parent"=> 10,
    "variableType"=> 0,
    "massEdit"=> 1,
    "sort"=> {
      "name"=> "id",
      "order"=> "asc"
    },
    "page"=> {
      "current_page"=> 1,
      "per_page"=> 10,
      "total"=> 12
    }
  },
  "header"=> [
    {
      "key"=> "number",
      "label"=> "Число",
      "editable"=> 0,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "text",
      "label"=> "Текстовое поле",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "textarea",
      "label"=> "Текстовая область",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "editor",
      "label"=> "Текстовый редактор - CKEditor",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "codeEditor",
      "label"=> "Редактор кода",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "boolean",
      "label"=> "Чекбокс",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 1
    },
    {
      "key"=> "radio",
      "label"=> "Радио кнопки",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "select",
      "label"=> "Выпадающий список",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    },
    {
      "key"=> "list",
      "label"=> "Массив значений",
      "editable"=> 1,
      "required"=> 1,
      "show"=> 1,
      "inline"=> 0
    }
  ],
  "body"=> [
    {
      "id"=> 100,
      "data"=> [
        {
          "name"=> "number",
          "label"=> "Число",
          "placeholder"=> "Number",
          "mask"=> "[0..9\\w ]+",
          "type"=> "InputNumber",
          "value"=> 556.4,
          "selected"=> []
        },
        {
          "name"=> "text",
          "label"=> "Текстовое поле",
          "placeholder"=> "text",
          "mask"=> "",
          "type"=> "InputText",
          "value"=> "Текстовое поле",
          "selected"=> []
        },
        {
          "name"=> "textarea",
          "label"=> "Текстовая область",
          "placeholder"=> "textarea",
          "mask"=> "",
          "type"=> "InputTextarea",
          "value"=> "Текстовая область",
          "selected"=> []
        },
        {
          "name"=> "editor",
          "label"=> "Текстовый редактор",
          "placeholder"=> "editor",
          "mask"=> "",
          "type"=> "InputCKEditor",
          "value"=> "Текстовый редактор - CKEditor",
          "selected"=> []
        },
        {
          "name"=> "codeEditor",
          "label"=> "Редактор кода",
          "placeholder"=> "codeEditor",
          "mask"=> "",
          "type"=> "InputCode",
          "value"=> "Редактор кода - ACE",
          "selected"=> []
        },
        {
          "name"=> "boolean",
          "label"=> "Чекбокс",
          "placeholder"=> "boolean",
          "mask"=> "[0..1\\w ]+",
          "type"=> "InputBoolean",
          "value"=> 1,
          "selected"=> []
        },
        {
          "name"=> "radio",
          "label"=> "Радио кнопки",
          "placeholder"=> "radio",
          "mask"=> "",
          "type"=> "InputRadio",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "select",
          "label"=> "Выпадающий список",
          "placeholder"=> "select",
          "mask"=> "",
          "type"=> "InputSelect",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "list",
          "label"=> "Массив значений",
          "placeholder"=> "list",
          "mask"=> "",
          "type"=> "InputDoubleList",
          "value"=> [["1", "Пн"], ["2", "Вт"], ["3", "Ср"]],
          "selected"=> []
        }
      ]
    },
    {
      "id"=> 101,
      "data"=> [
        {
          "name"=> "number",
          "label"=> "Число",
          "placeholder"=> "Number",
          "mask"=> "[0..9\\w ]+",
          "type"=> "InputNumber",
          "value"=> 65677.3,
          "selected"=> []
        },
        {
          "name"=> "text",
          "label"=> "Текстовое поле",
          "placeholder"=> "text",
          "mask"=> "",
          "type"=> "InputText",
          "value"=> "Текстовое поле",
          "selected"=> []
        },
        {
          "name"=> "textarea",
          "label"=> "Текстовая область",
          "placeholder"=> "textarea",
          "mask"=> "",
          "type"=> "InputTextarea",
          "value"=> "Текстовая область",
          "selected"=> []
        },
        {
          "name"=> "editor",
          "label"=> "Текстовый редактор",
          "placeholder"=> "editor",
          "mask"=> "",
          "type"=> "InputCKEditor",
          "value"=> "Текстовый редактор - CKEditor",
          "selected"=> []
        },
        {
          "name"=> "codeEditor",
          "label"=> "Редактор кода",
          "placeholder"=> "codeEditor",
          "mask"=> "",
          "type"=> "InputCode",
          "value"=> "Редактор кода - ACE",
          "selected"=> []
        },
        {
          "name"=> "boolean",
          "label"=> "Чекбокс",
          "placeholder"=> "boolean",
          "mask"=> "[0..1\\w ]+",
          "type"=> "InputBoolean",
          "value"=> 1,
          "selected"=> []
        },
        {
          "name"=> "radio",
          "label"=> "Радио кнопки",
          "placeholder"=> "radio",
          "mask"=> "",
          "type"=> "InputRadio",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "select",
          "label"=> "Выпадающий список",
          "placeholder"=> "select",
          "mask"=> "",
          "type"=> "InputSelect",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "list",
          "label"=> "Массив значений",
          "placeholder"=> "list",
          "mask"=> "",
          "type"=> "InputDoubleList",
          "value"=> [["1", "Пн"], ["2", "Вт"], ["3", "Ср"]],
          "selected"=> []
        }
      ]
    },
    {
      "id"=> 102,
      "data"=> [
        {
          "name"=> "number",
          "label"=> "Число",
          "placeholder"=> "Number",
          "mask"=> "[0..9\\w ]+",
          "type"=> "InputNumber",
          "value"=> 65677.3,
          "selected"=> []
        },
        {
          "name"=> "text",
          "label"=> "Текстовое поле",
          "placeholder"=> "text",
          "mask"=> "",
          "type"=> "InputText",
          "value"=> "Текстовое поле",
          "selected"=> []
        },
        {
          "name"=> "textarea",
          "label"=> "Текстовая область",
          "placeholder"=> "textarea",
          "mask"=> "",
          "type"=> "InputTextarea",
          "value"=> "Текстовая область",
          "selected"=> []
        },
        {
          "name"=> "editor",
          "label"=> "Текстовый редактор",
          "placeholder"=> "editor",
          "mask"=> "",
          "type"=> "InputCKEditor",
          "value"=> "Текстовый редактор - CKEditor",
          "selected"=> []
        },
        {
          "name"=> "codeEditor",
          "label"=> "Редактор кода",
          "placeholder"=> "codeEditor",
          "mask"=> "",
          "type"=> "InputCode",
          "value"=> "Редактор кода - ACE",
          "selected"=> []
        },
        {
          "name"=> "boolean",
          "label"=> "Чекбокс",
          "placeholder"=> "boolean",
          "mask"=> "[0..1\\w ]+",
          "type"=> "InputBoolean",
          "value"=> 1,
          "selected"=> []
        },
        {
          "name"=> "radio",
          "label"=> "Радио кнопки",
          "placeholder"=> "radio",
          "mask"=> "",
          "type"=> "InputRadio",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "select",
          "label"=> "Выпадающий список",
          "placeholder"=> "select",
          "mask"=> "",
          "type"=> "InputSelect",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "list",
          "label"=> "Массив значений",
          "placeholder"=> "list",
          "mask"=> "",
          "type"=> "InputDoubleList",
          "value"=> [["1", "Пн"], ["2", "Вт"], ["3", "Ср"]],
          "selected"=> []
        }
      ]
    },
    {
      "id"=> 103,
      "data"=> [
        {
          "name"=> "number",
          "label"=> "Число",
          "placeholder"=> "Number",
          "mask"=> "[0..9\\w ]+",
          "type"=> "InputNumber",
          "value"=> 65677.3,
          "selected"=> []
        },
        {
          "name"=> "text",
          "label"=> "Текстовое поле",
          "placeholder"=> "text",
          "mask"=> "",
          "type"=> "InputText",
          "value"=> "Текстовое поле",
          "selected"=> []
        },
        {
          "name"=> "textarea",
          "label"=> "Текстовая область",
          "placeholder"=> "textarea",
          "mask"=> "",
          "type"=> "InputTextarea",
          "value"=> "Текстовая область",
          "selected"=> []
        },
        {
          "name"=> "editor",
          "label"=> "Текстовый редактор",
          "placeholder"=> "editor",
          "mask"=> "",
          "type"=> "InputCKEditor",
          "value"=> "Текстовый редактор - CKEditor",
          "selected"=> []
        },
        {
          "name"=> "codeEditor",
          "label"=> "Редактор кода",
          "placeholder"=> "codeEditor",
          "mask"=> "",
          "type"=> "InputCode",
          "value"=> "Редактор кода - ACE",
          "selected"=> []
        },
        {
          "name"=> "boolean",
          "label"=> "Чекбокс",
          "placeholder"=> "boolean",
          "mask"=> "[0..1\\w ]+",
          "type"=> "InputBoolean",
          "value"=> 1,
          "selected"=> []
        },
        {
          "name"=> "radio",
          "label"=> "Радио кнопки",
          "placeholder"=> "radio",
          "mask"=> "",
          "type"=> "InputRadio",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "select",
          "label"=> "Выпадающий список",
          "placeholder"=> "select",
          "mask"=> "",
          "type"=> "InputSelect",
          "value"=> "Два",
          "selected"=> ["Раз", "Два"]
        },
        {
          "name"=> "list",
          "label"=> "Массив значений",
          "placeholder"=> "list",
          "mask"=> "",
          "type"=> "InputDoubleList",
          "value"=> [["1", "Пн"], ["2", "Вт"], ["3", "Ср"]],
          "selected"=> []
        }
      ]
    }
  ]
};

1;
