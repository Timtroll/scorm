PGDMP     $                    w            scorm "   10.10 (Ubuntu 10.10-1.pgdg18.04+1) "   10.10 (Ubuntu 10.10-1.pgdg18.04+1) 1    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    23749    scorm    DATABASE     w   CREATE DATABASE scorm WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
    DROP DATABASE scorm;
             otrs    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    13041    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                       1247    23751    EAV_field_type    TYPE     t   CREATE TYPE public."EAV_field_type" AS ENUM (
    'blob',
    'boolean',
    'int',
    'string',
    'datetime'
);
 #   DROP TYPE public."EAV_field_type";
       public       otrs    false    3            
           1247    23762    EAV_object_type    TYPE     K   CREATE TYPE public."EAV_object_type" AS ENUM (
    'user',
    'lesson'
);
 $   DROP TYPE public."EAV_object_type";
       public       otrs    false    3            r           1247    23840    color_t    TYPE     W   CREATE TYPE public.color_t AS ENUM (
    'blue',
    'red',
    'gray',
    'black'
);
    DROP TYPE public.color_t;
       public       otrs    false    3            �            1259    23767    EAV_data_boolean    TABLE     �   CREATE TABLE public."EAV_data_boolean" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data boolean
);
 &   DROP TABLE public."EAV_data_boolean";
       public         otrs    false    3            �            1259    23772    EAV_data_datetime    TABLE     �   CREATE TABLE public."EAV_data_datetime" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data timestamp(6) without time zone
);
 '   DROP TABLE public."EAV_data_datetime";
       public         otrs    false    3            �            1259    23777    EAV_data_int4    TABLE     �   CREATE TABLE public."EAV_data_int4" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data integer
);
 #   DROP TABLE public."EAV_data_int4";
       public         otrs    false    3            �            1259    23782    EAV_data_string    TABLE     �   CREATE TABLE public."EAV_data_string" (
    id integer DEFAULT 0 NOT NULL,
    field_id integer DEFAULT 0 NOT NULL,
    data character varying(255)
);
 %   DROP TABLE public."EAV_data_string";
       public         otrs    false    3            �            1259    23870 
   EAV_fields    TABLE     *  CREATE TABLE public."EAV_fields" (
    id integer NOT NULL,
    alias character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    type public."EAV_field_type" DEFAULT 'blob'::public."EAV_field_type",
    default_value character varying(255),
    set public."EAV_object_type"
);
     DROP TABLE public."EAV_fields";
       public         otrs    false    519    3    522    519            �            1259    23885    eav_items_id_seq    SEQUENCE     y   CREATE SEQUENCE public.eav_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.eav_items_id_seq;
       public       otrs    false    3            �           0    0    SEQUENCE eav_items_id_seq    ACL     8   GRANT ALL ON SEQUENCE public.eav_items_id_seq TO troll;
            public       otrs    false    204            �            1259    23887 	   EAV_items    TABLE     j  CREATE TABLE public."EAV_items" (
    id integer DEFAULT nextval('public.eav_items_id_seq'::regclass) NOT NULL,
    publish boolean DEFAULT false NOT NULL,
    import_id integer DEFAULT 0,
    import_type public."EAV_object_type",
    date_created timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated date,
    title character varying(255)
);
    DROP TABLE public."EAV_items";
       public         otrs    false    204    522    3            �            1259    23795 	   EAV_links    TABLE     �   CREATE TABLE public."EAV_links" (
    parent integer DEFAULT 0 NOT NULL,
    id integer DEFAULT 0 NOT NULL,
    distance integer DEFAULT 0 NOT NULL
);
    DROP TABLE public."EAV_links";
       public         otrs    false    3            �            1259    23801    EAV_sets    TABLE     �   CREATE TABLE public."EAV_sets" (
    id integer DEFAULT 0 NOT NULL,
    alias character varying(255) NOT NULL,
    title character varying(255) NOT NULL
);
    DROP TABLE public."EAV_sets";
       public         otrs    false    3            �            1259    23808    EAV_submodules_subscriptions    TABLE     �   CREATE TABLE public."EAV_submodules_subscriptions" (
    owner_id integer NOT NULL,
    sla_id integer NOT NULL,
    service_id integer NOT NULL,
    subscription_id integer DEFAULT 0 NOT NULL,
    distance smallint DEFAULT 0 NOT NULL
);
 2   DROP TABLE public."EAV_submodules_subscriptions";
       public         otrs    false    3            �            1259    87710    forum_messages    TABLE     �   CREATE TABLE public.forum_messages (
    id integer NOT NULL,
    theme_id integer NOT NULL,
    user_id integer NOT NULL,
    anounce boolean,
    date_created integer NOT NULL,
    msg text NOT NULL,
    rate integer NOT NULL
);
 "   DROP TABLE public.forum_messages;
       public         otrs    false    3            �            1259    87720    forum_rates    TABLE     �   CREATE TABLE public.forum_rates (
    user_id integer NOT NULL,
    msg_id integer NOT NULL,
    like_value smallint NOT NULL
);
    DROP TABLE public.forum_rates;
       public         otrs    false    3            �            1259    87699    forum_themes    TABLE     �   CREATE TABLE public.forum_themes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title text NOT NULL,
    url character varying(255) NOT NULL,
    rate integer NOT NULL,
    date_created integer NOT NULL
);
     DROP TABLE public.forum_themes;
       public         otrs    false    3            �            1259    77606    settings    TABLE     �  CREATE TABLE public.settings (
    id integer NOT NULL,
    lib_id integer,
    label character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    value text,
    type character varying(255),
    placeholder character varying(255),
    mask character varying(255),
    selected text,
    required integer DEFAULT 1,
    "readOnly" integer DEFAULT 0,
    editable integer DEFAULT 1,
    removable integer DEFAULT 1
);
    DROP TABLE public.settings;
       public         troll    false    3            �            1259    77604    settings_id_seq    SEQUENCE     x   CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.settings_id_seq;
       public       troll    false    207    3            �           0    0    settings_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;
            public       troll    false    206            5           2604    77609    settings id    DEFAULT     j   ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);
 :   ALTER TABLE public.settings ALTER COLUMN id DROP DEFAULT;
       public       troll    false    206    207    207            �          0    23767    EAV_data_boolean 
   TABLE DATA               @   COPY public."EAV_data_boolean" (id, field_id, data) FROM stdin;
    public       otrs    false    196   �4       �          0    23772    EAV_data_datetime 
   TABLE DATA               A   COPY public."EAV_data_datetime" (id, field_id, data) FROM stdin;
    public       otrs    false    197   �4       �          0    23777    EAV_data_int4 
   TABLE DATA               =   COPY public."EAV_data_int4" (id, field_id, data) FROM stdin;
    public       otrs    false    198   �4       �          0    23782    EAV_data_string 
   TABLE DATA               ?   COPY public."EAV_data_string" (id, field_id, data) FROM stdin;
    public       otrs    false    199   5       �          0    23870 
   EAV_fields 
   TABLE DATA               R   COPY public."EAV_fields" (id, alias, title, type, default_value, set) FROM stdin;
    public       otrs    false    203   75       �          0    23887 	   EAV_items 
   TABLE DATA               m   COPY public."EAV_items" (id, publish, import_id, import_type, date_created, date_updated, title) FROM stdin;
    public       otrs    false    205   �5       �          0    23795 	   EAV_links 
   TABLE DATA               ;   COPY public."EAV_links" (parent, id, distance) FROM stdin;
    public       otrs    false    200   �5       �          0    23801    EAV_sets 
   TABLE DATA               6   COPY public."EAV_sets" (id, alias, title) FROM stdin;
    public       otrs    false    201   6       �          0    23808    EAV_submodules_subscriptions 
   TABLE DATA               q   COPY public."EAV_submodules_subscriptions" (owner_id, sla_id, service_id, subscription_id, distance) FROM stdin;
    public       otrs    false    202   +6       �          0    87710    forum_messages 
   TABLE DATA               a   COPY public.forum_messages (id, theme_id, user_id, anounce, date_created, msg, rate) FROM stdin;
    public       otrs    false    209   H6       �          0    87720    forum_rates 
   TABLE DATA               B   COPY public.forum_rates (user_id, msg_id, like_value) FROM stdin;
    public       otrs    false    210   e6       �          0    87699    forum_themes 
   TABLE DATA               S   COPY public.forum_themes (id, user_id, title, url, rate, date_created) FROM stdin;
    public       otrs    false    208   �6       �          0    77606    settings 
   TABLE DATA               �   COPY public.settings (id, lib_id, label, name, value, type, placeholder, mask, selected, required, "readOnly", editable, removable) FROM stdin;
    public       troll    false    207   �6       �           0    0    eav_items_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.eav_items_id_seq', 1, true);
            public       otrs    false    204            �           0    0    settings_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.settings_id_seq', 64, true);
            public       troll    false    206            ;           2606    23878    EAV_fields EAV_fields_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public."EAV_fields"
    ADD CONSTRAINT "EAV_fields_pkey" PRIMARY KEY (id);
 H   ALTER TABLE ONLY public."EAV_fields" DROP CONSTRAINT "EAV_fields_pkey";
       public         otrs    false    203            =           2606    23895    EAV_items EAV_items_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."EAV_items"
    ADD CONSTRAINT "EAV_items_pkey" PRIMARY KEY (id);
 F   ALTER TABLE ONLY public."EAV_items" DROP CONSTRAINT "EAV_items_pkey";
       public         otrs    false    205            A           2606    87716 "   forum_messages forum_messages_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.forum_messages
    ADD CONSTRAINT forum_messages_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.forum_messages DROP CONSTRAINT forum_messages_pkey;
       public         otrs    false    209            C           2606    87724    forum_rates forum_rates_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.forum_rates
    ADD CONSTRAINT forum_rates_pkey PRIMARY KEY (user_id);
 F   ALTER TABLE ONLY public.forum_rates DROP CONSTRAINT forum_rates_pkey;
       public         otrs    false    210            ?           2606    87703    forum_themes forum_themes_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.forum_themes
    ADD CONSTRAINT forum_themes_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.forum_themes DROP CONSTRAINT forum_themes_pkey;
       public         otrs    false    208            �      x������ � �      �      x������ � �      �      x������ � �      �      x�3�4���2�4Q1z\\\ E�      �   F   x�3�,�H�M弰���{.l�,.)��K���,-N-�2��KIϹ��bH���������<�=... ���      �   N   x�3�,�4��I-.���420��5��5�T00�22�24�3�4500�60���0��M�^��w\�uaW� �5S      �      x�3�4�4������ �V      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �   �  x��Z[s��~�F/N�����O��dbW��H�e$a	-Hp 0��Kd%1c&�L��Q���L�V�%�B�/ �(�{�H��/qp��g��+�R��_��޲�ޗ凁iؔ�7��	�{։շ.EkhZ��Z�8��v[x�T�{�js}N�ʂp��h���UY����tyyyS\������ç����08�έ�ćD�'f��=��X]{�NY�H��ݲ_
5��H�kҺl�h�'���Djberib]RUYF��t�A_��2�̔�++L�{ZsU�g��X��\�/�}v@�ź�3YC�m��/�^���#���ZS5U��z�`�dU^#V�619!���h���Ƅǿ�����=$��O����ko�����M�h���c�����Iԡ�N��߻��N�X?[����ޡ�,^��ޢ�^�����3��@۬C�H1�#�Y���@Ўuf]�$�%H�Ro�;��
R���+rMRT��E��ɖ�״����<��<��DSA��TA[C�!N���V��Xu8@��LG �s����J�r6%,/W\����E�=� Ć�l�%h�� /{�($��+���ɔ�
v��%��Sp�>��9n� {U`k�$���Po�"GI�GI���1�Ts
��6��#�AO���Iv�Dm��O�v�3��|�$��ܣ����/�ݙ�e�<9N6@� P��0.~I�����˄�Kڷcu<<wx�p��}m�}�%H��Ѝ�EF�k�F�%c��
d<t�+���uZN��(j�V�QA�������q�/�����{�1����HG+�8��
@�:C��F+I�h���V0Z.0�t0K�=@1^� �;�!�q�_�?k��8�5�*��Wa��qHH	���b5���ǲ��=����({�1^cA����;T+�� qhV�y^>�	N��b4�ִ�4dҐ��u��&��?�h/�bȌ��� &NQ�ES����Sq�4�o�Ŕ+U�oݟ|��,OMV�ݾ5U�I�i,Z6�g櫡 ��4�@�����E%�Զ���J�r�2���gK�v�$<Oe�P��)1ʮ���O��ebO�gqK	�s~��yȱQ�] �.=���@�#�Ha���nVSnT�zU~:^q�I#SFz$�1If�$�W�O��!�"@�G�͢
-
��}ܨf�umM6����d��f��J伧"VA|�ՏY5?X@���J���)b�H;@�΃������Vǔ;w=��	�^�a���?���%;�JE��*:	*�d����E�j���L��J�˅H��䯩}��n����-�i�%�~����=�E��t._�g��ȹ|a���]
;���,}JΗTp��0����T��(�w���sk��ט֛W��"�����ǺV��zc���-M2��9�l�J���5\���#�w�U\���)�0ԯB�qE�4y̩�+�K��E�p,B�'���z0#\O�2WK�p��q楠.��J"�,�%����L�OO�@����^���U���* �`}Of:wtlA؊�U�����������@J�G��w�	p��5ִ�)��PTlh�����R*%f�|*����I�C&�H!׎W�t)2�ڻ�U�4�ZE�"j�!k��b`Q��pH�m߻��6aHbP���Œ�A9]�P,f
S��T��x�������=F��߃�)�?8E�nB)��5f��g� �"�F�'c�K�M��0|�s��e��<|GU��;8N�XQ�otaDm�K!��yG��{Etȹ;T��� ��4#1C�dJ������(�)@���3���d>�(�*9�t�GG��&��:�mq	��|̲���P�;v �RZd����ȶϏ��vN�ճwě�� WS��?���s?�[Р8{&V�(� i4kEPF�X-כ��aB^�f�h�����_���?2C�sV ����W�Eg���x������� aR��F`��D-��6N�z_��'���a��ch�C�;�f���-��5��]M��zK(��<���1��Y)�G�:��J�'�*N��k �Ḩ(��EkL���9�;���;u(FaPwE2!Om԰���3�b"r�S\��\U���T��h�҉�Q���^Y����FV#B$��"���.`PlskJ��ʕ�.�ț���dbL�{�(GnA���8�Q@�J���b�ƔQi������M�}t�>1��#eʳ�5Ȭ�
_&d�|A�����o�U��]|s��	���x���B]�4���d�__e�c֝-�܁bޝ%�F���E<�[V�@8�}M:SI����(��i>���W��:�y��`;�+B��T0��{%�B�-f
O�#U��v�y#�!�A6Ǝ}Ґ�0�9o�Z��'<�\P�U��{��W)�A��ů�@ę�����65}ol��P��|�M��[1o��s�е�[d�j^QzS��g�Ԏ�/� ķo��>�����^�k��<[ϰ�:��ٛe�CSGv/���z��坃Ҡ����I9�8e:�|(2�<���j�-`�����	�x����n�c�ؘ	���ll+���oP��ܳ�Og��լ��l�D�-��~a[ɱ��~[l_�]���Ԗ!���`��d�ނT�"�����!�x黎�k�s�+��9!�A�ho�_����>���:��KJ=q[2m���8{���e�g�f�/���RHq'�Z�W��O]�ޛf!sr�9��I_i�o��R�K�^�Et����R���SF`�:��'x�M/�x�d6�o�AhS�����#``�:�zb`��|�M��;�Mo�*�\���.�rJd�cS/'A{�q�����k�����5�1�-O߸q�W��     