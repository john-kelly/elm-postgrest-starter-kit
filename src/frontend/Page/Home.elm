module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Data.Session as Session exposing (Session)
import Data.User as User
import Html exposing (..)
import Page.Errored as Errored exposing (PageLoadError)
import Task exposing (Task)


-- MODEL --


type alias Model = ()


init : Session -> Task PageLoadError Model
init session =
    Task.succeed ()



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    case session.user of
        Nothing ->
            text "You are logged out."
        Just user ->
            text ("Hello, " ++ User.usernameToString user.username)


-- UPDATE --


type Msg = Msg


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model = ((), Cmd.none)
