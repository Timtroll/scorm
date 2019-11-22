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

    function ListMessages() {
        var data_id = this.getAttribute('data-id');
        postAjax('http://freee/forum/list_messages', { theme_id: data_id }, function( list ){
            var res = JSON.parse( list );
            const messages = [];

            var newUl = document.createElement("ul");
            var list_tag = document.getElementById('list_messages_output');
            list_tag.appendChild( newUl );

            res.list.forEach( function( item ) {
                var newLi = document.createElement("li");
                    newLi.innerHTML = item.msg;
                newUl.appendChild( newLi );
            });                                
        });
    }

    function ListGroups() {
        postAjax('http://freee/forum/list_groups', {}, function( list ){
            var res = JSON.parse( list );
            const groups = [];
            // создаётся тэг ul
            var groupUl = document.createElement("ul");
            // создаётся тэг groups
            var groupListTag = document.getElementById('groups');
            // ul вставляется в groups
            groupListTag.appendChild( groupUl );

            // проход по группам
            res.list.forEach( function( item ) {
                // создаётся тэг li
                var groupLi = document.createElement("li");
                // в li выводятся группы
                groupLi.innerHTML = item.name;
                // обработчик события клик на группы
                groupLi.addEventListener('click',function(){ 
                    DeleteThemeList( list, groupUl ); 
                    ListThemes( item.id, groupLi, groupUl );
                }, false);
                // li вставляется в ul
                groupUl.appendChild( groupLi );
            });                                
        });
    }

    function DeleteThemeList( list, groupUl ) {
        var themeDiv = document.querySelectorAll('.themes');
        for (var i = 0; i < themeDiv.length; i++) {        
            themeDiv[i].parentNode.removeChild( themeDiv[i] );
        }
    }

    function ListThemes( groupId, groupLi, groupUl ) {
        postAjax('http://freee/forum/list_themes', { group_id: groupId }, function( list ){
            var res = JSON.parse( list );
            const messages = [];

            res.list.forEach( function( item ) {
                var themeDiv = document.createElement("div");
                themeDiv.setAttribute('class', 'themes');
                var themeLi = document.createElement("dd");
                themeDiv.appendChild( themeLi );
                themeLi.innerHTML = item.title;
                groupUl.insertBefore( themeDiv, groupLi.nextSibling);
            });                                
        });
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

    document.getElementById('list_messages').addEventListener('click', ListMessages, false);

    var id = 1;

    ListGroups();

    // postAjax('http://freee/forum/list_themes', { id: id }, function(data){ Draw(data, 'menu'); },  Error );

    // postAjax('http://freee/forum/list_messages', { {id: id }, function(data){ Draw(data, 'messages'); }, Error );
};