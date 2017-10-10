import Html exposing (..)
import Html.Attributes exposing (..)



main =
  view


-- MODEL


type alias Model =
  { title : String
  , description: String
  , progress: String
  }

model =
  Model "Skill #1" "Some supporting for a description" "50"


-- UPDATE
-- VIEW


view =
  div [ class "card" ]
    [ div [ class "card-body" ]
        [ h4 [ class "card-title" ] [ text model.title ]
        , p [ class "card-text" ] [ text model.description ]
        , div [ class "progress" ]
            [ div [class "progress-bar", style [ ("width", model.progress ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" model.progress, attribute "aria-valuemin" "0", attribute "aria-valuemax" "100" ] [] ]
        ]
    ]
