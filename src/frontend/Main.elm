module Main exposing (main)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username)
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Navigation exposing (Location)
import Page.Errored as Errored exposing (PageLoadError)
import Page.Home as Home
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Register as Register
import Ports
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)


-- WARNING: Based on discussions around how asset management features
-- like code splitting and lazy loading have been shaping up, I expect
-- most of this file to become unnecessary in a future release of Elm.
-- Avoid putting things in here unless there is no alternative!


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Home Home.Model
    | Login Login.Model
    | Register Register.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL --


type alias Model =
    { session : Session
    , pageState : PageState
    }


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = decodeUserFromJson val }
        }


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString User.decoder >> Result.toMaybe)


initialPage : Page
initialPage =
    Blank



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page


viewPage : Session -> Bool -> Page -> Html Msg
viewPage session isLoading page =
    let
        frame =
            Page.frame isLoading session.user
    in
    case page of
        NotFound ->
            NotFound.view session
                |> frame Page.Other

        Blank ->
            -- This is for the very initial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            Html.text ""
                |> frame Page.Other

        Errored subModel ->
            Errored.view session subModel
                |> frame Page.Other

        Home subModel ->
            Home.view session subModel
                |> frame Page.Home
                |> Html.map HomeMsg

        Login subModel ->
            Login.view session subModel
                |> frame Page.Other
                |> Html.map LoginMsg

        Register subModel ->
            Register.view session subModel
                |> frame Page.Other
                |> Html.map RegisterMsg



-- SUBSCRIPTIONS --
-- Note: we aren't currently doing any page subscriptions, but I thought it would
-- be a good idea to put this in here as an example. If I were actually
-- maintaining this in production, I wouldn't bother until I needed this!


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
        , Sub.map SetUser sessionChange
        ]


sessionChange : Sub (Maybe User)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Blank ->
            Sub.none

        Errored _ ->
            Sub.none

        NotFound ->
            Sub.none

        Home _ ->
            Sub.none

        Login _ ->
            Sub.none

        Register _ ->
            Sub.none



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | HomeLoaded (Result PageLoadError Home.Model)
    | HomeMsg Home.Msg
    | SetUser (Maybe User)
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            ({ model | pageState = TransitioningFrom (getPage model.pageState) }, Task.attempt toMsg task)

        errored =
            pageErrored model
    in
    case maybeRoute of
        Nothing ->
            ({ model | pageState = Loaded NotFound }, Cmd.none)

        Just Route.Home ->
            transition HomeLoaded (Home.init model.session)

        Just Route.Login ->
            ({ model | pageState = Loaded (Login Login.initialModel) }, Cmd.none)

        Just Route.Logout ->
            let
                session =
                    model.session
                cmd =
                    Cmd.batch
                        [ Ports.storeSession Nothing
                        , Route.modifyUrl Route.Home
                        ]
            in
            ({ model | session = { session | user = Nothing } }, cmd)

        Just Route.Register ->
            ({ model | pageState = Loaded (Register Register.initialModel) }, Cmd.none)


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
    ({ model | pageState = Loaded (Errored error) }, Cmd.none)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        session =
            model.session

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
            ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

        errored =
            pageErrored model
    in
    case ( msg, page ) of
        ( SetRoute route, _ ) ->
            setRoute route model

        ( HomeLoaded (Ok subModel), _ ) ->
            ({ model | pageState = Loaded (Home subModel) }, Cmd.none)

        ( HomeLoaded (Err error), _ ) ->
            ({ model | pageState = Loaded (Errored error) }, Cmd.none)

        ( SetUser user, _ ) ->
            let
                session =
                    model.session

                cmd =
                    -- If we just signed out, then redirect to Home.
                    if session.user /= Nothing && user == Nothing then
                        Route.modifyUrl Route.Home
                    else
                        Cmd.none
            in
            ({ model | session = { session | user = user } }, cmd)

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Login.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Login.NoOp ->
                            model

                        Login.SetUser user ->
                            let
                                session =
                                    model.session
                            in
                            { model | session = { user = Just user } }
            in
            ({ newModel | pageState = Loaded (Login pageModel) }, Cmd.map LoginMsg cmd)

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Register.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Register.NoOp ->
                            model

                        Register.SetUser user ->
                            let
                                session =
                                    model.session
                            in
                            { model | session = { user = Just user } }
            in
            ({ newModel | pageState = Loaded (Register pageModel) }, Cmd.map RegisterMsg cmd)

        ( HomeMsg subMsg, Home subModel ) ->
            toPage Home HomeMsg (Home.update session) subMsg subModel

        ( _, NotFound ) ->
            -- Disregard incoming messages when we're on the
            -- NotFound page.
            (model, Cmd.none)

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            (model, Cmd.none)



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
