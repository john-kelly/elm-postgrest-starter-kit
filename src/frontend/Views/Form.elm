module Views.Form exposing (input, password, textarea)

import Html exposing (Attribute, Html, fieldset, li, text, ul)
import Html.Attributes exposing (class, type_)


password : List (Attribute msg) -> List (Html msg) -> Html msg
password attrs =
    control Html.input ([ type_ "password" ] ++ attrs)


input : List (Attribute msg) -> List (Html msg) -> Html msg
input attrs =
    control Html.input ([ type_ "text" ] ++ attrs)


textarea : List (Attribute msg) -> List (Html msg) -> Html msg
textarea =
    control Html.textarea


-- INTERNAL --


control :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
control element attributes children =
    fieldset [] [ element attributes children ]
