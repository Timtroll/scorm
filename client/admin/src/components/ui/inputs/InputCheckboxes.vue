<template>
  <li>
    <div class="uk-form-horizontal uk-overflow-hidden">
      <div>
        <label v-text="label || placeholder"
               class="uk-form-label uk-text-truncate"
               v-if="label || placeholder"/>

        <div class="uk-form-controls uk-form-controls-text"
             v-if="listParents">

          <label class="uk-width-1-1 uk-flex uk-flex-middle uk-grid-collapse pos-radio-label"
                 uk-grid=""
                 :for="checkbox.id"
                 v-for="checkbox in listParents"
                 :key="checkbox.id">

            <input class="pos-checkbox small"
                   :disabled="readonly === 1"
                   v-model="valueInput"
                   name="checkboxes"
                   :id="checkbox.id"
                   :checked="valueInput === checkbox.id"
                   :value="checkbox.id"
                   @change="update"
                   type="checkbox">

            <div class="uk-width-expand uk-margin-small-left">
              <span class="uk-text-truncate"
                    v-text="checkbox.label"/>
            </div>
          </label>

        </div>
      </div>
    </div>
  </li>
</template>

<script>

import {clone} from '@/store/methods'

export default {
  name: 'InputCheckboxes',

  props: {
    value:       {type: [Array, String], default: []},
    name:        '',
    label:       {default: '', type: String},
    placeholder: {default: '', type: String},
    selected:    {},
    readonly:    {default: 0, type: Number},
    required:    {default: 0, type: Number},
    mask:        {type: RegExp}
  },

  mounted () {
    this.valueInput = clone(this.value)
  },

  data () {
    return {
      valueInput: []
    }
  },

  computed: {

    isChanged () {
      return JSON.stringify(this.valueInput) !== JSON.stringify(this.value)
    },

    listParents () {
      return this.$store.getters.treeFlat
    }

  },

  methods: {

    update () {
      this.$emit('change', this.isChanged)
      //this.$emit('value', this.valueInput)
      this.$emit('value', JSON.stringify(this.valueInput))
    }

  }
}
</script>
