(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-23197502"],{"06c3":function(t,e,s){t.exports=s.p+"img/logo__bw.935d04f9.svg"},"0ef3":function(t,e,s){"use strict";var a=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"pos-sidebar uk-light",attrs:{id:"sidebar"}},[a("div",{staticClass:"pos-sidebar-top uk-visible@m"},[a("router-link",{attrs:{to:{name:"Main"}}},[a("img",{staticClass:"pos-sidebar-logo",attrs:{src:s("06c3"),"uk-svg":""}})])],1),a("div",{staticClass:"pos-sidebar-middle uk-light"},[a("ul",{staticClass:"pos-sidebar--nav"},t._l(t.menu,function(e,s){return a("router-link",{key:s,attrs:{tag:"li","exact-active-class":"uk-active","active-class":"uk-active",to:e.path,append:"",exact:""}},[a("a",{attrs:{"uk-tooltip":"",pos:t.tooltipPosition,title:e.meta.breadcrumb}},[a("img",{attrs:{src:e.meta.icon,"uk-svg":"",width:"24",height:"24"}})])])}),1)]),a("div",{staticClass:"pos-sidebar-bottom"},[a("SideBarUserMenu",{attrs:{size:30,width:1}})],1)])},i=[],n=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("ul",{staticClass:"pos-sidebar--nav"},[s("router-link",{attrs:{tag:"li",to:{name:"Settings"},"active-class":"uk-active",exact:""}},[s("a",[s("icon-setting",{attrs:{spin:!0}})],1)])],1)},r=[],o=(s("c5f6"),s("2b2f")),l={name:"SideBarSettings",components:{IconSetting:o["a"]},props:{size:{type:Number,default:24},width:{type:Number,default:1}}},c=l,u=s("2877"),d=Object(u["a"])(c,n,r,!1,null,null,null),f=d.exports,p={name:"SideBar",components:{SideBarUserMenu:f},mounted:function(){window.addEventListener("resize",this.handleResize)},beforeDestroy:function(){window.removeEventListener("resize",this.handleResize)},data:function(){return{width:window.innerWidth}},computed:{tooltipPosition:function(){var t="right";return t=this.width<=768?"top":"right",t},menu:function(){return this.$router.options.routes.filter(function(t){return t.sideMenuParent})[0].children.filter(function(t){return t.showInSideBar})}},methods:{handleResize:function(t){var e=this;setTimeout(function(){e.width=window.innerWidth},300)}}},m=p,g=Object(u["a"])(m,a,i,!1,null,"8a7ac420",null);e["a"]=g.exports},"2b2f":function(t,e,s){"use strict";var a=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("svg",{class:{"icon-hover-spin":t.spin},attrs:{xmlns:"http://www.w3.org/2000/svg",width:t.size,height:t.size,viewBox:"0 0 26 26"}},[s("circle",{attrs:{cx:"13",cy:"13",r:"1.5",opacity:".6",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}}),s("path",{staticClass:"inside",attrs:{d:"M5.89,15.37A7.5,7.5,0,0,0,7.39,18l2.7-1.56a4.43,4.43,0,0,0,5.82,0L18.61,18a7.5,7.5,0,0,0,1.5-2.6l-2.69-1.55a4.44,4.44,0,0,0-2.92-5V5.65a7.57,7.57,0,0,0-3,0V8.78a4.44,4.44,0,0,0-2.92,5Z",fill:"none",stroke:"#fff",opacity:".6","stroke-linecap":"round","stroke-linejoin":"round"}}),s("circle",{attrs:{cx:"13",cy:"13",r:"7.5",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}}),s("path",{staticClass:"outside",attrs:{d:"M25.39,11.41l-2-.08A10.38,10.38,0,0,0,21.5,6.86l1.38-1.5a12.5,12.5,0,0,0-2.24-2.24L19.14,4.5a10.38,10.38,0,0,0-4.47-1.85l-.08-2A13.84,13.84,0,0,0,13,.5a13.84,13.84,0,0,0-1.59.11l-.08,2A10.38,10.38,0,0,0,6.86,4.5L5.36,3.12A12.5,12.5,0,0,0,3.12,5.36L4.5,6.86a10.38,10.38,0,0,0-1.85,4.47l-2,.08A13.84,13.84,0,0,0,.5,13a13.84,13.84,0,0,0,.11,1.59l2,.08A10.38,10.38,0,0,0,4.5,19.14l-1.38,1.5a12.5,12.5,0,0,0,2.24,2.24l1.5-1.38a10.38,10.38,0,0,0,4.47,1.85l.08,2A13.84,13.84,0,0,0,13,25.5a13.84,13.84,0,0,0,1.59-.11l.08-2a10.38,10.38,0,0,0,4.47-1.85l1.5,1.38a12.5,12.5,0,0,0,2.24-2.24l-1.38-1.5a10.38,10.38,0,0,0,1.85-4.47l2-.08A13.84,13.84,0,0,0,25.5,13,13.84,13.84,0,0,0,25.39,11.41Z",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}})])},i=[],n=(s("c5f6"),{name:"IconSetting",props:{spin:{type:Boolean,default:!1},size:{type:Number,default:26},width:{type:Number,default:1}}}),r=n,o=(s("7945"),s("2877")),l=Object(o["a"])(r,a,i,!1,null,null,null);e["a"]=l.exports},"2ca2":function(t,e,s){t.exports=s.p+"img/user_profile.3ee91a36.svg"},"57bd":function(t,e,s){},7945:function(t,e,s){"use strict";var a=s("57bd"),i=s.n(a);i.a},a5b5:function(t,e,s){"use strict";s.r(e);var a=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"pos-body"},[s("div",{staticClass:"pos-main"},[s("div",{staticClass:"pos-container"},[s("div",{staticClass:"pos-content uk-flex uk-flex-middle uk-flex-center uk-text-center"},[s("div",[s("p",{staticClass:"uk-heading-2xlarge",domProps:{textContent:t._s(t.$t("err404.title"))}}),s("p",{staticClass:"uk-h4 uk-text-lowercase uk-margin-remove uk-text-muted",domProps:{textContent:t._s(t.$t("err404.content"))}})])]),s("NavBar")],1),s("SideBar")],1)])},i=[],n=s("0ef3"),r=s("bf06"),o={name:"PageNotFound",components:{NavBar:r["a"],SideBar:n["a"]},metaInfo:function(){return{title:this.$t("auth.title"),titleTemplate:"%s - Scorm",htmlAttrs:{lang:this.$t("app.lang")}}},data:function(){return{}}},l=o,c=s("2877"),u=Object(c["a"])(l,a,i,!1,null,null,null);e["default"]=u.exports},bf06:function(t,e,s){"use strict";var a=function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"pos-navbar"},[t.leftToggle.visibility?s("div",{staticClass:"pos-navbar-left"},[s("div",{staticClass:"pos-navbar-item"},[s("a",{staticClass:"pos-card-header-item link",class:{"uk-text-danger":t.leftToggleState},on:{click:function(e){return e.preventDefault(),t.leftToggleAction(e)}}},[s("img",{attrs:{src:"/img/icons/"+t.leftToggle.icon,"uk-svg":"",width:"20",height:"20"}})])])]):t._e(),s("div",{staticClass:"pos-navbar-middle"},[s("div",{staticClass:"pos-navbar__title",domProps:{innerHTML:t._s(t.pageTitle)}})]),s("div",{staticClass:"pos-navbar-right"},[t._m(0),s("NavBarUserMenu")],1)])},i=[function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("a",{staticClass:"pos-navbar-item"},[s("img",{attrs:{src:"/img/icons/user_profile.svg","uk-svg":"",width:"24",height:"24"}})])}],n=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"uk-navbar-dropdown uk-dropdown-small",attrs:{"uk-dropdown":"mode: click; offset: 10; pos: bottom-right; animation: uk-animation-slide-right-medium"}},[a("ul",{staticClass:"uk-nav uk-navbar-dropdown-nav"},[a("router-link",{attrs:{tag:"li",to:{name:"Profile"},"active-class":"uk-active",exact:""}},[a("a",[a("img",{staticClass:"uk-margin-small-right",attrs:{src:s("2ca2"),"uk-svg":"",width:"16",height:"16"}}),t._v("\n        Профиль пользователя")])]),a("li",[a("a",{on:{click:function(e){return e.preventDefault(),t.signOut(e)}}},[a("img",{staticClass:"uk-margin-small-right",attrs:{src:s("c4b0"),"uk-svg":"",width:"16",height:"16"}}),t._v("\n        Выйти\n      ")])])],1)])},r=[],o=(s("c5f6"),s("8323")),l=s.n(o),c=s("2b2f"),u={name:"NavBarUserMenu",components:{IconSetting:c["a"]},props:{size:{type:Number,default:24},width:{type:Number,default:1}},methods:{signOut:function(){var t=this;l.a.modal.confirm("Выйти из системы!",{labels:{ok:"Выйти",cancel:"Остаться в системе"}}).then(function(){t.$store.dispatch("logout")})}}},d=u,f=s("2877"),p=Object(f["a"])(d,n,r,!1,null,null,null),m=p.exports,g={name:"NavBar",components:{NavBarUserMenu:m},data:function(){return{}},computed:{leftToggle:function(){return this.$store.getters.cardLeftAction},leftToggleState:function(){return this.$store.getters.cardLeftState},pageTitle:function(){return this.$route.params.title?'<span class="uk-text-muted">'+this.$route.meta.breadcrumb+":</span> "+this.$route.params.title:this.$route.meta.breadcrumb}},methods:{leftToggleAction:function(){this.$store.commit("card_left_state",!this.leftToggleState)}}},v=g,h=Object(f["a"])(v,a,i,!1,null,null,null);e["a"]=h.exports},c4b0:function(t,e,s){t.exports=s.p+"img/user_logout.ae475479.svg"}}]);