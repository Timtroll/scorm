# scorm-admin

## NodeJs setup
```
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt install -y nodejs
```

```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install yarn
```

## Project setup
```
yarn install
```

### Compiles and hot-reloads for development
```
yarn run serve
```

### Compiles and minifies for production
```
yarn run build
```


### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
