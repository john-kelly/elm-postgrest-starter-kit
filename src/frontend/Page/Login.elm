module Page.Login exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

{-| The login page.
-}

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Request.User exposing (storeSession)
import Route exposing (Route)
import Views.Form as Form


-- MODEL --


type alias Model =
    { error : Maybe String
    , email : String
    , password : String
    }


initialModel : Model
initialModel =
    { error = Nothing
    , email = ""
    , password = ""
    }



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div [ ]
        [ h1 [ ] [ text "Sign in" ]
        , a [ Route.href Route.Register ] [ text "Need an account?" ]
        , case model.error of
            Nothing -> text ""
            Just error -> div [] [text error]
        , viewForm
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input
            [ placeholder "Email"
            , onInput SetEmail
            ]
            []
        , Form.password
            [ placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [] [ text "Sign in" ]
        ]



-- UPDATE --


type Msg
    = SubmitForm
    | SetEmail String
    | SetPassword String
    | LoginCompleted (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            (({ model | error = Nothing }, Http.send LoginCompleted (Request.User.login model)), NoOp)

        SetEmail email ->
            (({ model | email = email }, Cmd.none), NoOp)

        SetPassword password ->
            (({ model | password = password }, Cmd.none), NoOp)

        LoginCompleted (Err error) ->
            (({ model | error = Just "unable to process login" }, Cmd.none), NoOp)

        LoginCompleted (Ok user) ->
            ((model, Cmd.batch [ storeSession user, Route.modifyUrl Route.Home ]), SetUser user)
