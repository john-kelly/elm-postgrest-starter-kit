module Page.NotFound exposing (view)

import Data.Session as Session exposing (Session)
import Html exposing (Html, h1, main_, text)


-- VIEW --


view : Session -> Html msg
view session =
    main_ [ ] [ h1 [] [ text "Not Found" ] ]
