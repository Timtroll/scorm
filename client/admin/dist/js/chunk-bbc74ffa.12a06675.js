(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-bbc74ffa"],{4444:function(t,e,a){"use strict";a.r(e);var s=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{},[a("ul",{staticClass:"pos-side-nav"},t._l(t.nav,function(e){return a("li",{key:e.id},[a("NavTreeItem",{attrs:{"nav-item":e},on:{click:function(e){return t.click(e)}}})],1)}),0)])},i=[],n=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",[a("div",{staticClass:"pos-side-nav-item",class:{"uk-active":t.navActiveId===t.navItem.id}},[t.navItem.children&&t.navItem.children.length>0?a("div",{staticClass:"pos-side-nav-item__icon",on:{click:t.toggleChildren}},[t.opened?a("img",{attrs:{src:"/img/icons/icon__minus.svg","uk-svg":""}}):a("img",{attrs:{src:"/img/icons/icon__plus.svg","uk-svg":""}})]):a("div",{staticClass:"pos-side-nav-item__no-icon"}),a("a",{staticClass:"pos-side-nav-item__label",attrs:{"uk-tooltip":"pos: top-left; delay: 1000; title:"+t.navItem.label},on:{click:function(e){return e.preventDefault(),t.click(t.navItem)}}},[a("span",{staticClass:"pos-side-nav-item__label-text",domProps:{textContent:t._s(t.navItem.label)}}),t.navItem.table&&t.navItem.table.settings&&t.navItem.table.settings.totalCount?a("span",{staticClass:"uk-badge pos-side-nav-item__label-badge",domProps:{textContent:t._s(t.navItem.table.settings.totalCount)}}):t._e()]),a("div",{staticClass:"pos-side-nav-item__actions"},[a("a",{staticClass:"pos-side-nav-item-actions__add",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.add")},on:{click:function(e){return e.preventDefault(),t.addChildren(t.navItem.id)}}},[a("img",{attrs:{src:"/img/icons/icon__plus-doc.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),a("a",{staticClass:"pos-side-nav-item-actions__edit",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.edit")},on:{click:function(e){return e.preventDefault(),t.editGroup(t.navItem)}}},[a("img",{attrs:{src:"/img/icons/icon__edit.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),a("a",{staticClass:"pos-side-nav-item-actions__remove",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.remove")},on:{click:function(e){return e.preventDefault(),t.remove(t.navItem.id)}}},[a("img",{attrs:{src:"/img/icons/icon__trash.svg","uk-svg":"",width:"14",height:"14",alt:""}})])])]),t.navItem.children&&t.navItem.children.length>0&&t.opened?a("NavTree",{attrs:{nav:t.navItem.children}}):t._e()],1)},o=[],r=(a("7f7f"),{name:"NavTreeItem",components:{NavTree:function(){return Promise.resolve().then(a.bind(null,"4444"))}},props:{navItem:{type:Object}},data:function(){return{opened:!1}},beforeDestroy:function(){this.$store.commit("cms_page_title","")},computed:{navActiveId:function(){return this.$store.state.cms.cms.activeId}},methods:{toggleChildren:function(){this.opened=!this.opened},click:function(t){this.navActiveId!==this.navItem.id&&(this.$store.commit("cms_table_row_show",!1),this.$store.commit("cms_show_add_group",!1),this.$store.commit("tree_active",t.id),this.$store.commit("cms_table",t.table),this.$router.push({name:"SettingItem",params:{id:t.id,title:t.label,item:t}}))},addChildren:function(t){var e={folder:1,lib_id:t,label:"",name:"",editable:1,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!0),this.$store.commit("cms_row_success")},editGroup:function(t){var e={folder:1,lib_id:t.id,label:t.label,name:t.name,editable:t.editable,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!1),this.$store.commit("cms_row_success")},remove:function(t){t&&this.$store.dispatch("removeTableRow",t)}}}),c=r,l=a("2877"),d=Object(l["a"])(c,n,o,!1,null,null,null),u=d.exports,m={name:"NavTree",components:{NavTreeItem:u},props:{nav:{type:Array}},methods:{click:function(t){this.$emit("click",t)}}},p=m,h=Object(l["a"])(p,s,i,!1,null,null,null);e["default"]=h.exports},"77b2":function(t,e,a){"use strict";a.r(e);var s=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("Card",{attrs:{header:!1,footer:!1,"body-left":!0,"body-left-padding":!1,"body-left-toggle-show":!0,"body-right":!0,"body-right-show":t.pageTableAddGroupShow,"body-padding":!1,loader:t.loader},scopedSlots:t._u([{key:"body",fn:function(){return[a("transition",{attrs:{name:"slide-right",mode:"out-in",appear:""}},[a("router-view")],1)]},proxy:!0},{key:"bodyLeft",fn:function(){return[t.nav?a("Tree",{attrs:{nav:t.nav},on:{close:function(t){}}}):t._e()]},proxy:!0},{key:"bodyRight",fn:function(){return[a("List",{attrs:{data:t.pageTableAddGroupData,labels:"Добавить группу настроек",add:t.pageTableAddEditGroup,group:!0},on:{close:t.closeAddGroup}})]},proxy:!0}])})},i=[],n=a("0ae7"),o=a("4444"),r=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"uk-flex uk-height-1-1 uk-flex-column"},[a("div",{staticClass:"pos-border-bottom"},[a("div",{staticClass:"uk-grid-collapse",attrs:{"uk-grid":""}},[a("div",{staticClass:"uk-width-expand"},[a("div",{staticClass:"uk-position-relative"},[t.searchInput?a("a",{staticClass:"uk-form-icon uk-form-icon-flip",on:{click:function(e){return e.preventDefault(),t.clearSearchVal(e)}}},[a("img",{attrs:{src:"/img/icons/icon__close.svg",width:"12",height:"12","uk-svg":""}})]):t._e(),t._m(0),a("input",{directives:[{name:"model",rawName:"v-model",value:t.searchInput,expression:"searchInput"}],staticClass:"uk-input pos-border-radius-none pos-border-none",attrs:{placeholder:t.$t("actions.search")},domProps:{value:t.searchInput},on:{keyup:function(e){return!e.type.indexOf("key")&&t._k(e.keyCode,"esc",27,e.key,["Esc","Escape"])?null:t.clearSearchVal(e)},input:function(e){e.target.composing||(t.searchInput=e.target.value)}}})])]),a("div",{staticClass:"uk-width-auto"},[a("button",{staticClass:"uk-button pos-border-radius-none pos-border-none",attrs:{type:"button"},on:{click:function(e){return e.preventDefault(),t.addRoot(e)}}},[a("img",{attrs:{src:"/img/icons/icon__plus.svg",width:"18",height:"18","uk-svg":""}})])])])]),a("div",{staticClass:"pos-side-nav-container"},[t.filterSearch.length>0?a("NavTree",{attrs:{nav:t.filterSearch}}):a("div",{staticClass:"uk-flex uk-height-1-1 uk-flex-center uk-flex-middle uk-text-center"},[a("div",[a("IconBug",{attrs:{size:100,spin:!0}}),a("p",[t._v("Это сложно для меня. "),a("br"),t._v("Говори проще")])],1)])],1)])},c=[function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"uk-form-icon"},[a("img",{attrs:{src:"/img/icons/icon__search.svg",width:"14",height:"14","uk-svg":""}})])}],l=(a("ac6a"),function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("svg",{class:{spin:t.spin},attrs:{xmlns:"http://www.w3.org/2000/svg",viewBox:"0 0 48 48",width:t.size}},[a("path",{staticClass:"bug-inside",attrs:{d:"M24,11.53A12.47,12.47,0,1,0,36.47,24,12.48,12.48,0,0,0,24,11.53Zm4.91,21.85a10.57,10.57,0,0,1-9.82,0V31.07l.32-.33a4.83,4.83,0,0,0,4.12,2.32h.94a4.83,4.83,0,0,0,4.12-2.32l.32.33v2.31ZM23.06,23v3.63a.94.94,0,0,0,1.88,0V23a3,3,0,0,1,2.47,2.91v2.32a2.94,2.94,0,0,1-2.94,2.94h-.94a2.94,2.94,0,0,1-2.94-2.94V25.92A3,3,0,0,1,23.06,23Zm-.45-1.82A1.39,1.39,0,0,1,24,20a1.37,1.37,0,0,1,1.37,1.18,5.05,5.05,0,0,0-.88-.08h-.94A4.7,4.7,0,0,0,22.61,21.19Zm8.18,10.94V30.68a.91.91,0,0,0-.28-.66l-1.25-1.26c0-.17,0-.34,0-.52v-1h2.46a.94.94,0,1,0,0-1.87H29.25a5,5,0,0,0-.3-1.22l1.56-1.56a1,1,0,0,0,.28-.67V19.67a.94.94,0,0,0-1.88,0v1.87l-1,1a4.5,4.5,0,0,0-.66-.57v-.6a3.24,3.24,0,0,0-1-2.32,3.22,3.22,0,0,0,1-2.29.94.94,0,0,0-1.88,0,1.35,1.35,0,0,1-2.7,0,.94.94,0,1,0-1.88,0A3.2,3.2,0,0,0,21.71,19a3.25,3.25,0,0,0-1,2.34V22a4.08,4.08,0,0,0-.63.54l-1-1V19.67a.94.94,0,0,0-1.88,0v2.25a1,1,0,0,0,.28.67l1.56,1.56a5,5,0,0,0-.3,1.22H16.26a.94.94,0,1,0,0,1.87h2.46v1c0,.18,0,.35,0,.52L17.49,30a.91.91,0,0,0-.28.66v1.45a10.59,10.59,0,1,1,13.58,0Z"}}),a("g",{staticClass:"bag-outside"},[a("path",{attrs:{d:"M38.09,42.34a1,1,0,0,0-1.3-.29l0,0a.94.94,0,0,0,1,1.57l0,0A.94.94,0,0,0,38.09,42.34Z"}}),a("path",{attrs:{d:"M34.87,44.35a.93.93,0,0,0-1.25-.42.94.94,0,0,0,.4,1.78.9.9,0,0,0,.4-.09h0A.94.94,0,0,0,34.87,44.35Z"}}),a("path",{attrs:{d:"M31.48,45.84a.94.94,0,0,0-1.17-.63,22.32,22.32,0,0,1-13.73-.36.93.93,0,0,0-1.19.57.94.94,0,0,0,.56,1.2,24.18,24.18,0,0,0,14.9.39A.94.94,0,0,0,31.48,45.84Z"}}),a("path",{attrs:{d:"M11.2,4.84a.94.94,0,1,0-.78,1.45,1,1,0,0,0,.52-.15h0A.93.93,0,0,0,11.2,4.84Z"}}),a("path",{attrs:{d:"M14.26,3.07a.94.94,0,0,0-1.67.86.92.92,0,0,0,.83.51.87.87,0,0,0,.44-.11h0A.93.93,0,0,0,14.26,3.07Z"}}),a("path",{attrs:{d:"M33,1.74a24.07,24.07,0,0,0-16.73-.46,1,1,0,0,0-.59,1.19.93.93,0,0,0,1.19.58A22.19,22.19,0,0,1,24,1.88a21.87,21.87,0,0,1,8.28,1.6,1,1,0,0,0,.35.06A.93.93,0,0,0,33,1.74Z"}}),a("path",{attrs:{d:"M43.26,9.68a3.49,3.49,0,0,0,.61-2,3.56,3.56,0,1,0-3.56,3.56,3.46,3.46,0,0,0,1.53-.34A22.18,22.18,0,0,1,44.5,32.33.94.94,0,0,0,45,33.55a1.15,1.15,0,0,0,.35.07.94.94,0,0,0,.87-.59,24,24,0,0,0-3-23.35ZM41.5,8.89A1.69,1.69,0,1,1,40.31,6a1.67,1.67,0,0,1,1.19.49A1.69,1.69,0,0,1,41.5,8.89Z"}}),a("path",{attrs:{d:"M9.68,38.32a2.83,2.83,0,0,0-3-.62A21.86,21.86,0,0,1,1.88,24,22.13,22.13,0,0,1,3,17.13a.94.94,0,0,0-1.78-.58A24,24,0,0,0,0,24,23.73,23.73,0,0,0,5.21,38.93l0,0A2.81,2.81,0,0,0,9.68,42.3h0A2.81,2.81,0,0,0,9.68,38.32ZM8.36,41a1,1,0,0,1-.67.28,1,1,0,0,1-.94-.94A1,1,0,0,1,7,39.64a.93.93,0,0,1,.66-.27,1,1,0,0,1,.67.27A1,1,0,0,1,8.36,41Z"}}),a("path",{attrs:{d:"M8.36,7a1,1,0,0,0-.67-.28,1,1,0,0,0-.94.94A1,1,0,0,0,7,8.36a1,1,0,0,0,.66.27.92.92,0,0,0,.94-.94A1,1,0,0,0,8.36,7Z"}}),a("path",{attrs:{d:"M41,39.65a.92.92,0,0,0-.66-.28,1,1,0,0,0-.94.94.92.92,0,0,0,.28.66,1,1,0,0,0,.66.28A.92.92,0,0,0,41,41a1,1,0,0,0,.28-.66A.91.91,0,0,0,41,39.65Z"}})]),a("g",{staticClass:"bag-middle"},[a("path",{attrs:{d:"M24,37.41a3.57,3.57,0,0,0-3.32,2.28A16.09,16.09,0,0,1,9.74,31.34a.93.93,0,1,0-1.66.85,18,18,0,0,0,12.41,9.37A3.56,3.56,0,1,0,24,37.41Zm0,5.25A1.69,1.69,0,1,1,25.69,41,1.69,1.69,0,0,1,24,42.66Z"}}),a("path",{attrs:{d:"M40.91,25.69a.94.94,0,0,0-1.07.78,16.09,16.09,0,0,1-8.2,11.62.94.94,0,0,0,.45,1.77.92.92,0,0,0,.45-.12,17.91,17.91,0,0,0,9.15-13A.94.94,0,0,0,40.91,25.69Z"}}),a("path",{attrs:{d:"M16.67,8.66a.94.94,0,0,0-1.27-.37,18.08,18.08,0,0,0-6,5.36,17.85,17.85,0,0,0-3.08,7.59.94.94,0,0,0,.78,1.07h.14a.94.94,0,0,0,.93-.79A16.1,16.1,0,0,1,16.3,9.94,1,1,0,0,0,16.67,8.66Z"}}),a("path",{attrs:{d:"M39.45,15A17.8,17.8,0,0,0,26.76,6.31h-.05a2.8,2.8,0,1,0-.13,1.88A15.94,15.94,0,0,1,37.83,15.9a1,1,0,0,0,.81.46.91.91,0,0,0,.48-.13A.94.94,0,0,0,39.45,15ZM24,8a.94.94,0,1,1,.94-.93A.94.94,0,0,1,24,8Z"}})])])}),d=[],u=(a("c5f6"),{name:"IconBug",props:{spin:{type:Boolean,default:!0},size:{type:Number,default:24}}}),m=u,p=(a("b339"),a("2877")),h=Object(p["a"])(m,l,d,!1,null,"6ee4b151",null),v=h.exports,g={components:{IconBug:v,NavTree:o["default"]},name:"Tree",props:{nav:{type:Array}},data:function(){return{searchInput:null}},computed:{flattenNav:function(){if(this.searchInput){var t=this.nav,e=[],a=function t(a){a.forEach(function(a){var s={label:a.label,id:a.id,keywords:a.keywords,component:a.component,opened:a.opened,table:a.table};e.push(s),a.children&&a.children.length>0&&t(a.children)})};return a(t),e}return this.nav},filterSearch:function(){var t=this;return this.flattenNav.filter(function(e){return!t.searchInput||e.label.toLowerCase().indexOf(t.searchInput.toLowerCase())>-1||e.keywords.toLowerCase().indexOf(t.searchInput.toLowerCase())>-1})}},methods:{addRoot:function(){var t={folder:1,lib_id:0,label:"",name:"",editable:1,readOnly:0,removable:1};this.$store.commit("cms_add_group",t),this.$store.commit("cms_show_add_group",!0),this.$store.commit("cms_show_add_edit_toggle",!0),this.$store.commit("cms_row_success")},clearSearchVal:function(){this.searchInput=null}}},f=g,_=Object(p["a"])(f,r,c,!1,null,null,null),b=_.exports,k=a("4564"),w=a("6807"),A={name:"Settings",components:{IconBug:v,Tree:b,NavTree:o["default"],Card:n["a"],Loader:k["default"],List:w["a"]},data:function(){return{}},created:function(){this.$store.dispatch("getTree")},beforeDestroy:function(){this.$store.commit("cms_table_row_show",!1)},computed:{pageTableAddGroupShow:function(){return this.$store.getters.pageTableAddGroupShow},pageTableAddGroupData:function(){return this.$store.getters.pageTableAddGroupData},pageTableAddEditGroup:function(){return this.$store.getters.pageTableAddEditGroup},pageTable:function(){return this.$store.state.cms.navTree.items},loader:function(){return this.$store.getters.queryStatus},nav:function(){return this.$store.getters.Settings}},methods:{clearSearchVal:function(){this.table.searchInput=null},closeAddGroup:function(){this.$store.commit("cms_show_add_group",!1)}}},y=A,I=Object(p["a"])(y,s,i,!1,null,null,null);e["default"]=I.exports},b339:function(t,e,a){"use strict";var s=a("b578"),i=a.n(s);i.a},b578:function(t,e,a){}}]);