<template>
  <Card :header="false"
        :footer="false"
        :footer-left="true"
        :footer-right="true"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-right-toggle-show="false"
        :body-right-show="card.bodyRightShow"
        :body-padding="false"
        :body-left-action-event="card.bodyLeftShow"
        :loader="loader">

    <!-- // header // -->
    <template #headerLeft></template>
    <template #headerRight></template>
    <template #header></template>

    <!-- // footer // -->
    <template #footerLeft>+</template>
    <template #footerRight>+</template>
    <template #footer>footer</template>

    <!-- // Body // -->
    <template #body>

      <Card :footer="false"
            :footer-left="false"
            :header="true"
            :header-large="false"
            :header-bgr-default="true"
            :header-left="true"
            :footer-right="false"
            :body-padding="true"
            :loader="false">

        <template #headerLeft>
          <div class="uk-grid-small"
               uk-grid>

            <!--Add Row-->
            <div>
              <button type="button"
                      class="uk-button uk-button-success uk-button-small">
                <img src="/img/icons/icon__plus.svg"
                     width="16"
                     height="16"
                     uk-svg>
                <span class="uk-margin-small-left uk-visible@m"
                      v-text="$t('actions.add')"></span>
              </button>
            </div>

            <!--Remove Row-->
            <div>
              <button class="uk-button-danger uk-button uk-button-small"
                      disabled>
                <img src="/img/icons/icon__trash.svg"
                     uk-svg
                     width="10"
                     height="10">
                <span class="uk-margin-small-left uk-visible@s"
                      v-text="$t('actions.remove')"></span>
              </button>
            </div>
          </div>

        </template>

        <template #header>

          <ul class="uk-pagination uk-margin-remove"
              uk-margin>
            <li><a href="#">
              <span uk-pagination-previous></span>
            </a></li>
            <li><a href="#">1</a></li>
            <li class="uk-active">
              <span>4</span>
            </li>
            <li><a href="#">8</a></li>
            <li><a href="#">
              <span uk-pagination-next></span>
            </a></li>
          </ul>
          <!--table searchInput-->
          <div class="uk-position-relative uk-width-medium uk-margin-auto-left">
            <a @click.prevent="clearSearchVal"
               v-if="table.searchInput"
               class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__close.svg"
                   width="10"
                   height="10"
                   uk-svg>
            </a>
            <div v-else
                 class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__search.svg"
                   width="14"
                   height="14"
                   uk-svg>
            </div>
            <input type="text"
                   v-model="table.searchInput"
                   @keyup.esc="clearSearchVal"
                   placeholder="Поиск"
                   class="uk-input uk-form-small">
          </div>
        </template>

        <!--body-->
        <template #body>

          <!--table-->
          <Table :header="table.header"
                 :borders="true"
                 :data="table.data"
                 v-on:edit="editEl($event)"
                 :settings="table.settings"></Table>
        </template>

      </Card>

    </template>

    <!--bodyLeft-->
    <template #bodyLeft>
      <Tree :nav="nav"
            @click="bodyLeftActionEvent"></Tree>
    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :data="card.bodyRightContent"
            :labels="table.header"
            v-on:close="closeRightPanel"></List>
    </template>

    <!--bodyRightFooter-->
    <template #bodyRightFooter>
      <div class="uk-flex uk-flex-between uk-width-1-1">
        <div class="">
          <button class="uk-button-default uk-button uk-button-small"
                  @click.prevent="closeRightPanel">
            <img src="/img/icons/icon__close.svg"
                 uk-svg
                 width="10"
                 height="10">
            <span class="uk-margin-small-left"
                  v-text="$t('actions.cancel')"></span>
          </button>
        </div>
        <div class="">
          <button class="uk-button-success uk-button uk-button-small">
            <img src="/img/icons/icon__save.svg"
                 uk-svg
                 width="14"
                 height="14">
            <span class="uk-margin-small-left">сохранить</span>
          </button>
        </div>
      </div>
    </template>

  </Card>
</template>

<script>
  import Card from '../ui/card/Card'
  import NavTree from '../ui/tree/NavTree'
  import Tree from '../ui/tree/Tree'
  import IconBug from '../ui/icons/IconBug'
  import Table from '../ui/table/Table'
  import List from '../ui/list/List'

  export default {

    name: 'Settings',

    components: {List, Table, IconBug, Tree, NavTree, Card},

    data () {
      return {

        bodyComponent: null,
        card:          {
          //bodyLeftShow:     true,
          bodyRightShow:    false,
          bodyRightContent: []
        },

        table: {
          settings:    {readOnly: false},
          header:      ['InputNumber', 'InputText', 'InputTextarea', 'InputBoolean', 'InputRadio', 'InputSelect', 'InputList', 'InputDoubleList'],
          data:        [
            [{
              component:   'InputNumber',
              name:        'fullDebugMode',
              label:       'Режим обновления',
              placeholder: '',
              editable:    true,
              mask:        '[0..9\\w ]+',
              value:       5,
              values:      null
            }, {
              component:   'InputText',
              name:        'site_url',
              label:       'URL сайта включая http(s)://',
              placeholder: '',
              editable:    true,
              mask:        '[:\\/-_\\.\\w]+',
              value:       'http://freee.su',
              values:      null
            }, {
              component:   'InputTextarea',
              name:        'site_url',
              label:       'URL сайта включая http(s)://',
              placeholder: '',
              editable:    true,
              mask:        '[:\\/-_\\.\\w]+',
              value:       'http://freee.su',
              values:      null
            }, {
              component:   'InputBoolean',
              name:        'true_false',
              label:       'Да или нет, вот в чем вопрос',
              placeholder: '',
              editable:    true,
              mask:        '',
              value:       1,
              values:      null
            }, {
              component:   'InputRadio',
              name:        'radio buttons',
              label:       'Да или нет, а может и что-то другое, вот в чем вопрос',
              placeholder: '',
              editable:    true,
              mask:        '',
              value:       'rus',
              values:      ['rus', 'en', 'esp', 'ch']
            }, {
              component:   'InputSelect',
              name:        'multilang',
              label:       'Основной язык',
              placeholder: '',
              editable:    true,
              mask:        '',
              value:       'rus',
              values:      ['rus', 'en', 'esp', 'ch']
            }, {
              component:   'InputList',
              name:        'CatalogNumPPVariants',
              label:       'Количественные варианты деления на страницы',
              placeholder: '',
              editable:    true,
              mask:        '',
              value:       ['10', '20', '30', '40', '50']
            }, {
              component:   'InputDoubleList',
              name:        'libid',
              label:       'Модуль владелец',
              placeholder: '',
              editable:    true,
              mask:        '',
              value:       [['1', 'Шаблоны'], ['2', 'Календарь'], ['3', 'заявки'], ['4', 'Редактор форм'], ['5', 'Страницы сайта'], ['6', 'Пользователи сайта'], ['7', 'Медиа'], ['8', 'Новости'], ['9', 'Облако тэгов'], ['10', 'Отзывы'], ['11', 'Каталог'], ['12', 'Формы'], ['13', 'Настройки'], ['14', 'Форум'], ['15', 'Поиск'], ['16', 'банеры'], ['17', 'Вакансии'], ['18', 'Визуальный редактор'], ['19', 'Администраторы'], ['20', 'Файловый менеджер'], ['21', 'Управление MySQL'], ['22', 'LiveSupport'], ['23', 'Учёт'], ['24', 'Вопросы к курсам'], ['25', 'Тесты']]
            }
            ]
          ],
          searchInput: null
        }

      }
    },

    created () {

      // Get left nav tree
      this.$store.dispatch('getNavTree')
    },

    computed: {

      bodyLeftShow () {
        return this.$store.getters.navbarLeftActionState
      },

      loader () {
        if (this.nav) {
          return false
        }
      },

      // Left nav tree
      nav () {
        return this.$store.getters.navTree
      }
    },

    methods: {

      bodyLeftActionEvent () {
        this.$store.commit('setNavbarLeftActionState', !this.bodyLeftShow)
        //this.card.bodyLeftShow = !this.card.bodyLeftShow
      },

      closeRightPanel () {
        this.card.bodyRightShow = false
      },

      editEl (event) {
        this.card.bodyRightContent = event
        this.card.bodyRightShow    = !this.card.bodyRightShow
      },

      removeEl () {},

      // Очистка поля поиска
      clearSearchVal () {
        this.table.searchInput = null
      }
    }

  }
</script>
