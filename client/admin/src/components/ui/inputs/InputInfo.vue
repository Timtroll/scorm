<template>
  <li>
    <div class="uk-form-horizontal">
      <div>
        <label v-text="label"
               class="uk-form-label uk-text-truncate"
               v-if="label"></label>

        <div class="uk-form-controls">
          <div class="uk-inline uk-width-1-1">
            <div class="uk-form-icon uk-form-icon-flip">
              <img src="/img/icons/icon__info.svg"
                   uk-svg
                   width="18"
                   height="18">
            </div>
            <span class="uk-input-text"
                  v-text="value"></span>

          </div>
        </div>
      </div>
    </div>
  </li>
</template>

<script>
  export default {
    name: 'InputInfo',

    props: {
      value:       '',
      name:        '',
      label:       {
        default: '',
        type:    String
      },
      placeholder: {
        default: '',
        type:    String
      },
      readonly:    {default: 0, type: Number},
      required:    {default: 0, type: Number},
      mask:        {
        type: RegExp
      }

    }

  }
</script>
