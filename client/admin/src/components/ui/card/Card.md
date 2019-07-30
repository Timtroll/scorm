# CARD

### Пример использования
```
<Card :header="true"
        :header-left="true"
        :header-right="true"
        :footer="true"
        :footer-left="true"
        :footer-right="true"
        :body-left="true"
        :body-right="true">

    <!--header-->
    <template #headerLeft>headerLeft</template>
    <template #headerRight>headerRight</template>
    <template #header>header</template>

    <!--footer-->
    <template #footerLeft>footerLeft</template>
    <template #footerRight>footerRight</template>
    <template #footer>footer</template>

    <!--Body-->
    <template #body>Body</template>
    <template #bodyLeft>bodyLeft</template>
    <template #bodyRight>bodyRight</template>


  </Card>
```
### PROPS

| Props | type | default | descriptions |
|---|---|---|---|
| header | Boolean | false | Показать header |
| headerLeft | Boolean | false | Показать headerLeft |
| headerRight | Boolean | false | Показать headerRight |
| footer | Boolean | false | Показать footer |
| footerLeft | Boolean | false | Показать footerLeft |
| footerRight | Boolean | false | Показать footerRight |
| bodyLeft | Boolean | false | Показать bodyLeft |
| bodyRight | Boolean | false | Показать bodyRight |
| bodyPadding | Boolean | true | Есть отступы в Body |
| bodyLeftPadding | Boolean | true | Есть отступы в bodyLeft |
| bodyRightPadding | Boolean | true | Есть отступы в bodyRight|

### Слоты: 

**header**
1. header - html
2. headerleft - html
3. headerRight - html

**footer**
1. footer - html
1. footerleft - html
2. footerRight - html

**Body**
1. body - html
1. footerleft - html
2. footerRight - html
