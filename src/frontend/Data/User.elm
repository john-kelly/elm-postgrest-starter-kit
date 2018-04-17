module Data.User exposing (User, Username, decoder, loginUserDecoder, encode, usernameDecoder, usernameParser, usernameToHtml, usernameToString, usernameAttribute)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.UserPhoto as UserPhoto exposing (UserPhoto)
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import PostgRest as PG
import UrlParser


type alias User =
    { email : String
    , token : AuthToken
    , username : Username
    , bio : Maybe String
    , image : UserPhoto
    }



-- SERIALIZATION --


decoder : Decoder User
decoder =
    Decode.map5 User
        (Decode.field "email" Decode.string)
        (Decode.field "token" AuthToken.decoder)
        (Decode.field "username" usernameDecoder)
        (Decode.field "bio" (Decode.nullable Decode.string))
        (Decode.field "image" UserPhoto.decoder)


loginUserDecoder : Decoder User
loginUserDecoder =
    Decode.map5 User
        (Decode.field "me" (Decode.field "email" Decode.string))
        (Decode.field "token" AuthToken.decoder)
        (Decode.field "me" (Decode.field "name" usernameDecoder))
        (Decode.field "me" (Decode.field "bio" (Decode.nullable Decode.string)))
        (Decode.field "me" (Decode.field "image" UserPhoto.decoder))


encode : User -> Value
encode user =
    Encode.object
        [ ("email", Encode.string user.email)
        , ("token", AuthToken.encode user.token)
        , ("username", encodeUsername user.username)
        , ("bio", Maybe.withDefault Encode.null (Maybe.map Encode.string user.bio))
        , ("image", UserPhoto.encode user.image)
        ]



-- IDENTIFIERS --


type Username
    = Username String


usernameToString : Username -> String
usernameToString (Username username) =
    username


usernameParser : UrlParser.Parser (Username -> a) a
usernameParser =
    UrlParser.custom "USERNAME" (Ok << Username)


usernameDecoder : Decoder Username
usernameDecoder =
    Decode.map Username Decode.string


encodeUsername : Username -> Value
encodeUsername (Username username) =
    Encode.string username


usernameToHtml : Username -> Html msg
usernameToHtml (Username username) =
    Html.text username


usernameAttribute : String -> PG.Attribute Username
usernameAttribute name =
    PG.attribute
        { decoder = usernameDecoder
        , encoder = encodeUsername
        , urlEncoder = usernameToString
        }
        name
