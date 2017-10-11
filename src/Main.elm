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
  , time: Int
  }

type alias NewSkill =
  { name: String
  , description: String
  }

type alias Model =
  { list: List Skill
  , skill: NewSkill
  }

model : Model
model =
  { list = []
  , skill = NewSkill "" ""
  }


-- UPDATE


type Msg
  = UpdateSkillName String
  | UpdateSkillDescription String
  | AddSkillToList

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateSkillName updatedName ->
      let
        oldSkill = model.skill

        updatedSkill = { oldSkill | name = updatedName }
      in
        { model | skill = updatedSkill }
    UpdateSkillDescription updatedDescription ->
      let
        oldSkill = model.skill

        updatedSkill = { oldSkill | description = updatedDescription }
      in
        { model | skill = updatedSkill }
    AddSkillToList ->
      let
        newSkill = Skill (model.skill.name) (model.skill.description) 0

        updatedSkillList = newSkill :: model.list
      in
        { model | list = updatedSkillList }


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ addSkillForm model.skill
    , hr [] []
    , overvallProgress model.list
    , hr [] []
    , skillList model.list
    ]

addSkillForm : NewSkill -> Html Msg
addSkillForm newSkill =
  div [ class "row" ]
    [ div [ class "col" ]
        [ Html.form []
            [ div [ class "form-group row" ]
                [ label [ for "somethingName", class "col-sm-2 col-form-label" ] [ text "Name" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingName", onInput UpdateSkillName ] [] ]
                ]
            , div [ class "form-group row" ]
                [ label [ for "somethingDescription", class "col-sm-2 col-form-label" ] [ text "Description" ]
                , div [ class "col-sm-10" ]
                    [ input [ type_ "text", class "form-control", id "somethingDescription", onInput UpdateSkillDescription ] [] ]
                ]
            , button [ type_ "button", class "btn btn-primary", onClick AddSkillToList ] [ text "Add" ]
            ]
        ]
    ]

overvallProgress : List Skill -> Html msg
overvallProgress list =
  let
    time = List.foldr (+) 0 (List.map .time list)

    marker =
      if time > 3000 then 600000
      else if time > 1260 then 3000
      else 1260

    progress = (toFloat time) / marker * 100
  in
    div [ class "card" ]
      [ div [ class "card-body" ]
          [ h4 [ class "card-title" ] [ text "Overall Progress" ]
          , div [ class "progress" ]
              [ div [ class "progress-bar", style [ ("width", (toString progress) ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" (toString progress), attribute "aria-valuemin" "0", attribute "aria-valuemax" (toString marker) ] [] ]
          ]
      ]

skillList : List Skill -> Html Msg
skillList list =
  div [ class "row" ]
    [ div [ class "col" ] (List.map skillComponent list) ]

skillComponent : Skill -> Html Msg
skillComponent skill =
  let
    marker =
      if skill.time > 3000 then 600000
      else if skill.time > 1260 then 3000
      else 1260

    progress = (toFloat skill.time) / marker * 100
  in
    div [ class "card" ]
      [ div [ class "card-body" ]
          [ h4 [ class "card-title" ] [ text skill.title ]
          , p [ class "card-text" ] [ text skill.description ]
          , div [ class "progress" ]
              [ div [ class "progress-bar", style [ ("width", (toString progress) ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" (toString progress), attribute "aria-valuemin" "0", attribute "aria-valuemax" (toString marker) ] [] ]
          ]
      ]
