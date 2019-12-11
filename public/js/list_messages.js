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

    // меню навигации
    function DrawNavigation() {
        // группы
        var navigationGroups = document.getElementById('navigationGroups');
        navigationGroups.addEventListener('click',function(){
            DeleteMessageList();
            HideThemes();
            document.getElementById('navigationThemes').style.display   = 'none';
            document.getElementById('navigationMessages').style.display = 'none';
        });

        // темы
        var navigationThemes = document.getElementById('navigationThemes');
        navigationThemes.addEventListener('click',function(){
            DeleteMessageList();
            document.getElementById('navigationMessages').style.display = 'none';
        });
        navigationThemes.style.display = 'none';

        // сообщения
        document.getElementById('navigationMessages').style.display = 'none';
    }

    //рисование формы добавления/редактирования
    function DrawForm() {
        var formGroupButton = document.getElementById('formGroupButton');
        formGroupButton.addEventListener('click',function(){
            //обработка статуса
            var groupStatus = document.getElementById('groupStatus');
            if ( groupStatus.checked == true) {
                groupStatus.value = 1;
            }
            else {
                groupStatus.value = 0;
            }
            //добавление или сохранение в зависимости от параметра
            if ( document.getElementById('groupId').value == 'add') {
                postAjax('http://freee/forum/save_add_group', {
                    name : document.getElementById('name').value,
                    title : document.getElementById('groupTitle').value,
                    status : groupStatus.value,
                }, function( list ){
                    ReDrawGroup( list );
                    document.getElementById('name').value = '';
                    document.getElementById('groupTitle').value = '';
                });
            }
            else {
                postAjax('http://freee/forum/save_edit_group', {
                    id : document.getElementById('groupId').value,
                    name : document.getElementById('name').value,
                    title : document.getElementById('groupTitle').value,
                    status : groupStatus.value,
                }, function(list ){
                    ReDrawGroup( list );
                    document.getElementById('formGroup').style.display = 'none';
                });
            }
        }, false);

        var formThemeButton = document.getElementById('formThemeButton');
        formThemeButton.addEventListener('click',function(){
            var themeStatus = document.getElementById('themeStatus');
            if ( themeStatus.checked == true) {
                themeStatus.value = 1;
            } else {
                themeStatus.value = 0;
            }
            if ( document.getElementById('themeId').value == 'add') {
                postAjax('http://freee/forum/save_add_theme', {
                    group_id : document.getElementById('parentGroupId').value,
                    title : document.getElementById('themeTitle').value,
                    url : document.getElementById('url').value,
                    status : themeStatus.value,
                }, function( list ){
                    ReDrawTheme( list );
                    document.getElementById('url').value = '';
                    document.getElementById('themeTitle').value = '';
                });
            }
            else {
                postAjax('http://freee/forum/save_edit_theme', {
                    id : document.getElementById('themeId').value,
                    group_id : document.getElementById('parentGroupId').value,
                    title : document.getElementById('themeTitle').value,
                    url : document.getElementById('url').value,
                    status : themeStatus.value,
                }, function( list ){
                    ReDrawTheme( list );
                    document.getElementById('formTheme').style.display = 'none';
                });
            }
        }, false);

        var formMessageButton = document.getElementById('formMessageButton');
        formMessageButton.addEventListener('click',function(){
            var messageStatus = document.getElementById('messageStatus');
            if ( messageStatus.checked == true) {
                messageStatus.value = 1;
            } else {
                messageStatus.value = 0;
            }
            if ( document.getElementById('messageId').value == 'add') {
                postAjax('http://freee/forum/save_add', {
                    theme_id : document.getElementById('parentThemeId').value,
                    msg : document.getElementById('msg').value,
                    status : document.getElementById('messageStatus').value,
                }, function( list ){
                    var res = JSON.parse( list );
                    if ( res.status == 'ok' ) {
                        DeleteMessageList();
                        DrawMessageList( parentThemeId.value );
                        document.getElementById('msg').value = '';
                        document.getElementById('messageStatus').checked = 'true';
                    }
                    else {
                        var errorDiv = document.getElementsByClassName('error');
                        errorDiv[0].innerHTML = res.message;
                    }
                });
            }
            else {
                postAjax('http://freee/forum/save_edit', {
                    id : document.getElementById('messageId').value,
                    theme_id : document.getElementById('parentThemeId').value,
                    msg : document.getElementById('msg').value,
                    status : document.getElementById('messageStatus').value,
                }, function( list ){
                    var res = JSON.parse( list );
                    if ( res.status == 'ok' ) {
                        DeleteMessageList();
                        DrawMessageList( parentThemeId.value );
                        document.getElementById('formMessage').style.display = 'none';
                    }
                    else {
                        var errorDiv = document.getElementsByClassName('error');
                        errorDiv[0].innerHTML = res.message;
                    }
                });
            }
            
        }, false);
    }

    // показывание формы добавления группы
    function ShowGroupsAdd(){
        document.getElementById('groupId').value             = 'add';
        document.getElementById('name').value                = '';
        document.getElementById('groupTitle').value          = '';
        document.getElementById('groupStatus').checked       = 'true';
        document.getElementById('groupText').innerHTML       = 'Добавить новую группу';
        document.getElementById('formGroupButton').innerText = 'Добавить';
        document.getElementById('formGroup').style.display   = 'block';
        document.getElementById('formTheme').style.display   = 'none';
        document.getElementById('formMessage').style.display = 'none';
    };

    // показывание формы редактирования группы
    function GetGroup( id ) {
        postAjax('http://freee/forum/edit_group', { id: id }, function( list ){
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
                document.getElementById('groupId').value             = res.group.id;
                document.getElementById('name').value                = res.group.name;
                document.getElementById('groupTitle').value          = res.group.title;
                document.getElementById('groupStatus').checked       = res.group.status ? true : false;
                document.getElementById('groupText').innerHTML       = 'Редактировать группу';
                document.getElementById('formGroupButton').innerText = 'Сохранить';
                document.getElementById('formGroup').style.display   = 'block';
                document.getElementById('formTheme').style.display   = 'none';
                document.getElementById('formMessage').style.display = 'none';
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }

    // показывание формы добавления темы
    function ShowThemesAdd( id ){
        document.getElementById('themeId').value               = 'add';
        document.getElementById('themeTitle').value            = '';
        document.getElementById('url').value                   = '';
        document.getElementById('themeStatus').checked         = 'true';
        document.getElementById('parentGroupId').value         = id;
        document.getElementById('themeText').innerHTML         = 'Добавить тему';
        document.getElementById('formThemeButton').innerText   = 'Добавить';
        document.getElementById('formGroup').style.display     = 'none';
        document.getElementById('formTheme').style.display     = 'block';
        document.getElementById('formMessage').style.display   = 'none';
    };

    // показывание формы редактирования темы
    function GetTheme( id ) {
        postAjax('http://freee/forum/edit_theme', { id: id }, function( list ){
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
                document.getElementById('themeId').value               = res.theme.id;
                document.getElementById('themeTitle').value            = res.theme.title;
                document.getElementById('url').value                   = res.theme.url;
                document.getElementById('themeStatus').checked         = res.theme.status ? true : false;
                document.getElementById('parentGroupId').value         = res.theme.group_id;
                document.getElementById('themeText').innerHTML         = 'Редактировать тему';
                document.getElementById('formThemeButton').innerText   = 'Сохранить';
                document.getElementById('formGroup').style.display     = 'none';
                document.getElementById('formTheme').style.display     = 'block';
                document.getElementById('formMessage').style.display   = 'none';
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }

    // показывание формы добавления сообщений
    function ShowMessagesAdd( id ){
        document.getElementById('messageId').value             = 'add';
        document.getElementById('msg').value                   = '';
        document.getElementById('messageStatus').checked       = 'true';
        document.getElementById('parentThemeId').value         = id;
        document.getElementById('messageText').innerHTML       = 'Добавить сообщение';
        document.getElementById('formMessageButton').innerText = 'Добавить';
        document.getElementById('formGroup').style.display     = 'none';
        document.getElementById('formTheme').style.display     = 'none';
        document.getElementById('formMessage').style.display   = 'block';
    };

    // показывание формы редактирования сообщения
    function GetMessage( id ) {
        postAjax('http://freee/forum/edit', { id: id }, function( list ){
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
                console.log(res);
                document.getElementById('messageId').value             = res.msg.id;
                document.getElementById('msg').value                   = res.msg.msg;
                document.getElementById('messageStatus').checked       = res.msg.status ? true : false;
                document.getElementById('parentThemeId').value         = res.msg.theme_id;
                document.getElementById('messageText').innerHTML       = 'Редактировать сообщение';
                document.getElementById('formMessageButton').innerText = 'Сохранить';
                document.getElementById('formGroup').style.display     = 'none';
                document.getElementById('formTheme').style.display     = 'none';
                document.getElementById('formMessage').style.display   = 'block';
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }
    // создание кнопки добавления групп
    function DrawGroupsButton(){
        var newTag = document.createElement('i');
        newTag.setAttribute('class', 'fas fa-plus');
        document.getElementById('menuButton').appendChild( newTag );
        newTag.addEventListener('click',function(){
            ShowGroupsAdd();
        });
        document.getElementById('nameplateMessage').style.display = 'none';
    }

    // рисование листа групп
    // id - идентификатор группы, темы которой нужно показать
    function DrawGroupList( id ) {
        // запрос для получения листа групп
        postAjax('http://freee/forum/list_groups', {}, function( list ){
            // раскодирование json
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
                var groupDiv = document.getElementById('groupDiv');

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
                    DrawThemeList ( item.id, id );
                    // отображение тем этой группы
                    groupSpan.addEventListener('click',function(){
                        var pathDiv = document.getElementsByClassName('current_path');
                        pathDiv[0].innerHTML = item.id.toString() + ':';
                        HideThemes();
                        ShowThemes( item.id );
                        document.getElementById('formGroup').style.display   = 'none';
                        document.getElementById('formTheme').style.display   = 'none';
                        document.getElementById('formMessage').style.display = 'none';
                        DeleteMessageList();
                        document.getElementById('navigationThemes').style.display = 'block';
                        document.getElementById('navigationMessages').style.display = 'none';
                    }, false);

                    var newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-trash');
                    groupLine.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/del_group', { id: item.id }, function( list ){
                            ReDrawGroup( list );
                        }), false;
                    });

                    if ( ! item.status) {
                        newTag = document.createElement('i');
                        newTag.setAttribute('class', 'fas fa-eye');
                        groupLine.appendChild( newTag );
                        newTag.addEventListener('click',function(){
                            postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 1 }, function( list ){
                                var res = JSON.parse( list );
                                if ( res.status == 'ok' ) {
                                    DeleteGroupList();
                                    DrawGroupList( 0 );
                                }
                                else {
                                    var errorDiv = document.getElementsByClassName('error');
                                    errorDiv[0].innerHTML = res.message;
                                }
                            }), false;
                        });
                    } 
                    else {
                        newTag = document.createElement('i');
                        newTag.setAttribute('class', 'fas fa-eye-slash');
                        groupLine.appendChild( newTag );
                        newTag.addEventListener('click',function(){
                            postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 0 }, function( list ){
                                var res = JSON.parse( list );
                                if ( res.status == 'ok' ) {
                                    DeleteGroupList();
                                    DrawGroupList( 0 );
                                }
                                else {
                                    var errorDiv = document.getElementsByClassName('error');
                                    errorDiv[0].innerHTML = res.message;
                                }
                            }), false;
                        });
                    }

                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-edit');
                    groupLine.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        GetGroup( item.id );
                    });

                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-plus');
                    groupLine.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        ShowThemesAdd( item.id );
                    });
                });
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }

    //удаление листа групп
    function DeleteGroupList() {
        var groupList = document.querySelectorAll('.groups');
        for (var i = 0; i < groupList.length; i++) {        
            groupList[i].parentNode.removeChild( groupList[i] );
        }
    }

    //обновление списка групп
    function ReDrawGroup( list ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteGroupList();
            // путь к открытой группе
            var pathArray = document.getElementsByClassName('current_path')[0].innerHTML.split( ':' );
            // если обновляется открытая группа
            if ( res.id == Number( pathArray[0] ) ) {
                DeleteMessageList();
                DrawGroupList( 0 );
            }
            else {
                DrawGroupList( pathArray[0] );
            }
        }
        else {
            var errorDiv = document.getElementsByClassName('error');
            errorDiv[0].innerHTML = res.message;
        }
    }

    // рисование списка тем
    function DrawThemeList( groupId, id ) {
        var groupLi = document.getElementById( groupId );
        postAjax('http://freee/forum/list_themes', { group_id: groupId }, function( list ){
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
                res.list.forEach( function( item ) {

                    var themeLi = document.createElement('li');
                    themeLi.setAttribute('class', 'themes');
                    groupLi.appendChild( themeLi );

                    var themeSpan = document.createElement('span');
                    themeSpan.innerHTML = item.title;
                    themeLi.appendChild( themeSpan );
                    themeSpan.addEventListener('click',function(){ 
                        DeleteMessageList(); 
                        DrawMessageList( item.id );
                        document.getElementById('formGroup').style.display   = 'none';
                        document.getElementById('formTheme').style.display   = 'none';
                        document.getElementById('formMessage').style.display = 'none';
                        document.getElementById('navigationMessages').style.display = 'block';
                    }, false);

                    var newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-trash');
                    themeLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/del_theme', { id: item.id }, function( list ){
                            ReDrawTheme( list );
                        }), false;
                    });

                    if ( ! item.status) {
                        newTag = document.createElement('i');
                        newTag.setAttribute('class', 'fas fa-eye');
                        themeLi.appendChild( newTag );
                        newTag.addEventListener('click',function(){
                            postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 1 }, function( list ){
                                var res = JSON.parse( list );
                                if ( res.status == 'ok' ) {
                                    DeleteGroupList();
                                    DrawGroupList( groupId );
                                }
                                else {
                                    var errorDiv = document.getElementsByClassName('error');
                                    errorDiv[0].innerHTML = res.message;
                                }
                            }), false;
                        });
                    }
                    else {
                        newTag = document.createElement('i');
                        newTag.setAttribute('class', 'fas fa-eye-slash');
                        themeLi.appendChild( newTag );
                        newTag.addEventListener('click',function(){
                            postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 0 }, function( list ){
                                var res = JSON.parse( list );
                                if ( res.status == 'ok' ) {
                                    DeleteGroupList();
                                    DrawGroupList( groupId );
                                }
                                else {
                                    var errorDiv = document.getElementsByClassName('error');
                                    errorDiv[0].innerHTML = res.message;
                                }
                            }), false;
                        });
                    }

                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-edit');
                    themeLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        GetTheme( item.id );
                    });

                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-plus');
                    themeLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        ShowMessagesAdd( item.id );
                    });

                    if ( id == groupId ){
                        themeLi.style.display = 'block';
                    } 
                    else {
                        themeLi.style.display = 'none';                    
                    }
                });
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }

    //удалить все темы
    function DeleteThemeList() {
        var themeList = document.querySelectorAll('.themes');
        for (var i = 0; i < themeList.length; i++) {        
            themeList[i].parentNode.removeChild( themeList[i] );
        }
    }

    //обновление списка тем
    function ReDrawTheme( list ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteGroupList();
            // путь к открытой теме
            var pathArray = document.getElementsByClassName('current_path')[0].innerHTML.split( ':' );
            // если обновляется открытая тема
            if ( res.id == Number( pathArray[1] ) ) {
                DeleteMessageList();
            }
            DrawGroupList( pathArray[0] );
        }
        else {
            var errorDiv = document.getElementsByClassName('error');
            errorDiv[0].innerHTML = res.message;
        }
    }

    // показать темы текущей группы
    function ShowThemes( groupId ) {
        var groupLi = document.getElementById( groupId );
        var nodes = groupLi.childNodes;
        for (var i = 0; i < nodes.length; i++) {
            if ( nodes[i].classList.contains( 'themes' ) ){
                nodes[i].style.display = 'block';
            }
        }
    }

    // скрыть все темы
    function HideThemes( themeId ) {
        var themeList = document.querySelectorAll('.themes');
        for (var i = 0; i < themeList.length; i++) {        
            themeList[i].style.display = "none";
        }
    }

    // рисование списка сообщений
    function DrawMessageList( themeId ) {
        var pathDiv = document.getElementsByClassName('current_path');
        var pathArray = pathDiv[0].innerHTML.split( ':' );
        pathDiv[0].innerHTML = pathArray[0] + ':' + themeId.toString();

        postAjax('http://freee/forum/list_messages', { theme_id: themeId }, function( list ){
            var res = JSON.parse( list );
            if ( res.status == 'ok' ) {
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
                        GetMessage( item.id );
                    });
                });
                document.getElementById('nameplateMessage').style.display = 'block';
            }
            else {
                var errorDiv = document.getElementsByClassName('error');
                errorDiv[0].innerHTML = res.message;
            }
        });
    }

    //обновление списка сообщений
    function ReDrawMessage( list, theme_id ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteMessageList(); 
            DrawMessageList( theme_id );
        }
        else {
            var errorDiv = document.getElementsByClassName('error');
            errorDiv[0].innerHTML = res.message;
        }
    }

    function DeleteMessageList() {
        var container = document.getElementById('list_messages_output');
        while (container.firstChild) {
            container.removeChild(container.firstChild);
        }
        document.getElementById('nameplateMessage').style.display = 'none';
    }

    DrawNavigation();
    DrawGroupList( 0 );
    DrawForm();
    DrawGroupsButton();
};