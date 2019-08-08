package Freee::Mock::Settings;

use utf8;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $settings );


our @ISA = qw( Exporter );
our @EXPORT = qw( $settings );
our @EXPORT_OK = qw( $settings );
our $pref;

$settings = {
  "settings"=> [
    {
      "label"       => "Ядро",
      "id"          => 1,
      "component"   => "",
      "opened"      => 0,
      "keywords"    => "режим обновления список доступных редакторов редактор по умолчанию не имеет названия список доступных редакторов редактор по умолчанию не имеет названия поддержка более 2-х авто-превью включение многоязычной поддержки чтобы включить многоязычность необходимо ввести записи вида Русский rus default English eng Espanol esp дни недели русские именительный падеж емайл администратора",
      "children"    => [],
      "table"       => {
        "settings"  => {
          "readOnly"    => 0,
          "totalCount"  => 3,
          "editable"    => 1,
          "removable"   => 1,
          "massEdit"    => 0
        },
        "header" => ["name", "label", "value", "type"],
        "body"  =>[
          {
            "editable"      => 1,
            "type"          => "InputNumber",
            "name"          => "fullDebugMode",
            "label"         => "режим обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => ""
          },
          {
            "type"          => "InputSelect",
            "name"          => "editorsList",
            "label"         => "список доступных редакторов редактор по умолчанию не имеет 'названия'",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "CKEditor",
            "values"        => ["CKEditor"]
          },
          {
            "type"          => "InputList",
            "name"          => "mediaImagesConf",
            "label"         => "поддержка более 2-х авто-превью",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "values"        => ["0", "gallery", "crop", "179", "281"]
          },
          {
            "type"          => "InputSelect",
            "name"          => "multilang",
            "label"         => "включение многоязычной поддержки.",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "rus",
            "values"        => ["rus", "en", "esp", "ch"]
          },
          {
            "type"=>        "InputDoubleList",
            "name"=>        "RUDAYS",
            "label"=>       "дни недели, русские, именительный падеж",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       [["1", "Пн"], ["2", "Вт"], ["3", "Ср"], ["4", "Чт"], ["5", "Пт"], ["6", "Сб"], ["0", "Вс"]],
            "values"=>      ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "admin_email",
            "label"=>       "емайл администратора",
            "placeholder"=> "admin@admin.com",
            "mask"=>        "[\\@_-\\.0..9\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "pages_pp",
            "label"=>       "число страниц в постраничной навигации",
            "placeholder"=> "30",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "num_pp",
            "label"=>       "количество выводимых на страницу элементов при постраничной разбивке во всех модулях",
            "placeholder"=> "15",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputDoubleList",
            "name"=>        "RUMONTHPSMALL",
            "label"=>       "русские названия месяцев, родительный падеж, с маленькой буквы",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       [
              ["0", "января"], ["1", "февраля"], ["2", "марта"], ["3", "апреля"], ["4", "мая"], ["5", "июня"], ["6", "июля"], ["7", "августа"],
              ["8", "сентября"], ["9", "октября"], ["10", "ноября"], ["11", "декабря"]
            ],
            "values"=>      ""
          },
          {
            "type"=>        "InputDoubleList",
            "name"=>        "RUMONTHP",
            "label"=>       "русские названия месяцев, родительный падеж",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       "",
            "values"=>      ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "RUMONTHSMALL",
            "label"=>       "русские названя месяцев, именительный падеж, с маленькой буквы",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       "",
            "values"=>      [
              ["0", "январь"], ["1", "февраль"], ["2", "март"], ["3", "апрель"], ["4", "май"], ["5", "июнь"], ["6", "июль"], ["7", "август"],
              ["8", "сентябрь"], ["9", "октябрь"], ["10", "ноябрь"], ["11", "декабрь"]
            ]
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "RUMONTH",
            "label"=>       "русские названия месяцев, именительный падеж",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       "3",
            "values"=>      [
              ["0", "Январь"], ["1", "Февраль"], ["2", "Март"], ["3", "Апрель"], ["4", "Май"], ["5", "Июнь"], ["6", "Июль"], ["7", "Август"],
              ["8", "Сентябрь"], ["9", "Октябрь"], ["10", "Ноябрь"], ["11", "Декабрь"]
            ]
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "users_parent_category",
            "label"=>       "ID категории владельца объектов профилей пользователей.",
            "placeholder"=> "1",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "site_domain",
            "label"=>       "домен сайта - адрес без http://",
            "placeholder"=> "freee.su",
            "mask"=>        "[0..9\:\/-_\\.\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "site_url",
            "label"=>       "URL сайта включая http://",
            "placeholder"=> "http://freee.su",
            "mask"=>        "[0..9\:\/-_\\.\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "site_label",
            "label"=>       "имя сайта",
            "placeholder"=> "Образовательная система",
            "mask"=>        "[- \\w]+",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "Настройки",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputNumber",
            "name"=>        "import_step_index",
            "label"=>       "индекс внутри шага обновления",
            "placeholder"=> "",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "import_step",
            "label"=>       "шаг обновления",
            "placeholder"=> "",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "XMLUpdateProcessing",
            "label"=>       "служебная переменная",
            "placeholder"=> "",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "JSSC_rebuild",
            "label"=>       "служебная переменная, приказ о пересоздании JS кеша поисковой системы",
            "placeholder"=> "",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "lastXMLMTime",
            "label"=>       "служебная переменная, дата последней модификации файла обновления",
            "placeholder"=> "1322600996",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "lastXMLSize",
            "label"=>       "служебная переменная, последний зафиксированный размер файла обновления",
            "placeholder"=> "3145752",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "salesEmail",
            "label"=>       "адрес получателя писем с заказами",
            "placeholder"=> "mail@4clients.ru",
            "mask"=>        "[\\@_-\\.0..9\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "mailAddress",
            "label"=>       "поле From(От:) для всех исходящих писем",
            "placeholder"=> "mail@4clients.ru",
            "mask"=>        "[\\@_-\\.0..9\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "mailLogin",
            "label"=>       "логин для авторизации на SMTP сервере",
            "placeholder"=> "mail@4clients.ru",
            "mask"=>        "[\\@_-\\.0..9\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "mailPass",
            "label"=>       "пароль автризации на SMTP сервере",
            "placeholder"=> "",
            "mask"=>        "[_-\\.0..9\\w]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "mailSMTP",
            "label"=>       "SMTP сервер",
            "placeholder"=> "mail.4clients.ru",
            "mask"=>        "[\\@_-0..9\\w]+",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "Страницы сайта",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputTextarea",
            "name"=>        "pageBlocksOptions",
            "label"=>       "Блоки на странице",
            "placeholder"=> "",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputDoubleList",
            "name"=>        "pageMenuLocationlabels",
            "label"=>       "анонсировать страницу на главной",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       [["1", "Меню 'Кто мы'"], ["2", "Меню 'Жизнь клуба'"], ["3", "Меню 'Магазин'"]],
            "values"=>      ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "contacts_phone",
            "label"=>       "телефон",
            "placeholder"=> "8 800 2 505 505",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "contacts_bottom_address",
            "label"=>       "блок контактов внизу",
            "placeholder"=> "Доставка по Москве и Московской области: 8 (919) 726-36-86",
            "mask"=>        "[0..9\\w ]+",
            "value"=>       ""
          },
          {
            "type"=>        "InputTextarea",
            "name"=>        "countersTopCode",
            "label"=>       "верхний код счётчиков",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       ""
          },
          {
            "type"=>        "InputTextarea",
            "name"=>        "countersBottomCode",
            "label"=>       "нижний код счётчиков",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "Каталог",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputNumber",
            "name"=>        "AllowAdminFilter",
            "label"=>       "AllowAdminFilter",
            "placeholder"=> "1",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputSelect",
            "name"=>        "CatalogNumPPVariants",
            "label"=>       "количественные варианты деления на страницы",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       30,
            "values"=>      [12, 30, 50]
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "AllObjCatID",
            "label"=>       "ID корневой категории каталога продукции",
            "placeholder"=> "2",
            "mask"=>        "",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "Медиа",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputNumber",
            "name"=>        "minWidth",
            "label"=>       "ММИ: минимальная ширина",
            "placeholder"=> "120",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "minHeight",
            "label"=>       "ММИ: минимальная высота",
            "placeholder"=> "90",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "maxBorderHeight",
            "label"=>       "ММИ: максимальная высота границы",
            "placeholder"=> "600",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "maxBorderWidth",
            "label"=>       "ММИ: максимальная высота",
            "placeholder"=> "800",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "minBorderHeight",
            "label"=>       "ММИ: минимальная высота границы",
            "placeholder"=> "90",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "minBorderWidth",
            "label"=>       "ММИ: минимальная ширина границы",
            "placeholder"=> "120",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "max_attachments_size",
            "label"=>       "максимальный размер всех прикрепленных файлов",
            "placeholder"=> "50000000",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "default_max_attachments_size",
            "label"=>       "Максимальный размер всех прикрепленных файлов",
            "placeholder"=> "10000000",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "middle_preview_height",
            "label"=>       "размер по вертикали для средней первьюшки",
            "placeholder"=> "220",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "middle_preview_width",
            "label"=>       "размер по горизонтали для средней первьюшки",
            "placeholder"=> "220",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "small_preview_height",
            "label"=>       "размер по вертикали для маленькой первьюшки",
            "placeholder"=> "220",
            "mask"=>        "\\d+",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "small_preview_width",
            "label"=>       "размер по горизонтали для маленькой первьюшки",
            "placeholder"=> "220",
            "mask"=>        "\\d+",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "Новости",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputDoubleList",
            "name"=>        "newsPageID",
            "label"=>       "Точки привязки категорий новостей",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       [["1", "3"], ["2", "3"], ["3", "4"], ["4", "5"], ["5", "8"]],
            "values"=>      ""
          }
        ]
      }
    },
    {
      "label"=>     "Тесты",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputNumber",
            "name"=>        "UserTestsQuestionsContainerID",
            "label"=>       "UserTestsQuestionsContainerID",
            "placeholder"=> "34747",
            "mask"=>        "",
            "value"=>       ""
          },
          {
            "type"=>        "InputNumber",
            "name"=>        "UserTestsContainerID",
            "label"=>       "UserTestsContainerID",
            "placeholder"=> "34746",
            "mask"=>        "",
            "value"=>       ""
          }
        ]
      }
    },
    {
      "label"=>     "добавить параметр",
      "id"=>        1,
      "component"=> "",
      "opened"=>    0,
      "keywords"=>  "",
      "children"=>  [],
      "table"=>     {
        "settings"=> {
          "readOnly"=>   0,
          "totalCount"=> 3,
          "editable"=>   1,
          "removable"=>  1,
          "massEdit"=>   0
        },
        "header"=>   ["name", "label", "value", "type"],
        "body"=>     [
          {
            "type"=>        "InputDoubleList",
            "name"=>        "libid",
            "label"=>       "Модуль владелец",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       [
              ["1", "Шаблоны"], ["2", "Календарь"], ["3", "заявки"], ["4", "Редактор форм"], ["5", "Страницы сайта"], ["6", "Пользователи сайта"],
              ["7", "Медиа"], ["8", "Новости"], ["9", "Облако тэгов"], ["10", "Отзывы"], ["11", "Каталог"], ["12", "Формы"], ["13", "Настройки"],
              ["14", "Форум"], ["15", "Поиск"], ["16", "банеры"], ["17", "Вакансии"], ["18", "Визуальный редактор"], ["19", "Администраторы"],
              ["20", "Файловый менеджер"], ["21", "Управление MySQL"], ["22", "LiveSupport"], ["23", "Учёт"], ["24", "Вопросы к курсам"],
              ["25", "Тесты"]
            ],
            "values"=>      ""
          },
          {
            "type"=>        "InputList",
            "name"=>        "type",
            "label"=>       "Тип параметра",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       ["число", "строка", "текстовая область", "Селект", "список", "вложенный список"],
            "values"=>      ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "pname",
            "label"=>       "Название переменной",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       ""
          },
          {
            "type"=>        "InputText",
            "name"=>        "pdescr",
            "label"=>       "Описание переменной",
            "placeholder"=> "",
            "mask"=>        "",
            "value"=>       ""
          }
        ]
      }
    }
  ]
};

1;