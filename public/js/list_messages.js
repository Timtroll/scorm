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

    function Draw(data, id) {
    // вывод сообщения в веб-консоль 
console.log(id);
        // возвращает ссылку на элемент по его идентификатору
        var elem = document.getElementById(id);
        // вставляет содержимое data в указанный узел dom дерева
        elem.insertAdjacentHTML( 'afterbegin', data );

        if (id == 'groups') {
            // add edit action
            // массив всех дочерних элементов класса
            var classname = document.getElementsByClassName('edit');
            for (var i = 0; i < classname.length; i++) {
                // событие click на все элементы класса вызывает функцию Edit
                classname[i].addEventListener('click', Edit, false);
            }
            // add delete action
            classname = document.getElementsByClassName('delete');
            for (var i = 0; i < classname.length; i++) {
                classname[i].addEventListener('click', Delete, false);
            }
            // add toggle action
            classname = document.getElementsByClassName('toggle');
            for (var i = 0; i < classname.length; i++) {
                classname[i].addEventListener('click', Toggle, false);
            }
        }
    }

    // события для управления сообщениями
    function Save(data) {
        // возвращается значение id атрибута data
        var id = this.getAttribute('data-id');
        postAjax('http://freee/forum/save', {
            msg : document.getElementById('msg').value,
            id : document.getElementById('id').value,
            theme_id : document.getElementById('theme_id').value,
            status : document.getElementById('status').value,
        }, function(data){
            // перевод json в объект
            var res = JSON.parse(data);
            if (res.status == 'ok') {
                document.getElementById('msg').value = '';
                document.getElementById('id').value = '';
// >????????
                document.getElementById('status').checked   =  res.status ? true : false;
                document.getElementById('btn').innerHTML = 'Добавить';
console.log(res.id);
console.log(res.msg);
            }
            else {

            }
        });
// console.log('edit', id);
    }

    function Add(data) {
        var id = this.getAttribute('data-id');
        postAjax('http://freee/forum/edit', { id: id }, function(data){
            var res = JSON.parse(data);
            document.getElementById('msg').value        = '';
            document.getElementById('id').value         = '';
            document.getElementById('status').checked = true;
            document.getElementById('btn').innerHTML    = 'Добавить';
// console.log(res.id);
// console.log(res.msg);
        });
// console.log('edit', id);
    }

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
                groupDiv.appendChild( groupLi );

                var groupSpan = document.createElement('span');
                groupSpan.innerHTML = item.name;
                groupSpan.setAttribute('class', 'groupName');
                groupLi.appendChild( groupSpan );
                // рисование листа тем
                DrawThemeList (item.id, groupLi, groupDiv );
                // отображение тем этой группы
                groupSpan.addEventListener('click',function(){
                    HideThemes();
                    ShowThemes( groupLi );
                }, false);

                var newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-edit');
                groupLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 1 }, function(){}), false;
                });

                if ( ! item.status) {
                    newTag = document.createElement('i');
                    newTag.setAttribute('class', 'fas fa-eye');
                    groupLi.appendChild( newTag );
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
                    groupLi.appendChild( newTag );
                    newTag.addEventListener('click',function(){
                        postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_groups', value: 0 }, function( list ){
                            DeleteGroupList();
                            DrawGroupList();
                        }), false;
                    });
                }

                newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-trash');
                groupLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/del_group', { id: item.id }, function( list ){
                        ReDrawGroup( list, groupLi, groupDiv );
                    }), false;
                });
            });                                
        });
    }

    function ReDrawGroup( list, groupLi, groupDiv ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteGroupList();
            DrawGroupList();
            DeleteThemeList();
            var pathArray = document.getElementById('current_path').innerHTML.split( ':' );
            if ( res.id == Number( pathArray[0] ) ) {
                DeleteMessageList(); 
            }
            else {
                // нужен li открытой группы
                DrawThemeList( Number( pathArray[0] ), groupLi, groupDiv );
            }
        }
        else {
            var errorDiv = document.getElementById('error');
            errorDiv.innerHTML = res.message;
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
        var pathDiv = document.getElementById('current_path');
        pathDiv.innerHTML = groupId.toString() + ':';

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
                newTag.setAttribute('class', 'fas fa-edit');
                themeLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_themes', value: 1 }, function(){}), false;
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
                newTag.setAttribute('class', 'fas fa-trash');
                themeLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/del_theme', { id: item.id }, function( list ){
                        ShowThemes( list, groupId, groupLi, groupDiv );
                    }), false;
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

    function ShowThemes( groupLi ) {
        // показать темы текущей группы
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
        var pathDiv = document.getElementById('current_path');
        // pathDiv.innerHTML = pathDiv.innerHTML.substring( 0, pathDiv.innerHTML.indexOf( ':' ) + 1 ) + themeId.toString();
        var pathArray = pathDiv.innerHTML.split( ':' );
        pathDiv.innerHTML = pathArray[0] + ':' + themeId.toString();

//         var pathArray = pathDiv.innerHTML.split( ':' );
//         var a = pathArray[1] + 1000;
// console.log(Number( pathArray[1] ));
// console.log( pathArray[1] );
// console.log( a );

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
                newTag.setAttribute('class', 'fas fa-edit');
                newLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/toggle', { id: item.id, table: 'forum_messages', value: 1 }, function(){}), false;
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
                newTag.setAttribute('class', 'fas fa-trash');
                newLi.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/delete', { id: item.id }, function( list ){
                        ReDrawMessage( list, themeId );
                    }), false;
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
            var errorDiv = document.getElementById('error');
            errorDiv.innerHTML = res.message;
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

    document.getElementById('add').addEventListener('click', Add, false);
    document.getElementById('btn').addEventListener('click', Save, false);


    var id = 1;

    DrawGroupList();
    // postAjax('http://freee/forum/list_themes', { id: id }, function(data){ Draw(data, 'menu'); },  Error );

    // postAjax('http://freee/forum/list_messages', { {id: id }, function(data){ Draw(data, 'messages'); }, Error );
};