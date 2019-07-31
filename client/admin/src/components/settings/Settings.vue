<template>
  <Card :header="true"
        :header-left="false"
        :header-right="false"
        :footer="false"
        :footer-left="true"
        :footer-right="true"
        :body-left="true"
        :body-left-padding="false"
        :body-right="true">

    <!-- // header // -->
    <template #headerLeft>+</template>
    <template #headerRight>+</template>
    <template #header>
      <div class="uk-grid-small"
           uk-grid>
        <div>
          <a class="uk-button-default uk-button uk-button-small">
            <img src="/img/icons/icon__close.svg"
                 uk-svg
                 width="12"
                 height="12">
            <span class="uk-margin-small-left">отменить</span>
          </a>
        </div>
        <div>
          <a class="uk-button-success uk-button uk-button-small">
            <img src="/img/icons/icon__save.svg"
                 uk-svg
                 width="16"
                 height="16">
            <span class="uk-margin-small-left">сохранить</span>
          </a>
        </div>
      </div>
    </template>

    <!-- // footer // -->
    <template #footerLeft>+</template>
    <template #footerRight>+</template>
    <template #footer>footer</template>

    <!-- // Body // -->
    <template #body>

    </template>

    <!--bodyLeft-->
    <template #bodyLeft>
      <Tree :nav="nav"></Tree>
    </template>

    <!--bodyRight-->
    <template #bodyRight>bodyRight</template>

  </Card>
</template>

<script>
  import Card from '../ui/card/Card'
  import NavTree from '../ui/tree/NavTree'
  import Tree from '../ui/tree/Tree'
  import IconBug from '../ui/icons/IconBug'

  export default {

    name: 'Settings',

    components: {IconBug, Tree, NavTree, Card},

    data () {
      return {

        bodyComponent: null,

        nav: [
          {
            label:     'Основные',
            id:        1,
            component: '',
            opened:    false,
            children:  [
              {
                label:     'Раздел основных настроек номер один',
                id:        11,
                component: '',
                opened:    false,
                children:  [
                  {
                    label:     'Подраздел основных настроек номер один',
                    id:        111,
                    component: '',
                    opened:    false
                  },
                  {
                    label:     'Подраздел основных настроек номер один',
                    id:        112,
                    component: '',
                    opened:    false
                  },
                  {
                    label:     'Подраздел основных настроек номер один',
                    id:        113,
                    component: '',
                    opened:    false,
                    children:  [
                      {
                        label:     'Подраздел основных настроек номер один',
                        id:        1131,
                        component: '',
                        opened:    false
                      },
                      {
                        label:     'Подраздел основных настроек номер один',
                        id:        1132,
                        component: '',
                        opened:    false
                      },
                      {
                        label:     'Подраздел основных настроек номер один',
                        id:        1133,
                        component: '',
                        opened:    false,
                        children:  [
                          {
                            label:     'Подраздел основных настроек номер один',
                            id:        11331,
                            component: '',
                            opened:    false
                          },
                          {
                            label:     'Подраздел основных настроек номер один',
                            id:        11332,
                            component: '',
                            opened:    false
                          },
                          {
                            label:     'Подраздел основных настроек номер один',
                            id:        11333,
                            component: '',
                            opened:    false
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                label:     'Раздел основных настроек номер один',
                id:        12,
                component: '',
                opened:    false,
                children:  [
                  {
                    label:     'Подраздел основных настроек номер один',
                    id:        121,
                    component: '',
                    opened:    false
                  }
                ]
              }
            ]
          },
          {
            label:     'Дополнительные',
            id:        2,
            component: '',
            opened:    false,
            children:  [
              {
                label:     'Раздел Дополнительных настроек номер один',
                id:        21,
                component: '',
                opened:    false,
                children:  [
                  {
                    label:     'Подраздел Дополнительных настроек номер один',
                    id:        22,
                    component: '',
                    opened:    false
                  }
                ]
              }
            ]
          }
        ]
      }
    }

  }
</script>
