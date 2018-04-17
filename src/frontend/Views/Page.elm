module Views.Page exposing (ActivePage(..), frame)

{-| The frame around a typical page - that is, the header and footer.
-}

import Data.User as User exposing (User, Username)
import Data.UserPhoto as UserPhoto exposing (UserPhoto)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type ActivePage
    = Other
    | Home
    | Login
    | Register


{-| Take a page's Html and frame it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

-}
frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    div [ ]
        [ viewHeader page user isLoading
        , content
        , viewFooter
        ]


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    nav [ ]
        [ ul [ ]
            (navbarLink page Route.Home [ text "Home" ] :: viewSignIn page user)
        ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    let
        linkTo =
            navbarLink page
    in
    case user of
        Nothing ->
            [ linkTo Route.Login [ text "Sign in" ]
            , linkTo Route.Register [ text "Sign up" ]
            ]

        Just user ->
            [ linkTo Route.Logout [ text "Sign out" ]
            ]


viewFooter : Html msg
viewFooter =
    footer [] []


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ ] [ a [ Route.href route ] linkContent ]
