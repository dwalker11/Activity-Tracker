import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)



main =
  Html.beginnerProgram
    { model = model
    , view = view
    , update = update
    }


-- MODEL


type alias Skill =
  { title : String
  , description: String
  , progress: String
  }

type alias NewSkill =
  { name: String
  , description: String
  }

type alias Model =
  { skillList: List Skill
  , newSkill: NewSkill
  }

model : Model
model =
  { skillList = []
  , newSkill = NewSkill "" ""
  }


-- UPDATE


type Msg
  = UpdateName String
  | UpdateDescription String
  | AddSkill

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateName xName ->
      let
        oldSkill = model.newSkill

        skill = { oldSkill | name = xName }
      in
        { model | newSkill = skill }
    UpdateDescription xDescription ->
      let
        oldSkill = model.newSkill

        skill = { oldSkill | description = xDescription }
      in
        { model | newSkill = skill }
    AddSkill ->
      let
        newSkill = Skill (.name model.newSkill) (.description model.newSkill) (toString 0)

        updatedSkillList = newSkill :: model.skillList
      in
        { model | skillList = updatedSkillList }


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ addSkillForm model.newSkill
    , hr [] []
    , skillList model.skillList
    ]

addSkillForm : NewSkill -> Html Msg
addSkillForm newSkill =
  div [ class "row" ]
    [ div [ class "col" ]
        [ Html.form []
            [ div [ class "form-group row" ]
                [ label [ for "somethingName", class "col-sm-2 col-form-label" ] [ text "Name" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingName", onInput UpdateName ] [] ]
                ]
            , div [ class "form-group row" ]
                [ label [ for "somethingDescription", class "col-sm-2 col-form-label" ] [ text "Description" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingDescription", onInput UpdateDescription ] [] ]
                ]
            , button [ type_ "button", class "btn btn-primary", onClick AddSkill ] [ text "Add" ]
            ]
        ]
    ]

skillList : List Skill -> Html Msg
skillList skillList =
  div [ class "row" ]
    [ div [ class "col" ] (List.map skillComponent skillList) ]

skillComponent : Skill -> Html Msg
skillComponent skill =
  div [ class "card" ]
    [ div [ class "card-body" ]
        [ h4 [ class "card-title" ] [ text skill.title ]
        , p [ class "card-text" ] [ text skill.description ]
        , div [ class "progress" ]
            [ div [ class "progress-bar", style [ ("width", skill.progress ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" skill.progress, attribute "aria-valuemin" "0", attribute "aria-valuemax" "100" ] [] ]
        ]
    ]
