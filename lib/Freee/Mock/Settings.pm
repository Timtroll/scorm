package Freee::Mock::Settings;

# Только для загрузки в таблицу
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
      "name"        => "core",
      "label"       => "Ядро",
      "id"          => 101,
      "opened"      => 0,
      "parent"      => 1,
      "keywords"    => "режим обновления список доступных редакторов редактор по умолчанию не имеет названия список доступных редакторов редактор по умолчанию не имеет названия поддержка более 2-х авто-превью включение многоязычной поддержки чтобы включить многоязычность необходимо ввести записи вида Русский rus default English eng Espanol esp дни недели русские именительный падеж емайл администратора",
      "children"    => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "fullDebugMode",
            "label"         => "режим обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 1012,
          },

          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "editorsList",
            "label"         => "список доступных редакторов редактор по умолчанию не имеет 'названия'",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => ["CKEditor"],
            "selected"      => ["CKEditor", "EditorJs"],
            "parent"        => 101,
            "id"            => 1013,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "mediaImagesConf",
            "label"         => "поддержка более 2-х авто-превью",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["0"], ["gallery"], ["crop"], ["179"], ["281"]],
            "selected"      => [],
            "parent"        => 101,
            "id"            => 1014,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "multilang",
            "label"         => "включение многоязычной поддержки.",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "rus",
            "selected"      => ["rus", "en", "esp", "ch"],
            "parent"        => 101,
            "id"            => 1015,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUDAYS",
            "label"         => "дни недели, русские, именительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["1", "Пн"], ["2", "Вт"], ["3", "Ср"], ["4", "Чт"], ["5", "Пт"], ["6", "Сб"], ["0", "Вс"]],
            "selected"      => [],
            "parent"        => 101,
            "id"            => 1016,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "admin_email",
            "label"         => "емайл администратора",
            "placeholder"   => "admin@admin.com",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 1017,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "pages_pp",
            "label"         => "число страниц в постраничной навигации",
            "placeholder"   => "30",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 1018,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "num_pp",
            "label"         => "количество выводимых на страницу элементов при постраничной разбивке во всех модулях",
            "placeholder"   => "15",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"=>    [],
            "parent"        => 101,
            "id"            => 1019,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUMONTHPSMALL",
            "label"         => "русские названия месяцев, родительный падеж, с маленькой буквы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "января"], ["1", "февраля"], ["2", "марта"], ["3", "апреля"], ["4", "мая"], ["5", "июня"], ["6", "июля"], ["7", "августа"],
              ["8", "сентября"], ["9", "октября"], ["10", "ноября"], ["11", "декабря"]
            ],
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10110,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUMONTHP",
            "label"         => "русские названия месяцев, родительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10111,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "RUMONTHSMALL",
            "label"         => "русские названя месяцев, именительный падеж, с маленькой буквы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "январь"], ["1", "февраль"], ["2", "март"], ["3", "апрель"], ["4", "май"], ["5", "июнь"], ["6", "июль"], ["7", "август"],
              ["8", "сентябрь"], ["9", "октябрь"], ["10", "ноябрь"], ["11", "декабрь"]
            ],
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10112,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "RUMONTH",
            "label"         => "русские названия месяцев, именительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "Январь"], ["1", "Февраль"], ["2", "Март"], ["3", "Апрель"], ["4", "Май"], ["5", "Июнь"], ["6", "Июль"], ["7", "Август"],
              ["8", "Сентябрь"], ["9", "Октябрь"], ["10", "Ноябрь"], ["11", "Декабрь"]
            ],
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10113,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "users_parent_category",
            "label"         => "ID категории владельца объектов профилей пользователей.",
            "placeholder"   => "1",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10114,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "site_domain",
            "label"         => "домен сайта - адрес без http://",
            "placeholder"   => "freee.su",
            "mask"          => "[0..9\:\/-_\\.\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10115,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "name"          => "site_url",
            "label"         => "URL сайта включая http://",
            "placeholder"   => "http://freee.su",
            "mask"          => "[0..9\:\/-_\\.\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10116,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "name"          => "site_label",
            "label"         => "имя сайта",
            "placeholder"   => "Образовательная система",
            "mask"          => "[- \\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 101,
            "id"            => 10117,
          }
        ]
    },
    {
      "name"      => "preferences",
      "label"     => "Настройки",
      "id"        => 102,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  => "",
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "import_step_index",
            "label"         => "индекс внутри шага обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1021,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "import_step",
            "label"         => "шаг обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1022,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "XMLUpdateProcessing",
            "label"         => "служебная переменная",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1023,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "JSSC_rebuild",
            "label"         => "служебная переменная, приказ о пересоздании JS кеша поисковой системы",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1024,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "lastXMLMTime",
            "label"         => "служебная переменная, дата последней модификации файла обновления",
            "placeholder"   => "1322600996",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1025,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "lastXMLSize",
            "label"         => "служебная переменная, последний зафиксированный размер файла обновления",
            "placeholder"   => "3145752",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1026,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "salesEmail",
            "label"         => "адрес получателя писем с заказами",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1027,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailAddress",
            "label"         => "поле From(От:) для всех исходящих писем",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1028,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailLogin",
            "label"         => "логин для авторизации на SMTP сервере",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 1029,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailPass",
            "label"         => "пароль автризации на SMTP сервере",
            "placeholder"   => "",
            "mask"          => "[_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 10210,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailSMTP",
            "label"         => "SMTP сервер",
            "placeholder"   => "mail.4clients.ru",
            "mask"          => "[\\@_-0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 102,
            "id"            => 10211,
          }
        ]
    },
    {
      "name"      => "pages",
      "label"     => "Страницы сайта",
      "id"        => 103,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  =>  "",
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputTextarea",
            "name"          => "pageBlocksOptions",
            "label"         => "Блоки на странице",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1031,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "pageMenuLocationlabels",
            "label"         => "анонсировать страницу на главной",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["1", "Меню 'Кто мы'"], ["2", "Меню 'Жизнь клуба'"], ["3", "Меню 'Магазин'"]],
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1032,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "contacts_phone",
            "label"         => "телефон",
            "placeholder"   => "8 800 2 505 505",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1033,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "contacts_bottom_address",
            "label"         => "блок контактов внизу",
            "placeholder"   => "Доставка по Москве и Московской области: 8 (919) 726-36-86",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1034,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputTextarea",
            "name"          => "countersTopCode",
            "label"         => "верхний код счётчиков",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1035,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputTextarea",
            "name"          => "countersBottomCode",
            "label"         => "нижний код счётчиков",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 103,
            "id"            => 1036,
          }
        ]
    },
    {
      "name"      => "catalog",
      "label"     => "Каталог",
      "id"        => 104,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  => "",
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "AllowAdminFilter",
            "label"         => "AllowAdminFilter",
            "placeholder"   => "1",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 104,
            "id"            => 1041,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "CatalogNumPPVariants",
            "label"         => "количественные варианты деления на страницы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => 12,
            "selected"      => [12, 30, 50],
            "parent"        => 104,
            "id"            => 1042,
          },
          {
            "type"          => "InputNumber",
            "name"          => "AllObjCatID",
            "label"         => "ID корневой категории каталога продукции",
            "placeholder"   => "2",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 104,
            "id"            => 1043,
          }
        ]
    },
    {
      "name"      => "media",
      "label"     => "Медиа",
      "id"        => 105,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  => "",
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "minWidth",
            "label"         => "ММИ: минимальная ширина",
            "placeholder"   => "120",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1051,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "minHeight",
            "label"         => "ММИ: минимальная высота",
            "placeholder"   => "90",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1052,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "maxBorderHeight",
            "label"         => "ММИ: максимальная высота границы",
            "placeholder"   => "600",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1053,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "maxBorderWidth",
            "label"         => "ММИ: максимальная высота",
            "placeholder"   => "800",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1054,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "minBorderHeight",
            "label"         => "ММИ: минимальная высота границы",
            "placeholder"   => "90",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1055,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "minBorderWidth",
            "label"         => "ММИ: минимальная ширина границы",
            "placeholder"   => "120",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1056,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "max_attachments_size",
            "label"         => "максимальный размер всех прикрепленных файлов",
            "placeholder"   => "50000000",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1057,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "default_max_attachments_size",
            "label"         => "Максимальный размер всех прикрепленных файлов",
            "placeholder"   => "10000000",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1058,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "middle_preview_height",
            "label"         => "размер по вертикали для средней первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 1059,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "middle_preview_width",
            "label"         => "размер по горизонтали для средней первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 10510,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "small_preview_height",
            "label"         => "размер по вертикали для маленькой первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 10511,
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "small_preview_width",
            "label"         => "размер по горизонтали для маленькой первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "220",
            "selected"      => [],
            "parent"        => 105,
            "id"            => 10512,
          }
        ]
    },
    {
      "name"      => "news",
      "label"     => "Новости",
      "id"        => 106,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  => "",
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "newsPageID",
            "label"         => "Точки привязки категорий новостей",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["1", "3"], ["2", "3"], ["3", "4"], ["4", "5"], ["5", "8"]],
            "selected"      => [],
            "parent"        => 106,
            "id"            => 1061,
          }
        ]
    },
    {
      "name"      => "tests",
      "label"     => "Тесты",
      "id"        => 107,
      "opened"    => 0,
      "parent"    => 1,
      "keywords"  => "",
      "children"  => [
        {
          "readonly"      => 0,
          "required"      => 1,
          "type"          => "InputNumber",
          "name"          => "UserTestsQuestionsContainerID",
          "label"         => "UserTestsQuestionsContainerID",
          "placeholder"   => "34747",
          "mask"          => "",
          "value"         => "",
          "selected"      => [],
          "parent"        => 107,
          "id"            => 1071,
          "folder"        => 0
        },
        {
          "readonly"      => 0,
          "required"      => 1,
          "type"          => "InputNumber",
          "name"          => "UserTestsContainerID",
          "label"         => "UserTestsContainerID",
          "placeholder"   => "34746",
          "mask"          => "",
          "value"         => "",
          "selected"      => [],
          "parent"        => 107,
          "id"            => 1072,
          "folder"        => 0
        }
      ]
    }
  ]
};

1;
