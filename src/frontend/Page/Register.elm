module Page.Register exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.User exposing (storeSession)
import Route exposing (Route)
import Views.Form as Form


-- MODEL --


type alias Model =
    { error : Maybe String
    , email : String
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { error = Nothing
    , email = ""
    , username = ""
    , password = ""
    }



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div []
        [ h1 [] [ text "Sign up" ]
        , a [ Route.href Route.Login ] [ text "Have an account?" ]
        , case model.error of
            Nothing -> text ""
            Just error -> div [] [text error]
        , viewForm
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input
            [ placeholder "Username"
            , onInput SetUsername
            ]
            []
        , Form.input
            [ placeholder "Email"
            , onInput SetEmail
            ]
            []
        , Form.password
            [ placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [] [ text "Sign up" ]
        ]



-- UPDATE --


type Msg
    = SubmitForm
    | SetEmail String
    | SetUsername String
    | SetPassword String
    | RegisterCompleted (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            (({model | error = Nothing}, Http.send RegisterCompleted (Request.User.register model)), NoOp)

        SetEmail email ->
            (({ model | email = email }, Cmd.none), NoOp)

        SetUsername username ->
            (({ model | username = username }, Cmd.none), NoOp)

        SetPassword password ->
            (({ model | password = password }, Cmd.none), NoOp)

        RegisterCompleted (Err error) ->
            (({ model | error = Just "unable to process registration" }, Cmd.none), NoOp)

        RegisterCompleted (Ok user) ->
            ((model, Cmd.batch [ storeSession user, Route.modifyUrl Route.Home ]), SetUser user)
