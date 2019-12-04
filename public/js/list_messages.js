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

//     function Add(data) {
//         var id = this.getAttribute('data-id');
//         postAjax('http://freee/forum/edit', { id: id }, function(data){
//             var res = JSON.parse(data);
//             document.getElementById('msg').value        = '';
//             document.getElementById('id').value         = '';
//             document.getElementById('status').checked = true;
//             document.getElementById('btn').innerHTML    = 'Добавить';
// // console.log(res.id);
// // console.log(res.msg);
//         });
// // console.log('edit', id);
//     }

    function DrawForm() {
        var contentDiv = document.getElementsByClassName('content');
        var formDiv = document.createElement('div');
        contentDiv[0].appendChild( formDiv );

        var formGroupDiv = document.createElement('div');
        formDiv.appendChild( formGroupDiv );

        var formGroupH2 = document.createElement('h2');
        formGroupDiv.appendChild( formGroupH2 );
        formGroupDiv.innerHTML = 'Добавить группу';

        var formGroupInputName = document.createElement('textarea');
        formGroupDiv.appendChild( formGroupInputName );
        formGroupInputName.setAttribute('id', 'name');
        formGroupInputName.setAttribute('name', 'name');
        formGroupInputName.setAttribute('rows', '5');
        formGroupInputName.setAttribute('cols', '40');

        var formGroupInputTitle = document.createElement('textarea');
        formGroupDiv.appendChild( formGroupInputTitle );
        formGroupInputTitle.setAttribute('id', 'title');
        formGroupInputTitle.setAttribute('name', 'title');
        formGroupInputTitle.setAttribute('rows', '5');
        formGroupInputTitle.setAttribute('cols', '40');

        var formGroupLabel = document.createElement('label');
        formGroupDiv.appendChild( formGroupLabel );

        var formGroupInputStatus = document.createElement('input');
        formGroupLabel.appendChild( formGroupInputStatus );
        formGroupInputStatus.setAttribute('id', 'status');
        formGroupInputStatus.setAttribute('type', 'checkbox');
        formGroupInputStatus.setAttribute('name', 'status');
        formGroupInputStatus.setAttribute('value', '1');
        formGroupInputStatus.setAttribute('checked', 'checked');

        var formGroupButton = document.createElement('button');
        formGroupLabel.appendChild( formGroupButton );
        formGroupButton.innerHTML = 'Добавить группу';

        formGroupButton.addEventListener('click',function(){
            postAjax('http://freee/forum/save_add_group', {
                name : document.getElementById('name').value,
                title : document.getElementById('title').value,
                status : document.getElementById('status').value,
            }, function(){
                ReDrawGroup( list, groupLi, groupDiv );
            });
        }, false);
        formGroupDiv.style.display = 'none';

//////////////////////////////////////////////////////////////////////////////////////
        var formThemeDiv = document.createElement('div');
        formDiv.appendChild( formThemeDiv );

        var formThemeH2 = document.createElement('h2');
        formThemeDiv.appendChild( formThemeH2 );
        formThemeDiv.innerHTML = 'Добавить группу';

        var formThemeInputName = document.createElement('textarea');
        formThemeDiv.appendChild( formThemeInputName );
        formThemeInputName.setAttribute('id', 'name');
        formThemeInputName.setAttribute('name', 'name');
        formThemeInputName.setAttribute('rows', '5');
        formThemeInputName.setAttribute('cols', '40');

        var formThemeInputTitle = document.createElement('textarea');
        formThemeDiv.appendChild( formThemeInputTitle );
        formThemeInputTitle.setAttribute('id', 'title');
        formThemeInputTitle.setAttribute('name', 'title');
        formThemeInputTitle.setAttribute('rows', '5');
        formThemeInputTitle.setAttribute('cols', '40');

        var formThemeLabel = document.createElement('label');
        formThemeDiv.appendChild( formThemeLabel );

        var formThemeInputStatus = document.createElement('input');
        formThemeLabel.appendChild( formThemeInputStatus );
        formThemeInputStatus.setAttribute('id', 'status');
        formThemeInputStatus.setAttribute('type', 'checkbox');
        formThemeInputStatus.setAttribute('name', 'status');
        formThemeInputStatus.setAttribute('value', '1');
        formThemeInputStatus.setAttribute('checked', 'checked');

        var formThemeButton = document.createElement('button');
        formThemeLabel.appendChild( formThemeButton );
        formThemeButton.innerHTML = 'Добавить группу';

        formThemeButton.addEventListener('click',function(){
            postAjax('http://freee/forum/save_add_group', {
                name : document.getElementById('name').value,
                title : document.getElementById('title').value,
                status : document.getElementById('status').value,
            }, function(){
            });
        }, false);
        formThemeDiv.style.display = 'block';

//////////////////////////////////////////////////////////////////////////////////////
        var formMessageDiv = document.createElement('div');
        formDiv.appendChild( formMessageDiv );

        var formMessageH2 = document.createElement('h2');
        formMessageDiv.appendChild( formMessageH2 );
        formMessageDiv.innerHTML = 'Добавить группу';

        var formMessageInputName = document.createElement('textarea');
        formMessageDiv.appendChild( formMessageInputName );
        formMessageInputName.setAttribute('id', 'name');
        formMessageInputName.setAttribute('name', 'name');
        formMessageInputName.setAttribute('rows', '5');
        formMessageInputName.setAttribute('cols', '40');

        var formMessageInputTitle = document.createElement('textarea');
        formMessageDiv.appendChild( formMessageInputTitle );
        formMessageInputTitle.setAttribute('id', 'title');
        formMessageInputTitle.setAttribute('name', 'title');
        formMessageInputTitle.setAttribute('rows', '5');
        formMessageInputTitle.setAttribute('cols', '40');

        var formMessageLabel = document.createElement('label');
        formMessageDiv.appendChild( formMessageLabel );

        var formMessageInputStatus = document.createElement('input');
        formMessageLabel.appendChild( formMessageInputStatus );
        formMessageInputStatus.setAttribute('id', 'status');
        formMessageInputStatus.setAttribute('type', 'checkbox');
        formMessageInputStatus.setAttribute('name', 'status');
        formMessageInputStatus.setAttribute('value', '1');
        formMessageInputStatus.setAttribute('checked', 'checked');

        var formMessageButton = document.createElement('button');
        formMessageLabel.appendChild( formMessageButton );
        formMessageButton.innerHTML = 'Добавить группу';

        formMessageButton.addEventListener('click',function(){
            postAjax('http://freee/forum/save_add_group', {
                name : document.getElementById('name').value,
                title : document.getElementById('title').value,
                status : document.getElementById('status').value,
            }, function(){
            });
        }, false);
        formMessageDiv.style.display = 'block';
        
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
                    ShowThemes( groupLi );
                }, false);

                var newTag = document.createElement('i');
                newTag.setAttribute('class', 'fas fa-trash');
                groupLine.appendChild( newTag );
                newTag.addEventListener('click',function(){
                    postAjax('http://freee/forum/del_group', { id: item.id }, function( list ){
                        ReDrawGroup( list, groupLi, groupDiv );
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
            });                                
        });
    }

    function ReDrawGroup( list, groupLi, groupDiv ) {
        var res = JSON.parse( list );
        if ( res.status == 'ok' ) {
            DeleteGroupList();
            DrawGroupList();
            DeleteThemeList();
            var pathArray = document.getElementsByClassName('current_path').innerHTML.split( ':' );
            if ( res.id == Number( pathArray[0] ) ) {
                DeleteMessageList(); 
            }
            else {
                // нужен li открытой группы
                DrawThemeList( Number( pathArray[0] ), groupLi, groupDiv );
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
                        ShowThemes( list, groupId, groupLi, groupDiv );
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
        var pathDiv = document.getElementsByClassName('current_path');
        // pathDiv.innerHTML = pathDiv.innerHTML.substring( 0, pathDiv.innerHTML.indexOf( ':' ) + 1 ) + themeId.toString();
        var pathArray = pathDiv[0].innerHTML.split( ':' );
        pathDiv[0].innerHTML = pathArray[0] + ':' + themeId.toString();

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

    DrawForm();
    DrawGroupList();
    // postAjax('http://freee/forum/list_themes', { id: id }, function(data){ Draw(data, 'menu'); },  Error );

    // postAjax('http://freee/forum/list_messages', { {id: id }, function(data){ Draw(data, 'messages'); }, Error );
};