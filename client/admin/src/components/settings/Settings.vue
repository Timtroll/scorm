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
        :body-padding="false">

    <!-- // header // -->
    <template #headerLeft>+</template>
    <template #headerRight>+</template>
    <template #header>
    </template>

    <!-- // footer // -->
    <template #footerLeft>+</template>
    <template #footerRight>+</template>
    <template #footer>footer</template>

    <!-- // Body // -->
    <template #body>

      <Card :footer="true"
            :footer-left="true"
            :footer-right="true">

        <!--body-->
        <template #body>
          <Table :header="table.header"
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
      <Tree :nav="nav"></Tree>
    </template>

    <!--bodyRight-->
    <template #bodyRight>
      <List :data="card.bodyRightContent"
            :labels="table.header"
            v-on:close="closeRightPanel"></List>
    </template>

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
  import InputText from '../ui/inputs/Input'

  export default {

    name: 'Settings',

    components: {InputText, List, Table, IconBug, Tree, NavTree, Card},

    data () {
      return {

        bodyComponent: null,
        card:          {
          bodyRightShow:    false,
          bodyRightContent: []
        },

        table: {
          settings: {readOnly: false},
          header:   ['id', 'alias', 'title', 'type', 'default_value', 'set'],
          data:     [
            [
              {type: 'int', editable: false, validation: null, val: 1},
              {type: 'string', editable: true, validation: null, val: 'id'},
              {type: 'string', editable: true, validation: null, val: 'id'},
              {type: 'select', editable: true, validation: null, val: 'int'},
              {type: 'string', editable: true, validation: null, val: null},
              {type: 'string', editable: true, validation: null, val: 'office'}
            ], [
              {type: 'int', editable: false, validation: null, val: 2},
              {type: 'string', editable: true, validation: null, val: 'name'},
              {type: 'string', editable: true, validation: null, val: 'Название организации'},
              {type: 'select', editable: true, validation: null, val: 'string'},
              {type: 'string', editable: true, validation: null, val: null},
              {type: 'string', editable: true, validation: null, val: 'office'}
            ], [
              {type: 'int', editable: false, validation: null, val: 3},
              {type: 'string', editable: true, validation: null, val: 'system_name'},
              {type: 'string', editable: true, validation: null, val: 'Системное название'},
              {type: 'select', editable: true, validation: null, val: 'string'},
              {type: 'string', editable: true, validation: null, val: null},
              {type: 'string', editable: true, validation: null, val: 'office'}
            ], [
              {type: 'int', editable: false, validation: null, val: 4},
              {type: 'string', editable: true, validation: null, val: 'parent_id'},
              {type: 'string', editable: true, validation: null, val: 'Родитель'},
              {type: 'select', editable: true, validation: null, val: 'int'},
              {type: 'string', editable: true, validation: null, val: null},
              {type: 'string', editable: true, validation: null, val: 'office'}
            ], [
              {type: 'int', editable: false, validation: null, val: 5},
              {type: 'string', editable: true, validation: null, val: 'is_active'},
              {type: 'string', editable: true, validation: null, val: 'Статус'},
              {type: 'select', editable: true, validation: null, val: 'int'},
              {type: 'string', editable: true, validation: null, val: null},
              {type: 'string', editable: true, validation: null, val: 'office'}
            ]
          ]
        }

      }
    },

    created () {

      // Get left nav tree
      this.$store.dispatch('getNavTree')
    },

    computed: {

      // Left nav tree
      nav () {
        return this.$store.getters.navTree
        //return Settings.settings
      }
    },

    methods: {

      closeRightPanel () {
        this.card.bodyRightShow = false
      },

      editEl (event) {
        this.card.bodyRightContent = event
        this.card.bodyRightShow    = !this.card.bodyRightShow
      },

      removeEl () {}
    }

  }
</script>
