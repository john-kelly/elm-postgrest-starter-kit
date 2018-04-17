module Request.User exposing (login, register, storeSession)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.User as User exposing (User)
import Http
import Json.Encode as Encode
import Ports
import PostgRest as PG
import Request.Schema as Schema


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | email : String, password : String } -> Http.Request User
login { email, password } =
    let
        user =
            Encode.object
                [ ("email", Encode.string email)
                , ("password", Encode.string password)
                ]

        body =
            Http.jsonBody user
    in
        Http.request
            { method = "POST"
            , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
            , url = "http://localhost:3000/rpc/login"
            , body = body
            , expect = Http.expectJson User.loginUserDecoder
            , timeout = Nothing
            , withCredentials = False
            }


register : { r | username : String, email : String, password : String } -> Http.Request User
register { username, email, password } =
    let
        user =
            Encode.object
                [ ("email", Encode.string email)
                , ("password", Encode.string password)
                , ("name", Encode.string username)
                ]

        body =
            Http.jsonBody user
    in
        Http.request
            { method = "POST"
            , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
            , url = "http://localhost:3000/rpc/signup"
            , body = body
            , expect = Http.expectJson User.loginUserDecoder
            , timeout = Nothing
            , withCredentials = False
            }
