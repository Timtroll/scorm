(function(e){function n(n){for(var r,o,i=n[0],c=n[1],s=n[2],d=0,l=[];d<i.length;d++)o=i[d],a[o]&&l.push(a[o][0]),a[o]=0;for(r in c)Object.prototype.hasOwnProperty.call(c,r)&&(e[r]=c[r]);f&&f(n);while(l.length)l.shift()();return u.push.apply(u,s||[]),t()}function t(){for(var e,n=0;n<u.length;n++){for(var t=u[n],r=!0,o=1;o<t.length;o++){var i=t[o];0!==a[i]&&(r=!1)}r&&(u.splice(n--,1),e=c(c.s=t[0]))}return e}var r={},o={app:0},a={app:0},u=[];function i(e){return c.p+"js/"+({}[e]||e)+"."+{"chunk-25e48074":"afc23540","chunk-2d0d7be6":"1a9ce929","chunk-2d0ddb72":"0e23ce20","chunk-23f850ef":"6a9a6a6f","chunk-40a767a0":"33917e65","chunk-deb50a6c":"a0412bfd","chunk-2d217ef4":"faa801e8"}[e]+".js"}function c(n){if(r[n])return r[n].exports;var t=r[n]={i:n,l:!1,exports:{}};return e[n].call(t.exports,t,t.exports,c),t.l=!0,t.exports}c.e=function(e){var n=[],t={"chunk-23f850ef":1,"chunk-deb50a6c":1};o[e]?n.push(o[e]):0!==o[e]&&t[e]&&n.push(o[e]=new Promise(function(n,t){for(var r="css/"+({}[e]||e)+"."+{"chunk-25e48074":"31d6cfe0","chunk-2d0d7be6":"31d6cfe0","chunk-2d0ddb72":"31d6cfe0","chunk-23f850ef":"63539efb","chunk-40a767a0":"31d6cfe0","chunk-deb50a6c":"63539efb","chunk-2d217ef4":"31d6cfe0"}[e]+".css",a=c.p+r,u=document.getElementsByTagName("link"),i=0;i<u.length;i++){var s=u[i],d=s.getAttribute("data-href")||s.getAttribute("href");if("stylesheet"===s.rel&&(d===r||d===a))return n()}var l=document.getElementsByTagName("style");for(i=0;i<l.length;i++){s=l[i],d=s.getAttribute("data-href");if(d===r||d===a)return n()}var f=document.createElement("link");f.rel="stylesheet",f.type="text/css",f.onload=n,f.onerror=function(n){var r=n&&n.target&&n.target.src||a,u=new Error("Loading CSS chunk "+e+" failed.\n("+r+")");u.code="CSS_CHUNK_LOAD_FAILED",u.request=r,delete o[e],f.parentNode.removeChild(f),t(u)},f.href=a;var h=document.getElementsByTagName("head")[0];h.appendChild(f)}).then(function(){o[e]=0}));var r=a[e];if(0!==r)if(r)n.push(r[2]);else{var u=new Promise(function(n,t){r=a[e]=[n,t]});n.push(r[2]=u);var s,d=document.createElement("script");d.charset="utf-8",d.timeout=120,c.nc&&d.setAttribute("nonce",c.nc),d.src=i(e),s=function(n){d.onerror=d.onload=null,clearTimeout(l);var t=a[e];if(0!==t){if(t){var r=n&&("load"===n.type?"missing":n.type),o=n&&n.target&&n.target.src,u=new Error("Loading chunk "+e+" failed.\n("+r+": "+o+")");u.type=r,u.request=o,t[1](u)}a[e]=void 0}};var l=setTimeout(function(){s({type:"timeout",target:d})},12e4);d.onerror=d.onload=s,document.head.appendChild(d)}return Promise.all(n)},c.m=e,c.c=r,c.d=function(e,n,t){c.o(e,n)||Object.defineProperty(e,n,{enumerable:!0,get:t})},c.r=function(e){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},c.t=function(e,n){if(1&n&&(e=c(e)),8&n)return e;if(4&n&&"object"===typeof e&&e&&e.__esModule)return e;var t=Object.create(null);if(c.r(t),Object.defineProperty(t,"default",{enumerable:!0,value:e}),2&n&&"string"!=typeof e)for(var r in e)c.d(t,r,function(n){return e[n]}.bind(null,r));return t},c.n=function(e){var n=e&&e.__esModule?function(){return e["default"]}:function(){return e};return c.d(n,"a",n),n},c.o=function(e,n){return Object.prototype.hasOwnProperty.call(e,n)},c.p="/",c.oe=function(e){throw console.error(e),e};var s=window["webpackJsonp"]=window["webpackJsonp"]||[],d=s.push.bind(s);s.push=n,s=s.slice();for(var l=0;l<s.length;l++)n(s[l]);var f=d;u.push([0,"chunk-vendors"]),t()})({0:function(e,n,t){e.exports=t("56d7")},"56d7":function(e,n,t){"use strict";t.r(n);t("cadf"),t("551c"),t("f751"),t("097d");var r,o=t("a026"),a=function(){var e=this,n=e.$createElement,t=e._self._c||n;return t("div",{attrs:{id:"app"}},[t("transition",{attrs:{name:"rotate",mode:"out-in",appear:""}},[t("router-view")],1)],1)},u=[],i=t("2877"),c={},s=Object(i["a"])(c,a,u,!1,null,null,null),d=s.exports,l=t("8c4f"),f=t("2f62"),h=t("bc3a"),m=t.n(h),p=t("1764"),g=t.n(p);m.a.defaults.headers.common["Access-Control-Allow-Origin"]="*",r=(o["a"].config.productionTip,"https://cors-anywhere.herokuapp.com/");var b=r+"http://freee.su/",v={logIn:b+"login",logOut:b+"logout"},k=function(e){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"primary",t=arguments.length>2&&void 0!==arguments[2]?arguments[2]:"2000",r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:"top-center";g.a.notification({message:e,status:n,pos:r,timeout:t})},w={login:function(e,n){var t=e.commit;return new Promise(function(e,r){t("auth_request"),m()(v.logIn,{params:n,method:"POST",crossDomain:!0,withCredentials:!1}).then(function(r){var o=r.data;if("ok"===o.status){var a=o.token;localStorage.setItem("token",a),m.a.defaults.headers.common["Authorization"]=a,t("auth_success",a,n),e(r)}else k(o.mess,"danger"),t("auth_error"),localStorage.removeItem("token")}).catch(function(e){k(e,"danger"),t("auth_request"),r(e)})})},logout:function(e){var n=e.commit;return new Promise(function(e,t){m()(v.logOut,{method:"POST",crossDomain:!0,withCredentials:!1}).then(function(t){"ok"===t.data.status&&(n("logout"),localStorage.removeItem("token"),delete m.a.defaults.headers.common["Authorization"],k("До встречи!","success"),B.push({name:"Login"}),e(t))}).catch(function(e){k(e,"danger"),t(e)}),e()})}},y=w,S={auth_request:function(e){e.user.status="loading"},auth_success:function(e,n,t){e.user.status="success",e.user.token=n,e.user.user=t},auth_error:function(e){e.user.status="error"},logout:function(e){e.user.status="",e.user.token=""}},_=S,P={isLoggedIn:function(e){return!!e.user.token},authStatus:function(e){return e.user.status}},q=P,I={user:{status:"",token:localStorage.getItem("token")||"",profile:null}},O={namespaced:!1,state:I,actions:y,mutations:_,getters:q};o["a"].use(f["a"]);var R=new f["a"].Store({modules:{auth:O}}),A=R;o["a"].use(l["a"]);var j=new l["a"]({mode:"history",base:"/",routes:[{path:"/login",name:"Login",component:function(){return t.e("chunk-25e48074").then(t.bind(null,"a55b"))},meta:{authRequired:!1}},{path:"/",name:"Main",component:function(){return Promise.all([t.e("chunk-2d0ddb72"),t.e("chunk-23f850ef")]).then(t.bind(null,"cd56"))},redirect:{name:"Dashboard"},sideMenuParent:!0,meta:{authRequired:!0},children:[{path:"/dashboard",name:"Dashboard",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_dashboard.svg",breadcrumb:"Рабочий стол"}},{path:"/pages",name:"Pages",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_pages.svg",breadcrumb:"Контент"}},{path:"/courses",name:"Courses",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_courses.svg",breadcrumb:"Курсы"}},{path:"/review",name:"Review",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_review.svg",breadcrumb:"Отзывы"}},{path:"/users",name:"Users",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_users.svg",breadcrumb:"Пользователи"}},{path:"/media",name:"Media",component:function(){return t.e("chunk-2d217ef4").then(t.bind(null,"c99a"))},props:{},showInSideBar:!0,meta:{authRequired:!0,icon:"img/icons/sidebar_media.svg",breadcrumb:"Медиа хранилище"}},{path:"/profile",name:"Profile",component:function(){return Promise.all([t.e("chunk-2d0ddb72"),t.e("chunk-40a767a0")]).then(t.bind(null,"cfa2"))},props:{},showInSideBar:!1,meta:{authRequired:!0,icon:"img/icons/user_profile.svg",breadcrumb:"Профиль пользователя"}},{path:"/settings",name:"Settings",component:function(){return t.e("chunk-2d0d7be6").then(t.bind(null,"77b2"))},props:{},showInSideBar:!1,meta:{authRequired:!0,icon:"img/icons/user_profile.svg",breadcrumb:"Настройки"}}]},{path:"/404",name:"pageNotFound",component:function(){return Promise.all([t.e("chunk-2d0ddb72"),t.e("chunk-deb50a6c")]).then(t.bind(null,"a5b5"))},showInSideBar:!1,meta:{authRequired:!1,breadcrumb:"Страница не найдена"}},{path:"/*",redirect:"/404",meta:{authRequired:!1}}]});j.beforeEach(function(e,n,t){var r=A.getters.isLoggedIn;e.matched.some(function(e){return e.meta.authRequired})?r?t():t({name:"Login",query:{redirect:e.fullPath}}):t()});var B=j,E=t("58ca"),T=(t("5df3"),t("ac6a"),t("9483"));Object(T["a"])("".concat("/","service-worker.js"),{ready:function(){console.log("App is being served from cache by a service worker.\nFor more details, visit https://goo.gl/AFskqB")},registered:function(){console.log("Service worker has been registered.")},cached:function(){console.log("Content has been cached for offline use.")},updatefound:function(){console.log("New content is downloading.")},updated:function(){console.log("New content is available; please refresh.");var e=confirm('Доступно обновление. Нажмите "ОК" для перезагрузки');e&&(caches.keys().then(function(e){return Promise.all(e.filter(function(e){}).map(function(e){return caches.delete(e)}))}),navigator.serviceWorker.getRegistrations().then(function(e){e.forEach(function(e){e.unregister()})}),setTimeout(function(){location.reload(!0)},300))},offline:function(){console.log("No internet connection found. App is running in offline mode.")},error:function(e){console.error("Error during service worker registration:",e),alert(e)}}),!0===window.navigator.standalone&&console.log("safari display-mode is standalone"),window.matchMedia("(display-mode: standalone)").matches&&console.log("display-mode is standalone");t("f251");console.log(A),o["a"].prototype.$http=m.a;var C=localStorage.getItem("token");C&&(o["a"].prototype.$http.defaults.headers.common["Authorization"]=C),o["a"].use(E["a"],{refreshOnceOnNavigation:!0}),o["a"].config.productionTip=!1,new o["a"]({router:B,store:A,render:function(e){return e(d)}}).$mount("#app"),o["a"].directive("focus",{inserted:function(e){e.focus()}})},f251:function(e,n,t){}});