(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-77ca3df8"],{"0a49":function(t,e,i){var n=i("9b43"),s=i("626a"),a=i("4bf8"),r=i("9def"),o=i("cd1c");t.exports=function(t,e){var i=1==t,c=2==t,l=3==t,d=4==t,u=6==t,m=5==t||u,v=e||o;return function(e,o,h){for(var p,_,f=a(e),g=s(f),b=n(o,h,3),I=r(g.length),k=0,$=i?v(e,I):c?v(e,0):void 0;I>k;k++)if((m||k in g)&&(p=g[k],_=b(p,k,f),t))if(i)$[k]=_;else if(_)switch(t){case 3:return!0;case 5:return p;case 6:return k;case 2:$.push(p)}else if(d)return!1;return u?-1:l||d?d:$}}},"5a8e":function(t,e,i){"use strict";i.r(e);var n=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("div",{},[i("ul",{staticClass:"pos-side-nav"},t._l(t.nav,function(t){return i("li",{key:t.id},[i("NavTreeItem",{attrs:{"nav-item":t}})],1)}),0)])},s=[],a=function(){var t=this,e=t.$createElement,i=t._self._c||e;return i("div",[i("div",{staticClass:"pos-side-nav-item",class:{"uk-active":Number(t.navActiveId)===t.navItem.id}},[t.navItem.children&&t.navItem.children.length>0?i("div",{staticClass:"pos-side-nav-item__icon",on:{click:t.toggleChildren}},[t.opened?i("img",{attrs:{src:"/img/icons/icon__minus.svg","uk-svg":""}}):i("img",{attrs:{src:"/img/icons/icon__plus.svg","uk-svg":""}})]):i("div",{staticClass:"pos-side-nav-item__no-icon"}),i("a",{staticClass:"pos-side-nav-item__label",attrs:{"uk-tooltip":"pos: top-left; delay: 1000; title:"+t.navItem.label},on:{click:function(e){return e.preventDefault(),t.click(t.navItem)}}},[i("span",{staticClass:"pos-side-nav-item__label-text",domProps:{textContent:t._s(t.navItem.name)}}),t.navItem.children&&t.navItem.children.length>0?i("span",{staticClass:"uk-badge pos-side-nav-item__label-badge",domProps:{textContent:t._s(t.navItem.children.length)}}):t._e()]),i("div",{staticClass:"pos-side-nav-item__actions"},[i("a",{staticClass:"pos-side-nav-item-actions__add",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.add")},on:{click:function(e){return e.preventDefault(),t.addChildren(t.navItem.id)}}},[i("img",{attrs:{src:"/img/icons/icon__plus-doc.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),i("a",{staticClass:"pos-side-nav-item-actions__edit",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.edit")},on:{click:function(e){return e.preventDefault(),t.editGroup(t.navItem)}}},[i("img",{attrs:{src:"/img/icons/icon__edit.svg","uk-svg":"",width:"14",height:"14",alt:""}})]),i("a",{staticClass:"pos-side-nav-item-actions__remove",attrs:{"uk-tooltip":"pos: top-right; delay: 1000; title:"+t.$t("actions.remove")},on:{click:function(e){return e.preventDefault(),t.remove(t.navItem.id)}}},[i("img",{attrs:{src:"/img/icons/icon__trash.svg","uk-svg":"",width:"14",height:"14",alt:""}})])])]),t.navItem.children&&t.navItem.children.length>0&&t.opened?i("NavTree",{attrs:{nav:t.navItem.children}}):t._e()],1)},r=[],o=(i("7f7f"),i("c5f6"),i("7514"),i("75fc")),c={name:"NavTreeItem",components:{NavTree:function(){return Promise.resolve().then(i.bind(null,"5a8e"))}},props:{navItem:{type:Object}},mounted:function(){var t=this;if(this.navItem&&this.navItem.children){var e=Object(o["a"])(this.navItem.children);e&&e.length>0&&(this.opened=!!e.find(function(e){return e.id===Number(t.$store.getters.activeId)}))}},data:function(){return{opened:!1}},beforeDestroy:function(){this.$store.commit("page_title","")},computed:{tree_api:function(){return this.$store.getters.tree_api},table_api:function(){return this.$store.getters.table_api},navActiveId:function(){return this.$store.getters.activeId},cardLeftClickAction:function(){return this.$store.getters.cardLeftClickAction}},methods:{toggleChildren:function(){this.opened=!this.opened},click:function(t){this.navItem.children&&this.navItem.children.length>0?this.toggleChildren():(this.navActiveId!==this.navItem.id&&(this.$store.commit("card_right_show",!1),this.$store.commit("tree_active",t.id),this.$store.dispatch(this.table_api.get,t.id),this.$router.push({name:"SettingItem",params:{id:t.id,title:t.label}})),this.$store.commit("card_left_nav_click",!this.cardLeftClickAction))},addChildren:function(t){var e={folder:1,lib_id:t,label:"",name:"",editable:1,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("editPanel_group",!0),this.$store.commit("cms_show_add_edit_toggle",!0),this.$store.commit("editPanel_status_success")},editGroup:function(t){var e={folder:1,lib_id:t.id,label:t.label,name:t.name,editable:t.editable,readOnly:0,removable:1};this.$store.commit("cms_add_group",e),this.$store.commit("editPanel_group",!0),this.$store.commit("cms_show_add_edit_toggle",!1),this.$store.commit("editPanel_status_success")},remove:function(t){t&&this.$store.dispatch(this.tree_api.remove,t)}}},l=c,d=i("2877"),u=Object(d["a"])(l,a,r,!1,null,null,null),m=u.exports,v={name:"NavTree",components:{NavTreeItem:m},props:{nav:{type:Array}}},h=v,p=Object(d["a"])(h,n,s,!1,null,null,null);e["default"]=p.exports},7514:function(t,e,i){"use strict";var n=i("5ca1"),s=i("0a49")(5),a="find",r=!0;a in[]&&Array(1)[a](function(){r=!1}),n(n.P+n.F*r,"Array",{find:function(t){return s(this,t,arguments.length>1?arguments[1]:void 0)}}),i("9c6c")(a)},cd1c:function(t,e,i){var n=i("e853");t.exports=function(t,e){return new(n(t))(e)}},e853:function(t,e,i){var n=i("d3f4"),s=i("1169"),a=i("2b4c")("species");t.exports=function(t){var e;return s(t)&&(e=t.constructor,"function"!=typeof e||e!==Array&&!s(e.prototype)||(e=void 0),n(e)&&(e=e[a],null===e&&(e=void 0))),void 0===e?Array:e}}}]);