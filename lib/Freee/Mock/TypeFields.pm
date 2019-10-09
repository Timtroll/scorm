package Freee::Mock::TypeFields;

# html Типы полей в системе 
use utf8;
use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $type );

our @ISA = qw( Exporter );
our @EXPORT = qw( $type);
our @EXPORT_OK = qw( $type );

our $type = [
    { 'value' => 'InputText',       'label' => 'Текстовое поле' },
    { 'value' => 'InputNumber',     'label' => 'Число' },
    { 'value' => 'inputDateTime',   'label' => 'Дата и время' },
    { 'value' => 'InputTextarea',   'label' => 'Текстовая область' },
    { 'value' => 'InputCKEditor',   'label' => 'Текстовый редактор - CKEditor' },
    { 'value' => 'InputBoolean',    'label' => 'Чекбокс' },
    { 'value' => 'InputRadio',      'label' => 'Радио кнопки' },
    { 'value' => 'InputSelect',     'label' => 'Выпадающий список' },
    { 'value' => 'InputDoubleList', 'label' => 'Массив значений' },
    { 'value' => 'InputCode',       'label' => 'Редактор кода' }
];

1;
