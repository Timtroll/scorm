window.onload = function() {
// функции после загрузки страницы

    // отправка запроса 
    // url - адрес
    // data - передаваемые данные ?если не строка, конвертируются в строку запроса?
    // success - функция, вызывается при успешном запросе
    // error - функция,вызывается при не успешном запросе
    function postAjax(url, data, success, error) {
        var params = typeof data == 'string' ? data : Object.keys(data).map(
                // преобразование в get запрос
                function(k){ return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]) }
            ).join('&');

        // создание xhr объекта для запроса к серверу без перезагрузки страницы
        var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
        // конфигурация запроса
        xhr.open('POST', url);
        // обработчик события смены readystate (состояние загрузки документа)
        xhr.onreadystatechange = function() {
            if (xhr.readyState > 3 && xhr.status == 200) { success(xhr.responseText); }
            else if (xhr.readyState > 3 && xhr.status != 200) { error(xhr); }
        };
        // значение заголовков
        xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        // отправка запроса
        xhr.send(params);
        // объект
        return xhr;
    }

    function DrawForm() {
        var formGroupButton = document.getElementById('formGroupButton');
        formGroupButton.addEventListener('click',function(){
            var groupStatus = document.getElementById('groupStatus');
            if ( groupStatus.checked == true) {
                groupStatus.value = 1;
            }
            else {
                groupStatus.value = 0;
            }
            postAjax('http://freee/forum/save_add_group', {
                name : document.getElementById('name').value,
                title : document.getElementById('groupTitle').value,
                status : groupStatus.value,
            }, function(){
                DeleteGroupList();
                DrawGroupList();
                document.getElementById('name').value = '';
                document.getElementById('groupTitle').value = '';
            });
        }, false);

        var formThemeButton = document.getElementById('formThemeButton');
        formThemeButton.addEventListener('click',function(){
            var themeStatus = document.getElementById('themeStatus');
            if ( themeStatus.checked == true) {
                themeStatus.value = 1;
            } else {
                themeStatus.value = 0;
            }
            postAjax('http://freee/forum/save_add_theme', {
                group_id : document.getElementById('parentGroupId').value,
                title : document.getElementById('themeTitle').value,
                url : document.getElementById('url').value,
                status : themeStatus.value,
            }, function(){
                    DeleteGroupList();
                    DrawGroupList();
console.log( 2 );
console.log( document.getElementById('parentGroupId').value );
                ShowThemes( document.getElementById('parentGroupId').value );
                document.getElementById('url').value = '';
                document.getElementById('themeTitle').value = '';
            });
        }, false);

        var formMessageButton = document.getElementById('formMessageButton');
        formMessageButton.addEventListener('click',function(){
            var messageStatus = document.getElementById('messageStatus');
            if ( messageStatus.checked == true) {
                messageStatus.value = 1;
            } else {
                messageStatus.value = 0;
            }
            postAjax('http://freee/forum/save_add', {
                theme_id : document.getElementById('parentThemeId').value,
                msg : document.getElementById('msg').value,
                status : document.getElementById('messageStatus').value,
            }, function(){
                DeleteMessageList(); 
                ShowMessageList( parentThemeId.value );
            });
        }, false);
    }

    // создание кнопки добавления групп
    function DrawGroupsButtton(){
        var newTag = document.createElement('i');
        newTag.setAttribute('class', 'fas fa-plus');
        document.getElementById('menuButton').appendChild( newTag );
        newTag.addEventListener('click',function(){
            ShowGroupsAdd();
        });
    }

    // показывание формы добавления групп
    function ShowGroupsAdd(){
        document.getElementById( 'formGroup' ).style.display = 'block';
        document.getElementById( 'formTheme' ).style.display = 'none';
        document.getElementById( 'formMessage' ).style.display = 'none';
    };

    // показывание формы добавления тем
    function ShowThemesAdd( groupId ){
        document.getElementById( 'formGroup' ).style.display = 'none';
        document.getElementById( 'formTheme' ).style.display = 'block';
        document.getElementById( 'formMessage' ).style.display = 'none';
        document.getElementById( 'parentGroupId' ).setAttribute('value', groupId );
console.log( 1 );
console.log( groupId );
    };

    // показывание формы добавления сообщений
    function ShowMessagesAdd( id ){
        document.getElementById( 'formGroup' ).style.display = 'none';
        document.getElementById( 'formTheme' ).style.display = 'none';
        document.getElementById( 'formMessage' ).style.display = 'block';
        document.getElementById( 'parentThemeId' ).setAttribute('value', id );
    };

    // рисование листа групп
    function DrawGroupList() {
        // запрос для получения листа групп
        postAjax('http://freee/forum/list_groups', {}, function( list ){
            // раскодирование json
            var res = JSON.parse( list );
            const groups = [];
            // создаётся тэг ul
            var groupDiv = document.createElement('div');
            // создаётся тэг groups
            var groupListTag = document.getElementById('groups');
            // ul вставляется в groups
            groupListTag.appendChild( groupDiv );

            // проход по группам
            res.list.forEach( function( item ) {

                var groupLi = document.createElement('li');
                groupLi.setAttribute('class', 'groups');
                groupLi.setAttribute('id', item.id);
                groupDiv.appendChild( groupLi );

                var groupLine = document.createElement('div');
                groupLine.setAttribute('class', 'groupLine');
                groupLi.appendChild( groupLine );

                var groupSpan = document.createElement('span');
                groupSpan.innerHTML = item.name;
                groupSpan.setAttribute('class', 'groupName');
                groupLine.appendChild( groupSpan );
                // рисование листа тем
                DrawThemeList (item.id, groupLi, groupDiv );
                // отображение тем этой группы
                groupSpan.addEventListener('click',function(){
                    HideThemes();
                    ShowThemes( item.id );
                }, false);

                var newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-trash');
                groupLine.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/del_group', { id: item.id }, function( list ){
                        ReDrawGroup( list, item.id );
                    }), false;
                });

                if ( ! item.status) {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye');
                    groupLine.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 1 }, function( list ){
                            DeleteGroupList();
                            DrawGroupList();
                        }), false;
                    });
                } 
                else {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye-slash');
                    groupLine.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 0 }, function( list ){
                            DeleteGroupList();
                            DrawGroupList();
                        }), false;
                    });
                }

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-edit');
                groupLine.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 1 }, function(){}), false;
                });

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-plus');
                groupLine.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    ShowThemesAdd( item.id, groupLi );
                });
            });
        });                        
    }

    function ReDrawGroup( list, groupId ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteGroupList();
            DrawGroupList();
            HideThemes();
            var pathArray = document.getElementsByClassName('current_path').innerHTML.split( ':' );
            if ( res.id == Number( pathArray[0] ) ) {
                DeleteMessageList(); 
            }
            else {
                // нужен li открытой группы
                ShowThemes( groupId );
            }
        }
        else {
            var errorDiv = document.getElementsByClassName('error');
            errorDiv[0].innerHTML = res.message;
        }
    }

    function DeleteGroupList() {
        var groupList = document.querySelectorAll('.groups');
        for (var i = 0; i < groupList.length; i++) {        
            groupList[i].parentNode.removeChild( groupList[i] );
        }
    }

    function DeleteThemeList() {
        var themeList = document.querySelectorAll('.themes');
        for (var i = 0; i < themeList.length; i++) {        
            themeList[i].parentNode.removeChild( themeList[i] );
        }
    }

    function DrawThemeList( groupId, groupLi, groupDiv ) {
        var pathDiv = document.getElementsByClassName('current_path');
        pathDiv[0].innerHTML = groupId.toString() + ':';

        postAjax('http://freee/forum/list_themes', { group_id: groupId }, function( list ){
            var res = JSON.parse( list );
            const messages = [];
            res.list.forEach( function( item ) {

                var themeLi = document.createElement('li');
                themeLi.setAttribute('class', 'themes');
                groupLi.appendChild( themeLi );

                var themeSpan = document.createElement('span');
                themeSpan.innerHTML = item.title;
                themeLi.appendChild( themeSpan );
                themeSpan.addEventListener('click',function(){ 
                    DeleteMessageList(); 
                    ShowMessageList( item.id );
                }, false);

                var newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-trash');
                themeLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/del_theme', { id: item.id }, function( list ){
                        ShowThemes( groupId );
                    }), false;
                });

                if ( ! item.status) {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye');
                    themeLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 1 }, function( list ){
                            DeleteThemeList(); 
                            DrawThemeList( groupId, groupLi, groupDiv );
                        }), false;
                    });
                }
                else {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye-slash');
                    themeLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 0 }, function( list ){
                            DeleteThemeList(); 
                            DrawThemeList( groupId, groupLi, groupDiv );
                        }), false;
                    });
                }

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-edit');
                themeLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 1 }, function(){}), false;
                });

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-plus');
                themeLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    ShowMessagesAdd( item.id );
                });
                themeLi.style.display = "none";
            });
        });
    }

    function HideThemes( themeId ) {
        // скрыть все темы
        var themeList = document.querySelectorAll('.themes');
        for (var i = 0; i < themeList.length; i++) {        
            themeList[i].style.display = "none";
        }
    }

    function ShowThemes( groupId ) {
        // показать темы текущей группы
        var id = groupId.toString();
console.log('3:');
console.log(groupId);
console.log(id);
        var groupLi = document.getElementById( id );
console.log(groupLi);
        var nodes = groupLi.childNodes;
        for (var i = 0; i < nodes.length; i++) {
            if ( nodes[i].classList.contains( 'themes' ) ){
                nodes[i].style.display = "block";
            }
        }
    }
    // function ShowThemess( themeId ) {
    //     // скрыть все темы
    //     var themeList = document.querySelectorAll('.themes');
    //     for (var i = 0; i < themeList.length; i++) {        
    //         themeList[i].style.display = "none";
    //     }
    //     // показать темы текущей группы
    //     var themeList = document.querySelectorAll("[id=themeId]");
    //     for (var i = 0; i < themeList.length; i++) {        
    //         themeList[i].style.display = "block";
    //     }
    // }

    // function ReDrawTheme( list, groupId, groupLi, groupDiv ) {
    //     var res = JSON.parse( list );
    //     if ( res.status == 'ok' ) {
    //         var pathArray = document.getElementById('current_path').innerHTML.split( ':' );
    //         if ( res.id == Number( pathArray[1] ) ) {
    //             DeleteMessageList(); 
    //         }
    //         DeleteThemeList(); 
    //         DrawThemeList( groupId, groupLi, groupDiv );
    //     }
    //     else {
    //         var errorDiv = document.getElementById('error');
    //         errorDiv.innerHTML = res.message;
    //     }
    // }

    function DeleteMessageList() {
        var container = document.getElementById('list_messages_output');
        while (container.firstChild) {
            container.removeChild(container.firstChild);
        }
    }

    function ShowMessageList( themeId ) {
        var pathDiv = document.getElementsByClassName('current_path');
        var pathArray = pathDiv[0].innerHTML.split( ':' );
        pathDiv[0].innerHTML = pathArray[0] + ':' + themeId.toString();

        postAjax('http://freee/forum/list_messages', { theme_id: themeId }, function( list ){
            var res = JSON.parse( list );
            const messages = [];

            var newDiv = document.createElement('div');
            var list_tag = document.getElementById('list_messages_output');
            list_tag.appendChild( newDiv );

            res.list.forEach( function( item ) {
                var newLi = document.createElement('li');
                newLi.innerHTML = item.msg;
                newDiv.appendChild( newLi );

                var newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-trash');
                newLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/delete', { id: item.id }, function( list ){
                        ReDrawMessage( list, themeId );
                    }), false;
                });

                if ( ! item.status) {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye');
                    newLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_messages', value: 1 }, function( list ){
                            ReDrawMessage( list, themeId );
                        }), false;
                    });
                } 
                else {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye-slash');
                    newLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_messages', value: 0 }, function( list ){
                            ReDrawMessage( list, themeId );
                        }), false;
                    });
                }

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-edit');
                newLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_messages', value: 1 }, function(){}), false;
                });
            });                                
        });
    }

    function ReDrawMessage( list, theme_id ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteMessageList(); 
            ShowMessageList( theme_id );
        }
        else {
            var errorDiv = document.getElementsByClassName('error');
            errorDiv[0].innerHTML = res.message;
        }
    }

    function CreateButtons() {
        // add delete action
        // classname = document.getElementsByClassName('fas fa-trash');
        // for (var i = 0; i < classname.length; i++) {
        //     classname[i].addEventListener('click',function(){
        //     }, false);
        // }
        // // add toggle action
        // classname = document.getElementsByClassName('fas fa-eye');
        // for (var i = 0; i < classname.length; i++) {
        //     classname[i].addEventListener('click',function(){
        //     }, false);
        // }
        // add toggle action
        classname = document.getElementsByClassName('fas fa-eye-slash');
        for (var i = 0; i < classname.length; i++) {
            classname[i].addEventListener('click',function(){
                postAjax('http://freee/forum/toggle', { id: 3, table: 'forum_messages', value: 0}, function(){}), false;
            });
        }
    }

    function Edit(data) {
        var id = this.getAttribute('data-id');
        postAjax('http://freee/forum/edit', { id: id }, function(data){
            var res = JSON.parse(data);
            document.getElementById('msg').value        = res.msg;
            document.getElementById('id').value         = res.id;
            document.getElementById('theme_id').value   = res.theme_id;
            document.getElementById('status').checked   = res.status ? true : false;
            document.getElementById('btn').innerHTML    = 'Сохранить';
console.log(res.id);
console.log(res.msg);
        });
// console.log('edit', id);
    }

    function Delete(data) {
console.log('delete');
    }

    function Toggle(data) {
console.log('toggle');
    }

    // document.getElementById('add').addEventListener('click', Add, false);

    // var add = document.getElementsByClassName('btn');
    // add[0].addEventListener('click', Add, false);


    var id = 1;

    DrawGroupList();
    DrawForm();
    DrawGroupsButtton();
    // postAjax('http://freee/forum/list_themes', { id: id }, function(data){ Draw(data, 'menu'); },  Error );

    // postAjax('http://freee/forum/list_messages', { {id: id }, function(data){ Draw(data, 'messages'); }, Error );
};