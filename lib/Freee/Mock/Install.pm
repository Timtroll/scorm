package Freee::Mock::Install;

# Только для загрузки в таблицу
use utf8;
use Encode qw( encode );
use Exporter();
use vars qw( @ISA @EXPORT @EXPORT_OK $config );
use FindBin;

our @ISA = qw( Exporter );
our @EXPORT = qw( $config );
our @EXPORT_OK = qw( $config );
our $pref;


$config = {
    'debug'                 => 1,
    'test'                  => 1,
    'secrets'               => ['187be8b67d3b264a5c536a7f2b13a8557103769b'],
    'log'                   =>'/log/mojo.log',
    'host'                  =>'http://127.0.0.1:4444',
    'expires'               =>'6000',
    'export_settings_path'  =>'',
    # it belongs to the first default admin user
    'login'                 => '',
    'password'              => '',

    #  Extension of description file (for uploaded files)
    'desc_extension' => 'desc',

    # Beanstalk
    'beans'  => {
        server          => "localhost:11300",
        default_tube    => 'main'
    },

    # databases
    'dbs' => {
        'databases' => {
            'pg_main' => {
                'dsn'      => 'dbi:Pg:dbname=scorm;host=localhost;port=5432',
                'username' => '',
                'password' => '',
                'options'  => { 'pg_enable_utf8' => 1, 'pg_auto_escape' => 1, 'AutoCommit' => 1, 'PrintError' => 1, 'RaiseError' => 1, 'pg_server_prepare' => 0 }
                # 'helper'   => 'pg'
            },
            'pg_main_test' => {
                'dsn'      => 'dbi:Pg:dbname=scorm_test;host=localhost;port=5432',
                'username' => '',
                'password' => '',
                'options'  => { 'pg_enable_utf8' => 1, 'pg_auto_escape' => 1, 'AutoCommit' => 1, 'PrintError' => 1, 'RaiseError' => 1, 'pg_server_prepare' => 0 }
                # 'helper'   => 'pg'
            }
            # 'pg_slave' => {
            #     'dsn'      => 'dbi:Pg:dbname=otrs_rt;host=localhost;port=5432',
            #     'username' => 'otrs',
            #     'password' => 'Yfenbkec_1',
            #     'options'  => { 'pg_enable_utf8' => 1, 'AutoCommit' => 1, 'PrintError' => 1, 'RaiseError' => 1, 'pg_server_prepare' => # },
            #     # 'helper'   => 'pg'
            # },
        }
    },

    # list oftimezones by country
    'timezones' => 'client/admin/src/assets/json/proto/timezones.json',

    # countries by ISO 3166-1 (2 letters)
    'countries' => 'client/admin/src/assets/json/proto/countries.json',

    # Types of html form
    "field_types" => {
        'InputTextarea'     => 1,
        'InputText'         => 1,
        'InputNumber'       => 1,
        'InputSelect'       => 1,
        'InputBoolean'      => 1,
        'InputRadio'        => 1,
        'InputList'         => 1,
        'InputDoubleList'   => 1,
        'InputRichText'     => 1,
        'inputDateTime'     => 1,
        'InputFile'         => 1
    },

    # Flags for permissions and others
    'UserFlags' => {
       'Active'         => 1,
       'EmailConfirmed' => 2,
       'PhoneConfirmed' => 4
    }
}