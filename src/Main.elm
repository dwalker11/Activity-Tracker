import Html exposing (..)
import Html.Attributes exposing (..)



main =
  view model


-- MODEL


type alias Skill =
  { title : String
  , description: String
  , progress: String
  }

type alias Model =
  List Skill

model : Model
model =
  [ Skill "Skill #1" "Some supporting for a description" "50"
  , Skill "Skill #2" "Some supporting for a description" "25"
  ]


-- UPDATE
-- VIEW


view : Model -> Html msg
view model =
  div [ class "col" ] (List.map skillComponent model)

skillComponent : Skill -> Html msg
skillComponent model =
  div [ class "card" ]
    [ div [ class "card-body" ]
        [ h4 [ class "card-title" ] [ text model.title ]
        , p [ class "card-text" ] [ text model.description ]
        , div [ class "progress" ]
            [ div [class "progress-bar", style [ ("width", model.progress ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" model.progress, attribute "aria-valuemin" "0", attribute "aria-valuemax" "100" ] [] ]
        ]
    ]
