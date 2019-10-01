package Freee::Mock::Groups;

use utf8;

use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $groups );


our @ISA = qw( Exporter );
our @EXPORT = qw( $groups);
our @EXPORT_OK = qw( $groups );
our $pref;

$groups = {
  "groups"=> [
    {
      "label"       => "scrom",
      "id"          => 1,
      "component"   => "Groups",
      "opened"      => 0,
      "folder"      => 1,
      "keywords"    => "",
      "children"    => [
        {
          "label"       => "Просмотр сайта",
          "id"          => 1001,
          "component"   => "",
          "opened"      => 0,
          "folder"      => 0,
          "keywords"    => "",
          "children"    => [],
          "table"       => {
            "settings"  => {
              "readonly"    => 0,
              "totalCount"  => 3,
              "removable"   => 1,
              "massEdit"    => 0,
              "sortBy"      => "id",
              "sortOrder"   => "asc"
            },
            # В таблице выведутся поля, с ключами указаннымы в  "header"
            "header" => [
              {
                # Значение этого поля должно соответствовать ключу в объекте массива "body" ("name" => "name")
                "key"   => "modules",
                # Значение этого поля будет выведено в шапке таблицы
                "label" => "Название Модуля"
              },{
                "key"   => "admin",
                "label" => "Суперадмин"
              },{
                "key"   => "guest",
                "label" => "Неавторизованные пользователи"
              },{
                "key"   => "cmsmanager",
                "label" => "Менеджеры CMS"
              },{
                "key"   => "cmsuser",
                "label" => "Пользователи CMS"
              },{
                "key"   => "scormuser",
                "label" => "Пользователи Scorm"
              },{
                "key"   => "scormrector",
                "label" => "Ректоры Scorm"
              },{
                "key"   => "scormteacher",
                "label" => "Преподаватели Scorm"
              }
            ],
            "body"  =>[
              {
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputText",
                "name"          => "modules",
                "label"         => "Название Модуля",
                "placeholder"   => "Латинскими символами",
                "mask"          => "",
                "value"         => "modules",
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10011,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "admin",
                "label"         => "Суперадмин",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "guest",
                "label"         => "Неавторизованные пользователи",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "cmsmanager",
                "label"         => "Менеджеры CMS",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "cmsuser",
                "label"         => "Пользователи CMS",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "scormrector",
                "label"         => "Ректоры Scorm",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              },{
                "readonly"      => 1,
                "required"      => 1,
                "type"          => "InputCheckbox",
                "name"          => "scormteacher",
                "label"         => "Преподаватели Scorm",
                "placeholder"   => "",
                "mask"          => "[0..9\\w ]+",
                "value"         => 1,
                "selected"      => 0,
                "parent"        => 1001,
                "id"            => 10012,
                "removable"     => 1,
                "folder"        => 1
              }
            ]
          }
        }
    ],
      "table"       => {}
    }
    ]
  };

1;
