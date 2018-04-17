elm-postgrest-starter-kit

```
# init db and start postgrest
cd scripts
./setup.sh
cd ..
postgrest ./postgrest.conf

# compile and open app
elm-make src/frontend/Main.elm --output=elm.js
open index.html
```

### Prior Work
- https://github.com/subzerocloud/postgrest-starter-kit
- https://github.com/rtfeldman/elm-spa-example
