module Request.Schema
    exposing
        ( profile, Profile
        )

import Data.User as User
import Data.UserPhoto as UserPhoto

import PostgRest as PG


type Profile = Profile


profile :
    PG.Schema Profile
        { name : PG.Attribute User.Username
        , email : PG.Attribute String
        , bio : PG.Attribute (Maybe String)
        , image : PG.Attribute UserPhoto.UserPhoto
        }
profile =
    PG.schema "profiles"
        { name = User.usernameAttribute "name"
        , email = PG.string "email"
        , bio = PG.nullable (PG.string "bio")
        , image = UserPhoto.attribute "image"
        }
