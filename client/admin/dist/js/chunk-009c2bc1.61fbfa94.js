(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-009c2bc1"],{"06c3":function(t,e,n){t.exports=n.p+"img/logo__bw.935d04f9.svg"},"0ef3":function(t,e,n){"use strict";var a=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"pos-sidebar uk-light",attrs:{id:"sidebar"}},[a("div",{staticClass:"pos-sidebar-top uk-visible@m"},[a("router-link",{attrs:{to:{name:"Main"}}},[a("img",{staticClass:"pos-sidebar-logo",attrs:{src:n("06c3"),"uk-svg":""}})])],1),a("div",{staticClass:"pos-sidebar-middle uk-light"},[a("ul",{staticClass:"pos-sidebar--nav"},t._l(t.menu,function(e,n){return a("router-link",{key:n,attrs:{tag:"li","exact-active-class":"uk-active","active-class":"uk-active",to:e.path,append:"",exact:""}},[a("a",{attrs:{"uk-tooltip":"",pos:t.tooltipPosition,title:e.meta.breadcrumb}},[a("img",{attrs:{src:e.meta.icon,"uk-svg":"",width:"24",height:"24"}})])])}),1)]),a("div",{staticClass:"pos-sidebar-bottom"},[a("SideBarUserMenu",{attrs:{size:30,width:1}})],1)])},r=[],i=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("ul",{staticClass:"pos-sidebar--nav"},[n("router-link",{attrs:{tag:"li",to:{name:"Settings"},"active-class":"uk-active",exact:""}},[n("a",[n("icon-setting",{attrs:{spin:!0}})],1)])],1)},s=[],o=(n("c5f6"),n("2b2f")),c={name:"SideBarSettings",components:{IconSetting:o["a"]},props:{size:{type:Number,default:24},width:{type:Number,default:1}}},l=c,u=n("2877"),f=Object(u["a"])(l,i,s,!1,null,null,null),d=f.exports,p={name:"SideBar",components:{SideBarUserMenu:d},mounted:function(){window.addEventListener("resize",this.handleResize)},beforeDestroy:function(){window.removeEventListener("resize",this.handleResize)},data:function(){return{width:window.innerWidth}},computed:{tooltipPosition:function(){var t="right";return t=this.width<=768?"top":"right",t},menu:function(){return this.$router.options.routes.filter(function(t){return t.sideMenuParent})[0].children.filter(function(t){return t.showInSideBar})}},methods:{handleResize:function(t){var e=this;setTimeout(function(){e.width=window.innerWidth},300)}}},m=p,g=Object(u["a"])(m,a,r,!1,null,"8a7ac420",null);e["a"]=g.exports},"11e9":function(t,e,n){var a=n("52a7"),r=n("4630"),i=n("6821"),s=n("6a99"),o=n("69a8"),c=n("c69a"),l=Object.getOwnPropertyDescriptor;e.f=n("9e1e")?l:function(t,e){if(t=i(t),e=s(e,!0),c)try{return l(t,e)}catch(n){}if(o(t,e))return r(!a.f.call(t,e),t[e])}},"2b2f":function(t,e,n){"use strict";var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("svg",{class:{"icon-hover-spin":t.spin},attrs:{xmlns:"http://www.w3.org/2000/svg",width:t.size,height:t.size,viewBox:"0 0 26 26"}},[n("circle",{attrs:{cx:"13",cy:"13",r:"1.5",opacity:".6",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}}),n("path",{staticClass:"inside",attrs:{d:"M5.89,15.37A7.5,7.5,0,0,0,7.39,18l2.7-1.56a4.43,4.43,0,0,0,5.82,0L18.61,18a7.5,7.5,0,0,0,1.5-2.6l-2.69-1.55a4.44,4.44,0,0,0-2.92-5V5.65a7.57,7.57,0,0,0-3,0V8.78a4.44,4.44,0,0,0-2.92,5Z",fill:"none",stroke:"#fff",opacity:".6","stroke-linecap":"round","stroke-linejoin":"round"}}),n("circle",{attrs:{cx:"13",cy:"13",r:"7.5",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}}),n("path",{staticClass:"outside",attrs:{d:"M25.39,11.41l-2-.08A10.38,10.38,0,0,0,21.5,6.86l1.38-1.5a12.5,12.5,0,0,0-2.24-2.24L19.14,4.5a10.38,10.38,0,0,0-4.47-1.85l-.08-2A13.84,13.84,0,0,0,13,.5a13.84,13.84,0,0,0-1.59.11l-.08,2A10.38,10.38,0,0,0,6.86,4.5L5.36,3.12A12.5,12.5,0,0,0,3.12,5.36L4.5,6.86a10.38,10.38,0,0,0-1.85,4.47l-2,.08A13.84,13.84,0,0,0,.5,13a13.84,13.84,0,0,0,.11,1.59l2,.08A10.38,10.38,0,0,0,4.5,19.14l-1.38,1.5a12.5,12.5,0,0,0,2.24,2.24l1.5-1.38a10.38,10.38,0,0,0,4.47,1.85l.08,2A13.84,13.84,0,0,0,13,25.5a13.84,13.84,0,0,0,1.59-.11l.08-2a10.38,10.38,0,0,0,4.47-1.85l1.5,1.38a12.5,12.5,0,0,0,2.24-2.24l-1.38-1.5a10.38,10.38,0,0,0,1.85-4.47l2-.08A13.84,13.84,0,0,0,25.5,13,13.84,13.84,0,0,0,25.39,11.41Z",fill:"none",stroke:"#fff","stroke-linecap":"round","stroke-linejoin":"round"}})])},r=[],i=(n("c5f6"),{name:"IconSetting",props:{spin:{type:Boolean,default:!1},size:{type:Number,default:26},width:{type:Number,default:1}}}),s=i,o=(n("7945"),n("2877")),c=Object(o["a"])(s,a,r,!1,null,null,null);e["a"]=c.exports},"2ca2":function(t,e,n){t.exports=n.p+"img/user_profile.3ee91a36.svg"},"57bd":function(t,e,n){},"5dbc":function(t,e,n){var a=n("d3f4"),r=n("8b97").set;t.exports=function(t,e,n){var i,s=e.constructor;return s!==n&&"function"==typeof s&&(i=s.prototype)!==n.prototype&&a(i)&&r&&r(t,i),t}},7945:function(t,e,n){"use strict";var a=n("57bd"),r=n.n(a);r.a},"8b97":function(t,e,n){var a=n("d3f4"),r=n("cb7c"),i=function(t,e){if(r(t),!a(e)&&null!==e)throw TypeError(e+": can't set as prototype!")};t.exports={set:Object.setPrototypeOf||("__proto__"in{}?function(t,e,a){try{a=n("9b43")(Function.call,n("11e9").f(Object.prototype,"__proto__").set,2),a(t,[]),e=!(t instanceof Array)}catch(r){e=!0}return function(t,n){return i(t,n),e?t.__proto__=n:a(t,n),t}}({},!1):void 0),check:i}},9093:function(t,e,n){var a=n("ce10"),r=n("e11e").concat("length","prototype");e.f=Object.getOwnPropertyNames||function(t){return a(t,r)}},a5b5:function(t,e,n){"use strict";n.r(e);var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"pos-body"},[n("div",{staticClass:"pos-main"},[n("div",{staticClass:"pos-container"},[n("div",{staticClass:"pos-content uk-flex uk-flex-middle uk-flex-center uk-text-center"},[n("div",[n("p",{staticClass:"uk-heading-2xlarge",domProps:{textContent:t._s(t.$t("err404.title"))}}),n("p",{staticClass:"uk-h4 uk-text-lowercase uk-margin-remove uk-text-muted",domProps:{textContent:t._s(t.$t("err404.content"))}})])]),n("NavBar")],1),n("SideBar")],1)])},r=[],i=n("0ef3"),s=n("bf06"),o={name:"PageNotFound",components:{NavBar:s["a"],SideBar:i["a"]},metaInfo:function(){return{title:this.$t("auth.title"),titleTemplate:"%s - Scorm",htmlAttrs:{lang:this.$t("app.lang")}}},data:function(){return{}}},c=o,l=n("2877"),u=Object(l["a"])(c,a,r,!1,null,null,null);e["default"]=u.exports},aa77:function(t,e,n){var a=n("5ca1"),r=n("be13"),i=n("79e5"),s=n("fdef"),o="["+s+"]",c="​",l=RegExp("^"+o+o+"*"),u=RegExp(o+o+"*$"),f=function(t,e,n){var r={},o=i(function(){return!!s[t]()||c[t]()!=c}),l=r[t]=o?e(d):s[t];n&&(r[n]=l),a(a.P+a.F*o,"String",r)},d=f.trim=function(t,e){return t=String(r(t)),1&e&&(t=t.replace(l,"")),2&e&&(t=t.replace(u,"")),t};t.exports=f},bf06:function(t,e,n){"use strict";var a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"pos-navbar"},[t.leftToggle.visibility?n("div",{staticClass:"pos-navbar-left"},[n("div",{staticClass:"pos-navbar-item"},[n("a",{staticClass:"pos-card-header-item link",class:{"uk-text-danger":t.leftToggleState},on:{click:function(e){return e.preventDefault(),t.leftToggleAction(e)}}},[n("img",{attrs:{src:"/img/icons/"+t.leftToggle.icon,"uk-svg":"",width:"20",height:"20"}})])])]):t._e(),n("div",{staticClass:"pos-navbar-middle"},[n("div",{staticClass:"pos-navbar__title",domProps:{innerHTML:t._s(t.pageTitle)}})]),n("div",{staticClass:"pos-navbar-right"},[t._m(0),n("NavBarUserMenu")],1)])},r=[function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("a",{staticClass:"pos-navbar-item"},[n("img",{attrs:{src:"/img/icons/user_profile.svg","uk-svg":"",width:"24",height:"24"}})])}],i=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"uk-navbar-dropdown uk-dropdown-small",attrs:{"uk-dropdown":"mode: click; offset: 10; pos: bottom-right; animation: uk-animation-slide-right-medium"}},[a("ul",{staticClass:"uk-nav uk-navbar-dropdown-nav"},[a("router-link",{attrs:{tag:"li",to:{name:"Profile"},"active-class":"uk-active",exact:""}},[a("a",[a("img",{staticClass:"uk-margin-small-right",attrs:{src:n("2ca2"),"uk-svg":"",width:"16",height:"16"}}),t._v("\n        Профиль пользователя")])]),a("li",[a("a",{on:{click:function(e){return e.preventDefault(),t.signOut(e)}}},[a("img",{staticClass:"uk-margin-small-right",attrs:{src:n("c4b0"),"uk-svg":"",width:"16",height:"16"}}),t._v("\n        Выйти\n      ")])])],1)])},s=[],o=(n("c5f6"),n("8323")),c=n.n(o),l=n("2b2f"),u={name:"NavBarUserMenu",components:{IconSetting:l["a"]},props:{size:{type:Number,default:24},width:{type:Number,default:1}},methods:{signOut:function(){var t=this;c.a.modal.confirm("Выйти из системы!",{labels:{ok:"Выйти",cancel:"Остаться в системе"}}).then(function(){t.$store.dispatch("logout")})}}},f=u,d=n("2877"),p=Object(d["a"])(f,i,s,!1,null,null,null),m=p.exports,g={name:"NavBar",components:{NavBarUserMenu:m},data:function(){return{}},computed:{leftToggle:function(){return this.$store.getters.cardLeftAction},leftToggleState:function(){return this.$store.getters.cardLeftState},pageTitle:function(){return this.$route.params.title?'<span class="uk-text-muted">'+this.$route.meta.breadcrumb+":</span> "+this.$route.params.title:this.$route.meta.breadcrumb}},methods:{leftToggleAction:function(){this.$store.commit("card_left_state",!this.leftToggleState)}}},v=g,h=Object(d["a"])(v,a,r,!1,null,null,null);e["a"]=h.exports},c4b0:function(t,e,n){t.exports=n.p+"img/user_logout.ae475479.svg"},c5f6:function(t,e,n){"use strict";var a=n("7726"),r=n("69a8"),i=n("2d95"),s=n("5dbc"),o=n("6a99"),c=n("79e5"),l=n("9093").f,u=n("11e9").f,f=n("86cc").f,d=n("aa77").trim,p="Number",m=a[p],g=m,v=m.prototype,h=i(n("2aeb")(v))==p,b="trim"in String.prototype,k=function(t){var e=o(t,!1);if("string"==typeof e&&e.length>2){e=b?e.trim():d(e,3);var n,a,r,i=e.charCodeAt(0);if(43===i||45===i){if(n=e.charCodeAt(2),88===n||120===n)return NaN}else if(48===i){switch(e.charCodeAt(1)){case 66:case 98:a=2,r=49;break;case 79:case 111:a=8,r=55;break;default:return+e}for(var s,c=e.slice(2),l=0,u=c.length;l<u;l++)if(s=c.charCodeAt(l),s<48||s>r)return NaN;return parseInt(c,a)}}return+e};if(!m(" 0o1")||!m("0b1")||m("+0x1")){m=function(t){var e=arguments.length<1?0:t,n=this;return n instanceof m&&(h?c(function(){v.valueOf.call(n)}):i(n)!=p)?s(new g(k(e)),n,m):k(e)};for(var _,w=n("9e1e")?l(g):"MAX_VALUE,MIN_VALUE,NaN,NEGATIVE_INFINITY,POSITIVE_INFINITY,EPSILON,isFinite,isInteger,isNaN,isSafeInteger,MAX_SAFE_INTEGER,MIN_SAFE_INTEGER,parseFloat,parseInt,isInteger".split(","),x=0;w.length>x;x++)r(g,_=w[x])&&!r(m,_)&&f(m,_,u(g,_));m.prototype=v,v.constructor=m,n("2aba")(a,p,m)}},fdef:function(t,e){t.exports="\t\n\v\f\r   ᠎             　\u2028\u2029\ufeff"}}]);