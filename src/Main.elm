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
  div []
    [ addSkillForm
    , hr [] []
    , skillList model
    ]

addSkillForm : Html msg
addSkillForm =
  div [ class "row" ]
    [ div [ class "col" ]
        [ Html.form []
            [ div [ class "form-group row" ]
                [ label [ for "somethingName", class "col-sm-2 col-form-label" ] [ text "Name" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingName" ] [] ]
                ]
            , div [ class "form-group row" ]
                [ label [ for "somethingDescription", class "col-sm-2 col-form-label" ] [ text "Description" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingDescription" ] [] ]
                ]
            , button [ type_ "submit", class "btn btn-primary" ] [ text "Add" ]
            ]
        ]
    ]

skillList : Model -> Html msg
skillList model =
  div [ class "row" ]
    [ div [ class "col" ] (List.map skillComponent model) ]

skillComponent : Skill -> Html msg
skillComponent skill =
  div [ class "card" ]
    [ div [ class "card-body" ]
        [ h4 [ class "card-title" ] [ text skill.title ]
        , p [ class "card-text" ] [ text skill.description ]
        , div [ class "progress" ]
            [ div [class "progress-bar", style [ ("width", skill.progress ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" skill.progress, attribute "aria-valuemin" "0", attribute "aria-valuemax" "100" ] [] ]
        ]
    ]
