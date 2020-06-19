package Freee::Mock::Settings;

# Только для загрузки в таблицу
use utf8;
use Encode qw( encode );
use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $settings );
use FindBin;

our @ISA = qw( Exporter );
our @EXPORT = qw( $settings );
our @EXPORT_OK = qw( $settings );
our $pref;

$settings = {
  "settings"=> [
    {
      "name"        => "core",
      "label"       => "Ядро",
      "opened"      => 0,
      "parent"      => 0,
      "folder"      => 1,
      "status"      => 1,
      "keywords"    => "режим обновления список доступных редакторов редактор по умолчанию не имеет названия список доступных редакторов редактор по умолчанию не имеет названия поддержка более 2-х авто-превью включение многоязычной поддержки чтобы включить многоязычность необходимо ввести записи вида Русский rus default English eng Espanol esp дни недели русские именительный падеж емайл администратора",
      "children"    => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "socials",
            "label"         => "Социальные сети",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["1", "ВКонтакте"], ["2", "Facebook"], ["3", "Google"], ["4", "Yandex"], ["5", "Twitter"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "upload_name_length",
            "label"         => "Длина нового имени файла (в символах)",
            "placeholder"   => 48,
            "mask"          => "",
            "value"         => 48,
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "upload_max_size",
            "label"         => "Максимальный размер файла (в байтах)",
            "placeholder"   => 1048576,
            "mask"          => "",
            "value"         => 1048576,
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "upload_local_path",
            "label"         => "Локальный путь к хранилищу файлов",
            "placeholder"   => $FindBin::Bin . '/../public/storage/',
            "mask"          => "",
            "value"         => $FindBin::Bin . '/../public/storage/',
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "upload_url_path",
            "label"         => "Url-путь к хранилищу файлов",
            "placeholder"   => "/storage/",
            "mask"          => "",
            "value"         => '/storage/',
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "desc_extension",
            "label"         => "Расширение файла описания",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => 'desc',
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "root",
            "label"         => "Корень проекта",
            "placeholder"   => $FindBin::Bin . '/../',
            "mask"          => "",
            "value"         => $FindBin::Bin . '/../',
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "valid_extensions",
            "label"         => "Разрешённые расширения загружаемых файлов (не включать значение  desc !!!)",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["1", "png"], ["1", "jpg"], ["1", "jpeg"], ["1", "svg"], ["1", "txt"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "fullDebugMode",
            "label"         => "Режим обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },

          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "editorsList",
            "label"         => "Список доступных редакторов редактор по умолчанию не имеет 'названия'",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "CKEditor",
            "selected"      => ["CKEditor", "EditorJs"],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "mediaImagesConf",
            "label"         => "Поддержка более 2-х авто-превью",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["0"], ["gallery"], ["crop"], ["179"], ["281"]],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "multilang",
            "label"         => "Включение многоязычной поддержки.",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "rus",
            "selected"      => ["rus", "en", "esp", "ch"],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUDAYS",
            "label"         => "Дни недели, русские, именительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["1", "Пн"], ["2", "Вт"], ["3", "Ср"], ["4", "Чт"], ["5", "Пт"], ["6", "Сб"], ["0", "Вс"]],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "admin_email",
            "label"         => "Email администратора",
            "placeholder"   => "admin@admin.com",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "pages_pp",
            "label"         => "Число страниц в постраничной навигации",
            "placeholder"   => "30",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "num_pp",
            "label"         => "Количество выводимых на страницу элементов при постраничной разбивке во всех модулях",
            "placeholder"   => 15,
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUMONTHPSMALL",
            "label"         => "Русские названия месяцев, родительный падеж, с маленькой буквы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "января"], ["1", "февраля"], ["2", "марта"], ["3", "апреля"], ["4", "мая"], ["5", "июня"], ["6", "июля"], ["7", "августа"],
              ["8", "сентября"], ["9", "октября"], ["10", "ноября"], ["11", "декабря"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "RUMONTHP",
            "label"         => "Русские названия месяцев, родительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "Января"], ["1", "Февраля"], ["2", "Марта"], ["3", "Апреля"], ["4", "Мая"], ["5", "Июня"], ["6", "Июля"], ["7", "Августа"],
              ["8", "Сентября"], ["9", "Октября"], ["10", "Ноября"], ["11", "Декабря"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "RUMONTHSMALL",
            "label"         => "Русские названя месяцев, именительный падеж, с маленькой буквы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "январь"], ["1", "февраль"], ["2", "март"], ["3", "апрель"], ["4", "май"], ["5", "июнь"], ["6", "июль"], ["7", "август"],
              ["8", "сентябрь"], ["9", "октябрь"], ["10", "ноябрь"], ["11", "декабрь"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "RUMONTH",
            "label"         => "Русские названия месяцев, именительный падеж",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [
              ["0", "Январь"], ["1", "Февраль"], ["2", "Март"], ["3", "Апрель"], ["4", "Май"], ["5", "Июнь"], ["6", "Июль"], ["7", "Август"],
              ["8", "Сентябрь"], ["9", "Октябрь"], ["10", "Ноябрь"], ["11", "Декабрь"]
            ],
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "site_domain",
            "label"         => "Домен сайта",
            "placeholder"   => "freee.su",
            "mask"          => "[0..9\-_\\.\\w]+",
            "value"         => "freee.su",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "name"          => "site_url",
            "label"         => "URL сайта",
            "placeholder"   => "https://freee.su",
            "mask"          => "[0..9\:\/-_\\.\\w]+",
            "value"         => "https://freee.su",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "name"          => "site_label",
            "label"         => "имя сайта",
            "placeholder"   => "Система получения знаний",
            "mask"          => "[- \\w]+",
            "value"         => "Система получения знаний",
            "selected"      => [],
            "parent"        => 1,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "preferences",
      "label"     => "Настройки",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  => "",
      "folder"    => 1,
      "status"    => 1,
      "children"  => [
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "import_step_index",
            "label"         => "Индекс внутри шага обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "import_step",
            "label"         => "Шаг обновления",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "XMLUpdateProcessing",
            "label"         => "Служебная переменная",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "JSSC_rebuild",
            "label"         => "Служебная переменная, приказ о пересоздании JS кеша поисковой системы",
            "placeholder"   => "",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "lastXMLMTime",
            "label"         => "Служебная переменная, дата последней модификации файла обновления",
            "placeholder"   => "1322600996",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "lastXMLSize",
            "label"         => "Служебная переменная, последний зафиксированный размер файла обновления",
            "placeholder"   => "3145752",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "salesEmail",
            "label"         => "Адрес получателя писем с заказами",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailAddress",
            "label"         => "Поле From(От:) для всех исходящих писем",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailLogin",
            "label"         => "Логин для авторизации на SMTP сервере",
            "placeholder"   => "mail@4clients.ru",
            "mask"          => "[\\@_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "mailPass",
            "label"         => "Пароль автризации на SMTP сервере",
            "placeholder"   => "",
            "mask"          => "[_-\\.0..9\\w]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 2,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "pages",
      "label"     => "Страницы сайта",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  =>  "",
      "folder"    => 1,
      "status"    => 1,
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
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputDoubleList",
            "name"          => "pageMenuLocationlabels",
            "label"         => "Анонсировать страницу на главной",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => [["1", "Меню 'Кто мы'"], ["2", "Меню 'Жизнь клуба'"], ["3", "Меню 'Магазин'"]],
            "selected"      => [],
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "contacts_phone",
            "label"         => "Телефон",
            "placeholder"   => "8 800 2 505 505",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputText",
            "name"          => "contacts_bottom_address",
            "label"         => "Блок контактов внизу",
            "placeholder"   => "Доставка по Москве и Московской области: 8 (919) 726-36-86",
            "mask"          => "[0..9\\w ]+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputTextarea",
            "name"          => "countersTopCode",
            "label"         => "Верхний код счётчиков",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputTextarea",
            "name"          => "countersBottomCode",
            "label"         => "Нижний код счётчиков",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 3,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "catalog",
      "label"     => "Каталог",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  => "",
      "folder"    => 1,
      "status"    => 1,
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
            "parent"        => 4,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputSelect",
            "name"          => "CatalogNumPPVariants",
            "label"         => "Количественные варианты деления на страницы",
            "placeholder"   => "",
            "mask"          => "",
            "value"         => 12,
            "selected"      => [12, 30, 50],
            "parent"        => 4,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "type"          => "InputNumber",
            "name"          => "AllObjCatID",
            "label"         => "ID корневой категории каталога продукции",
            "placeholder"   => "2",
            "mask"          => "",
            "value"         => "",
            "selected"      => [],
            "parent"        => 4,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "media",
      "label"     => "Медиа",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  => "",
      "folder"    => 1,
      "status"    => 1,
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "max_attachments_size",
            "label"         => "Максимальный размер всех прикрепленных файлов",
            "placeholder"   => "50000000",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
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
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "middle_preview_height",
            "label"         => "Размер по вертикали для средней первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "middle_preview_width",
            "label"         => "Размер по горизонтали для средней первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "small_preview_height",
            "label"         => "Размер по вертикали для маленькой первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "",
            "selected"      => [],
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          },
          {
            "readonly"      => 0,
            "required"      => 1,
            "type"          => "InputNumber",
            "name"          => "small_preview_width",
            "label"         => "Размер по горизонтали для маленькой первьюшки",
            "placeholder"   => "220",
            "mask"          => "\\d+",
            "value"         => "220",
            "selected"      => [],
            "parent"        => 5,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "news",
      "label"     => "Новости",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  => "",
      "folder"    => 1,
      "status"    => 1,
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
            "parent"        => 6,
            "folder"        => 0,
            "status"        => 1
          }
        ]
    },
    {
      "name"      => "tests",
      "label"     => "Тесты",
      "opened"    => 0,
      "parent"    => 0,
      "keywords"  => "",
      "folder"    => 1,
      "status"    => 1,
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
          "parent"        => 7,
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
          "parent"        => 7,
          "folder"        => 0
        }
      ]
    }
  ]
};

1;
