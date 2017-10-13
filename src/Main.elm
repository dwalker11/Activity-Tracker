import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onInput, onClick, targetValue)
import Array exposing (Array, fromList, toList)
import Json.Decode as Json
import Result



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

type alias Updater =
  { index: Int
  , mintues: Int
  }

type alias Model =
  { list: Array Skill
  , skill: NewSkill
  , updater: Updater
  }

model : Model
model =
  { list = fromList []
  , skill = NewSkill "" ""
  , updater = Updater 0 0
  }


-- UPDATE


type Msg
  = UpdateSkillName String
  | UpdateSkillDescription String
  | AddSkillToList
  | UpdateSelectedSkill String
  | UpdateMinutesToAdd String
  | AddMinutesToSelectedSkill

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

        updatedSkillList = Array.push newSkill model.list
      in
        { model | list = updatedSkillList }

    UpdateSelectedSkill val ->
      let
        oldUpdater = model.updater

        updatedUpdater = { oldUpdater | index = (Result.withDefault 0 (String.toInt val)) }
      in
        { model | updater = updatedUpdater }

    UpdateMinutesToAdd val ->
      let
        oldUpdater = model.updater

        updatedUpdater = { oldUpdater | mintues = (Result.withDefault 0 (String.toInt val)) }
      in
        { model | updater = updatedUpdater }

    AddMinutesToSelectedSkill ->
      let
        index = model.updater.index

        maybeSkill = Array.get index model.list
      in
        case maybeSkill of
          Just currentSkill ->
            let
              addTime = (+) model.updater.mintues

              updatedSkill = { currentSkill | time = addTime currentSkill.time }

              updatedSkillList = Array.set index updatedSkill model.list
            in
              { model | list = updatedSkillList }

          Nothing ->
            model


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ addTimeModal model.list
    , addSkillForm model.skill
    , hr [] []
    , overvallProgress model.list
    , hr [] []
    , skillList model.list
    ]

addTimeModal : Array Skill -> Html Msg
addTimeModal list =
  let
    x = List.map (\n -> n * 5) (List.range 1 12)

    y = List.map (\n -> option [ value (toString n) ] [ text (toString n) ]) (1 :: x)

    indexedSkillList = toList (Array.indexedMap (,) (Array.map .title list))

    skills = List.map (\(index, name) -> option [ value (toString index) ] [ text name ]) indexedSkillList
  in
    div [ class "modal fade", id "somethingModal" ]
      [ div [ class "modal-dialog modal-lg", attribute "role" "document" ]
          [ div [ class "modal-content" ]
              [ div [ class "modal-header" ]
                  [ h5 [ class "modal-title" ] [ text "Add Time" ]
                  , button [ type_ "button", class "close", attribute "data-dismiss" "modal", attribute "aria-label" "Close" ] [ span [ attribute "aria-hidden" "true" ] [text "×" ] ]
                  ]
              , div [ class "modal-body" ]
                  [ Html.form [ class "form" ]
                      [ div [ class "form-row" ]
                          [ div [ class "col" ]
                              [ select [ class "form-control", on "change" (Json.map UpdateSelectedSkill targetValue) ]
                                  (List.append [ option [] [ text "Select a Skill" ] ] skills)
                              ]
                          , div [ class "col" ]
                              [ select [ class "form-control", on "change" (Json.map UpdateMinutesToAdd targetValue) ]
                                  (List.append [ option [] [ text "Default time" ] ] y)
                              ]
                          , div [ class "col" ]
                              [ button [ type_ "button", class "btn btn-primary", onClick AddMinutesToSelectedSkill ] [ text "Add" ] ]
                          ]
                      ]
                  ]
              ]
          ]
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

overvallProgress : Array Skill -> Html msg
overvallProgress list =
  let
    time = Array.foldr (+) 0 (Array.map .time list)

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

skillList : Array Skill -> Html Msg
skillList list =
  let
    componentList = (toList (Array.map skillComponent list))
  in
    div [ class "row" ]
      [ div [ class "col" ] componentList ]

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
