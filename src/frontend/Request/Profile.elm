module Request.Profile exposing (get)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.Profile as Profile exposing (Profile)
import Data.User as User exposing (Username)
import Data.UserPhoto
import Http
import PostgRest as PG
import Request.Schema as Schema


-- GET --


get : Username -> Maybe AuthToken -> Http.Request Profile
get username maybeToken =
    PG.readOne Schema.profile
        { select = selection
        , where_ = PG.eq username .name
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = maybeToken
            , timeout = Nothing
            }



selection : PG.Selection
    { attributes
        | bio : PG.Attribute (Maybe String)
        , image : PG.Attribute Data.UserPhoto.UserPhoto
        , name : PG.Attribute Username
    }
    Profile
selection = PG.map3 Profile
    (PG.field .name)
    (PG.field .bio)
    (PG.field .image)
