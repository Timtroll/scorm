(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-b83c8596"],{4444:function(t,e,s){"use strict";s.r(e);var n=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{},[s("ul",{staticClass:"pos-side-nav"},t._l(t.nav,function(t){return s("li",{key:t.id},[s("NavTreeItem",{attrs:{"nav-item":t}})],1)}),0)])},i=[],a=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",[s("div",{staticClass:"pos-side-nav-item",class:{"uk-active":Number(t.navActiveId)===t.navItem.id}},[t.navItem.children&&t.navItem.children.length>0?s("div",{staticClass:"pos-side-nav-item__icon",on:{click:t.toggleChildren}},[t.opened?s("img",{attrs:{src:"/img/icons/icon__minus.svg","uk-svg":""}}):s("img",{attrs:{src:"/img/icons/icon__plus.svg","uk-svg":""}})]):s("div",{staticClass:"pos-side-nav-item__no-icon"}),s("a",{staticClass:"pos-side-nav-item__label",attrs:{"uk-tooltip":"pos: top-left; delay: 1000; title:"+t.navItem.label},on:{click:function(e){return e.preventDefault(),t.click(t.navItem)}}},[s("span",{staticClass:"pos-side-nav-item__label-text",domProps:{textContent:t._s(t.navItem.label)}}),t.navItem.table&&t.navItem.table.settings&&t.navItem.table.settings.totalCount?s("span",{staticClass:"uk-badge pos-side-nav-item__label-badge",domProps:{textContent:t._s(t.navItem.table.settings.totalCount)}}):t._e(),t.navItem.children&&t.navItem.children.length>0?s("span",{staticClass:"uk-badge pos-side-nav-item__label-badge",domProps:{textContent:t._s(t.navItem.children.length)}}):t._e()]),s("div",{staticClass:"pos-side-nav-item__actions"},[s("a",{staticClass:"pos-side-nav-item-actions__add",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.add")},on:{click:function(e){return e.preventDefault(),t.addChildren(t.navItem.id)}}},[s("img",{attrs:{src:"/img/icons/icon__plus-doc.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),s("a",{staticClass:"pos-side-nav-item-actions__edit",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.edit")},on:{click:function(e){return e.preventDefault(),t.editGroup(t.navItem)}}},[s("img",{attrs:{src:"/img/icons/icon__edit.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),s("a",{staticClass:"pos-side-nav-item-actions__remove",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.remove")},on:{click:function(e){return e.preventDefault(),t.remove(t.navItem.id)}}},[s("img",{attrs:{src:"/img/icons/icon__trash.svg","uk-svg":"",width:"14",height:"14",alt:""}})])])]),t.navItem.children&&t.navItem.children.length>0&&t.opened?s("NavTree",{attrs:{nav:t.navItem.children}}):t._e()],1)},o=[],r=(s("7f7f"),s("c5f6"),s("7514"),s("75fc")),c={name:"NavTreeItem",components:{NavTree:function(){return Promise.resolve().then(s.bind(null,"4444"))}},props:{navItem:{type:Object}},mounted:function(){var t=this;if(this.navItem&&this.navItem.children){var e=Object(r["a"])(this.navItem.children);e&&e.length>0&&(this.opened=!!e.find(function(e){return e.id===Number(t.$store.getters.navActiveId)}))}},data:function(){return{opened:!1}},beforeDestroy:function(){this.$store.commit("cms_page_title","")},computed:{navActiveId:function(){return this.$store.getters.navActiveId},cardLeftClickAction:function(){return this.$store.getters.cardLeftClickAction}},methods:{toggleChildren:function(){this.opened=!this.opened},click:function(t){this.navActiveId!==this.navItem.id&&(this.$store.commit("cms_table_row_show",!1),this.$store.commit("cms_show_add_group",!1),this.$store.commit("tree_active",t.id),this.$store.commit("cms_table",t.table),this.$router.push({name:"SettingItem",params:{id:t.id,title:t.label,item:t}})),this.$store.commit("card_left_nav_click",!this.cardLeftClickAction)},addChildren:function(t){var e={folder:1,lib_id:t,label:"",name:"",editable:1,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!0),this.$store.commit("cms_row_success")},editGroup:function(t){var e={folder:1,lib_id:t.id,label:t.label,name:t.name,editable:t.editable,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!1),this.$store.commit("cms_row_success")},remove:function(t){t&&this.$store.dispatch("removeTableRow",t)}}},l=c,d=s("2877"),u=Object(d["a"])(l,a,o,!1,null,null,null),m=u.exports,h={name:"NavTree",components:{NavTreeItem:m},props:{nav:{type:Array}},computed:{},methods:{}},p=h,v=Object(d["a"])(p,n,i,!1,null,null,null);e["default"]=v.exports},"6b47":function(t,e,s){"use strict";var n=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"uk-flex uk-height-1-1 uk-flex-column"},[s("div",{staticClass:"pos-border-bottom"},[s("div",{staticClass:"uk-grid-collapse",attrs:{"uk-grid":""}},[s("div",{staticClass:"uk-width-auto"},[s("button",{staticClass:"uk-button uk-button-success pos-border-radius-none pos-border-none",attrs:{type:"button"},on:{click:function(e){return e.preventDefault(),t.addRoot(e)}}},[s("img",{attrs:{src:"/img/icons/icon__plus.svg",width:"18",height:"18","uk-svg":""}})])]),s("div",{staticClass:"uk-width-expand"},[s("div",{staticClass:"uk-position-relative"},[t.searchInput?s("a",{staticClass:"uk-form-icon uk-form-icon-flip",on:{click:function(e){return e.preventDefault(),t.clearSearchVal(e)}}},[s("img",{attrs:{src:"/img/icons/icon__close.svg",width:"12",height:"12","uk-svg":""}})]):t._e(),t._m(0),s("input",{directives:[{name:"model",rawName:"v-model",value:t.searchInput,expression:"searchInput"}],staticClass:"uk-input pos-border-radius-none pos-border-none",attrs:{placeholder:t.$t("actions.search")},domProps:{value:t.searchInput},on:{keyup:function(e){return!e.type.indexOf("key")&&t._k(e.keyCode,"esc",27,e.key,["Esc","Escape"])?null:t.clearSearchVal(e)},input:function(e){e.target.composing||(t.searchInput=e.target.value)}}})])])])]),s("div",{staticClass:"pos-side-nav-container"},[t.filterSearch.length>0?s("NavTree",{attrs:{nav:t.filterSearch}}):s("div",{staticClass:"uk-flex uk-height-1-1 uk-flex-center uk-flex-middle uk-text-center"},[s("div",[s("IconBug",{attrs:{size:100,spin:!0}}),s("p",{domProps:{innerHTML:t._s(t.$t("actions.searchError"))}})],1)])],1)])},i=[function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"uk-form-icon"},[s("img",{attrs:{src:"/img/icons/icon__search.svg",width:"14",height:"14","uk-svg":""}})])}],a=(s("ac6a"),s("4444")),o=s("0919"),r={components:{IconBug:o["a"],NavTree:a["default"]},name:"Tree",props:{nav:{type:Array}},data:function(){return{searchInput:null}},computed:{flattenNav:function(){if(this.searchInput){var t=this.nav,e=[],s=function t(s){s.forEach(function(s){var n={label:s.label,id:s.id,keywords:s.keywords,component:s.component,opened:s.opened,table:s.table,children:s.children};1!==s.folder&&e.push(n),s.children&&s.children.length>0&&t(s.children)})};return s(t),e}return this.nav},filterSearch:function(){var t=this;return this.flattenNav.filter(function(e){return!t.searchInput||e.label.toLowerCase().indexOf(t.searchInput.toLowerCase())>-1||e.keywords.toLowerCase().indexOf(t.searchInput.toLowerCase())>-1})}},methods:{addRoot:function(){var t={folder:1,lib_id:0,label:"",name:"",editable:1,readOnly:0,removable:1};this.$store.commit("cms_add_group",t),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!0),this.$store.commit("cms_row_success")},clearSearchVal:function(){this.searchInput=null}}},c=r,l=s("2877"),d=Object(l["a"])(c,n,i,!1,null,null,null);e["a"]=d.exports},"77b2":function(t,e,s){"use strict";s.r(e);var n=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("Card",{attrs:{header:!1,footer:!1,"body-left":!0,"body-left-padding":!1,"body-left-toggle-show":!0,"body-right":!0,"body-right-show":t.pageTableAddGroupShow,"body-padding":!1,loader:t.loader},scopedSlots:t._u([{key:"body",fn:function(){return[s("transition",{attrs:{name:"slide-right",mode:"out-in",appear:""}},[s("router-view")],1)]},proxy:!0},{key:"bodyLeft",fn:function(){return[t.nav?s("Tree",{attrs:{nav:t.nav}}):t._e()]},proxy:!0},{key:"bodyRight",fn:function(){return[s("List",{attrs:{data:t.pageTableAddGroupData,labels:"Добавить группу настроек",add:t.pageTableAddEditGroup,group:!0},on:{close:t.closeAddGroup}})]},proxy:!0}])})},i=[],a=s("0ae7"),o=s("4444"),r=s("6b47"),c=s("0919"),l=s("4564"),d=s("6807"),u={name:"Settings",components:{IconBug:c["a"],Tree:r["a"],NavTree:o["default"],Card:a["a"],Loader:l["default"],List:d["a"]},data:function(){return{leftNavToggleMobile:!1}},created:function(){this.$store.dispatch("getTree")},beforeDestroy:function(){this.$store.commit("cms_table_row_show",!1)},computed:{pageTableAddGroupShow:function(){return this.$store.getters.pageTableAddGroupShow},pageTableAddGroupData:function(){return this.$store.getters.pageTableAddGroupData},pageTableAddEditGroup:function(){return this.$store.getters.pageTableAddEditGroup},pageTable:function(){return this.$store.state.cms.navTree.items},loader:function(){return this.$store.getters.queryStatus},nav:function(){return this.$store.getters.Settings},cardLeftClickAction:function(){return this.$store.getters.cardLeftClickAction}},methods:{clearSearchVal:function(){this.table.searchInput=null},closeAddGroup:function(){this.$store.commit("cms_show_add_group",!1)}}},m=u,h=s("2877"),p=Object(h["a"])(m,n,i,!1,null,null,null);e["default"]=p.exports}}]);