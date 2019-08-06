<template>
  <Card :header="true"
        :header-left="false"
        :header-right="false"
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

      <Card :footer="true"
            :footer-left="true"
            :header="true"
            :header-large="true"
            :header-bgr-default="true"
            :header-left="true"
            :footer-right="true"
            :body-padding="false"
            :loader="false">

        <template #headerLeft>
          <button type="button"
                  class="uk-button uk-button-success">
            <img src="/img/icons/icon__plus.svg"
                 width="16"
                 height="16"
                 uk-svg>
            <span class="uk-margin-small-left uk-visible@m"
                  v-text="$t('actions.add')"></span>
          </button>
        </template>

        <template #header>

          <!--table searchInput-->
          <div class="uk-position-relative uk-width-medium uk-margin-auto-left">
            <a @click.prevent="clearSearchVal"
               v-if="table.searchInpu"
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
                   class="uk-input">
          </div>
        </template>

        <!--body-->
        <template #body>

          <!--table-->
          <Table :header="table.header"
                 :borders="false"
                 :data="table.data"
                 v-on:edit="editEl($event)"
                 :settings="table.settings"></Table>
        </template>

        <!--footerLeft-->
        <template #footerLeft>
          <button class="uk-button-primary uk-button uk-button-small">
            <img src="/img/icons/icon__plus.svg"
                 uk-svg
                 width="14"
                 height="14">
            <span class="uk-margin-small-left uk-visible@s"
                  v-text="$t('actions.loadMore')"></span>
          </button>
        </template>

        <!--footerRight-->
        <template #footerRight>
          <div class="uk-grid-small"
               uk-grid>
            <div>
              <button class="uk-button-default uk-button uk-button-small">
                <img src="/img/icons/icon__close.svg"
                     uk-svg
                     width="10"
                     height="10">
                <span class="uk-margin-small-left uk-visible@s"
                      v-text="$t('actions.cancel')"></span>
              </button>
            </div>
            <div>
              <button class="uk-button-danger uk-button uk-button-small">
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
                  @click.prevent="closeRightPanel"
          >
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
  import InputText from '../ui/inputs/InputText'

  export default {

    name: 'Settings',

    components: {InputText, List, Table, IconBug, Tree, NavTree, Card},

    data () {
      return {

        bodyComponent: null,
        card:          {
          bodyLeftShow:     true,
          bodyRightShow:    false,
          bodyRightContent: []
        },

        table: {
          settings:    {readOnly: false},
          header:      ['id', 'alias', 'title', 'type', 'default_value', 'set'],
          data:        [
            [
              {
                type: 'int', component: 'InputNumber', editable: true, validation: null, value: 1
              },
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'id'},
              {type: 'string', component: 'InputTextarea', editable: true, validation: null, value: 'id'},
              {
                type:   'select', component: 'InputSelect', editable: true, validation: null, value: 'int',
                values: [['1', 'Пн'], ['2', 'Вт'], ['3', 'Ср'], ['4', 'Чт'], ['5', 'Пт'], ['6', 'Сб'], ['0', 'Вс']]
              },
              {type: 'string', component: 'InputCheckbox', editable: true, validation: null, value: 0},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'office'}
            ], [
              {type: 'int', component: 'InputNumber', editable: false, validation: null, value: 2},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'name'},
              {type: 'string', component: 'InputTextarea', editable: true, validation: null, value: 'Название организации'},
              {
                type:   'select', component: 'InputSelect', editable: true, validation: null, value: 'string',
                values: [['1', 'Пн'], ['2', 'Вт'], ['3', 'Ср'], ['4', 'Чт'], ['5', 'Пт'], ['6', 'Сб'], ['0', 'Вс']]
              },
              {type: 'string', component: 'InputCheckbox', editable: true, validation: null, value: 1},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'office'}
            ], [
              {type: 'int', component: 'InputNumber', editable: false, validation: null, value: 3},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'system_name'},
              {type: 'string', component: 'InputTextarea', editable: true, validation: null, value: 'Системное название'},
              {
                type:   'select', component: 'InputSelect', editable: true, validation: null, value: 'string',
                values: [['1', 'Пн'], ['2', 'Вт'], ['3', 'Ср'], ['4', 'Чт'], ['5', 'Пт'], ['6', 'Сб'], ['0', 'Вс']]
              },
              {type: 'string', component: 'InputCheckbox', editable: true, validation: null, value: 0},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'office'}
            ], [
              {type: 'int', component: 'InputNumber', editable: false, validation: null, value: 4},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'parent_id'},
              {type: 'string', component: 'InputTextarea', editable: true, validation: null, value: 'Родитель'},
              {
                type:   'select', component: 'InputSelect', editable: true, validation: null, value: 'int',
                values: [['1', 'Пн'], ['2', 'Вт'], ['3', 'Ср'], ['4', 'Чт'], ['5', 'Пт'], ['6', 'Сб'], ['0', 'Вс']]
              },
              {type: 'string', component: 'InputCheckbox', editable: true, validation: null, value: 1},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'office'}
            ], [
              {type: 'int', component: 'InputNumber', editable: false, validation: null, value: 5},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'is_active'},
              {type: 'string', component: 'InputTextarea', editable: true, validation: null, value: 'Статус'},
              {
                type:   'select', component: 'InputSelect', editable: true, validation: null, value: 'int',
                values: [['1', 'Пн'], ['2', 'Вт'], ['3', 'Ср'], ['4', 'Чт'], ['5', 'Пт'], ['6', 'Сб'], ['0', 'Вс']]
              },
              {type: 'string', component: 'InputCheckbox', editable: true, validation: null, value: 1},
              {type: 'string', component: 'InputText', editable: true, validation: null, value: 'office'}
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
        this.card.bodyLeftShow = !this.card.bodyLeftShow
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
