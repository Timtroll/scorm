<template>
  <Card :header="true"
        :header-bgr-default="true"
        :header-padding-none="true"
        :header-right="true"
        :body-padding="true">

    <!-- // header // -->
    <template #header>
      <div class="uk-position-relative uk-width-1-1">
        <div class="uk-form-icon">
          <img src="/img/icons/icon__search.svg"
               width="14"
               height="14"
               uk-svg>
        </div>
        <input class="uk-input pos-border-radius-none pos-border-none"
               @keypress.enter="search"
               v-model="searchRequest"
               :placeholder="$t('media.searchPlaceholder')">
      </div>
    </template>

    <!-- // headerRight // -->
    <template #headerRight>
      <button class="uk-button pos-card-header-item"
              @click.prevent="search"
              :disabled="searchSubmitDisable">
        <img src="/img/icons/icon__search.svg"
             uk-svg=""
             width="20"
             height="20"
             hidden="true">
      </button>

    </template>

    <!-- // Body // -->
    <template #body>
      <div class="pos-media">

        <div class="pos-media-result">
          <FileGrid :data="searchResult"
                    :allow-actions="true"/>
        </div>

        <div class="pos-media-search">
          <ul class="pos-list">
            <InputFile/>
          </ul>
        </div>

      </div>
    </template>

  </Card>
</template>

<script>

import filesClass from './../../api/upload/files'
import {notify, prettyBytes} from '../../store/methods'

const files = new filesClass

export default {

  name:       'Media',
  components: {
    FileGrid:  () => import(/* webpackChunkName: "FileGrid" */ '../../components/ui/files/FileGrid'),
    Card:      () => import(/* webpackChunkName: "Card" */ './../../components/ui/card/Card'),
    InputFile: () => import(/* webpackChunkName: "InputFile" */ './../../components/ui/inputs/InputFile')
  },
  metaInfo () {
    return {
      title:         this.$route.meta.breadcrumb,
      titleTemplate: '%s - Scorm',
      htmlAttrs:     {
        lang: this.$t('app.lang')
      }
    }
  },

  data () {
    return {
      searchRequest: '',
      searchResult:  []
    }
  },

  computed: {

    searchSubmitDisable () {
      return !this.searchRequest
    },

    pageTitle () {
      return this.$route.meta.breadcrumb
    }

  },

  methods: {

    clearSearch () { this.searchRequest = ''},

    async search () {
      if (!this.searchRequest) return
      this.searchResult = []
      const response    = await files.search(this.searchRequest)
      const data        = await response
      this.searchResult = data.data
    }

  }
}
</script>
