<template>
  <Card :header="false"
        :footer="false"
        :body-left="true"
        :body-left-padding="false"
        :body-left-toggle-show="true"
        :body-right="true"
        :body-right-toggle-show="false"
        :body-right-show="card.bodyRightShow"
        :body-padding="false"
        :body-left-action-event="card.bodyLeftShow"
        :loader="loader">

    <!-- // Body // -->
    <template #body>

      <transition name="slide-right"
                  mode="out-in"
                  appear>
        <router-view/>
      </transition>

    </template>

    <!--bodyLeft-->
    <template #bodyLeft>
      <Tree v-if="nav"
            :nav="nav"></Tree>
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
      //this.$store.dispatch('getNavTree')

      // cms
      this.$store.dispatch('getTree')
    },

    computed: {

      pageTable () {
        return this.$store.state.cms.navTree.items
      },

      bodyLeftShow () {
        return this.$store.getters.cardLeftState
      },

      loader () {
        return this.$store.getters.queryStatus
      },

      // Left nav tree
      nav () {
        return this.$store.getters.Settings
      }
    },

    methods: {

      //bodyLeftActionEvent () {
      //  this.$store.commit('setNavbarLeftActionState', !this.bodyLeftShow)
      //  //this.card.bodyLeftShow = !this.card.bodyLeftShow
      //},

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
