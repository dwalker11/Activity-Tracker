import Html exposing (..)
import Html.Attributes exposing (id, class, style, attribute, disabled, type_, for, value)
import Html.Events exposing (on, onInput, onClick, targetValue)
import Http exposing (post)
import Json.Encode
import Json.Decode
import Result
import Array exposing (Array, fromList, toList, indexedMap)



main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Skill =
  { id : String
  , name: String
  , description: String
  , minutes: Int
  , locked: Bool
  }

type alias Generator =
  { name: String
  , description: String
  }

type alias Updater =
  { index: Int
  , minutes: Int
  }

type alias Model =
  { userSkills: Array Skill
  , skillGenerator: Generator
  , skillUpdater: Updater
  }

type alias Flags =
  { skills : List Skill }

init : Flags -> (Model, Cmd Msg)
init flag =
  ( Model (fromList flag.skills) (Generator "" "") (Updater 0 0)
  , Cmd.none
  )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- UPDATE


type Msg
  = UpdateNewSkillName String
  | UpdateNewSkillDescription String
  | CreateNewSkill
  | StoreNewSkill (Result Http.Error String)
  | UpdateSelection String
  | UpdateMinutesToAdd String
  | AddMinutesToSelectedSkill
  | StoreUpdatedSkill (Result Http.Error (List String))
  | UnlockSkill Int
  | UnlockStoredSkill (Result Http.Error (List String))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateNewSkillName updatedName ->
      let
        generator =
          model.skillGenerator

        updatedSkill =
          { generator | name = updatedName }
      in
        ({ model | skillGenerator = updatedSkill }, Cmd.none)

    UpdateNewSkillDescription updatedDescription ->
      let
        generator =
          model.skillGenerator

        updatedSkill =
          { generator | description = updatedDescription }
      in
        ({ model | skillGenerator = updatedSkill }, Cmd.none)

    CreateNewSkill ->
      let
        newSkill =
          Skill "" (model.skillGenerator.name) (model.skillGenerator.description) 0 True

        updatedSkillList =
          Array.push newSkill model.userSkills
      in
        ({ model | userSkills = updatedSkillList }, Http.send StoreNewSkill (postSkill newSkill))

    StoreNewSkill (Ok val) ->
      let
        index =
          (-) (Array.length model.userSkills) 1

        maybeSkill =
          Array.get index model.userSkills
      in
        case maybeSkill of
          Just currentSkill ->
            let
              updatedSkill =
                { currentSkill | id = val }

              updatedSkillList =
                Array.set index updatedSkill model.userSkills
            in
              ({ model | userSkills = updatedSkillList }, Cmd.none)
          Nothing ->
            (model, Cmd.none)

    StoreNewSkill (Err _) ->
      (model, Cmd.none)

    UpdateSelection val ->
      let
        oldUpdater =
          model.skillUpdater

        newUpdater =
          { oldUpdater | index = (Result.withDefault 0 (String.toInt val)) }
      in
        ({ model | skillUpdater = newUpdater }, Cmd.none)

    UpdateMinutesToAdd val ->
      let
        oldUpdater =
          model.skillUpdater

        newUpdater =
          { oldUpdater | minutes = (Result.withDefault 0 (String.toInt val)) }
      in
        ({ model | skillUpdater = newUpdater }, Cmd.none)

    AddMinutesToSelectedSkill ->
      let
        index =
          model.skillUpdater.index

        maybeSkill =
          Array.get index model.userSkills
      in
        case maybeSkill of
          Just currentSkill ->
            let
              time =
                currentSkill.minutes + model.skillUpdater.minutes

              updatedSkill =
                { currentSkill | minutes = time }

              updatedSkillList =
                Array.set index updatedSkill model.userSkills
            in
              ({ model | userSkills = updatedSkillList }, Http.send StoreUpdatedSkill (patchSkill currentSkill (Json.Encode.string "minutes") (Json.Encode.int time)))

          Nothing ->
            (model, Cmd.none)

    StoreUpdatedSkill (Ok val) ->
      (model, Cmd.none)

    StoreUpdatedSkill (Err _) ->
      (model, Cmd.none)

    UnlockSkill index ->
      let
        maybeSkill =
          Array.get index model.userSkills
      in
        case maybeSkill of
          Just currentSkill ->
            let
              updatedSkill =
                { currentSkill | locked = False }

              updatedSkillList =
                Array.set index updatedSkill model.userSkills
            in
              ({ model | userSkills = updatedSkillList }, Http.send UnlockStoredSkill (patchSkill currentSkill (Json.Encode.string "locked") (Json.Encode.bool False)))

          Nothing ->
            (model, Cmd.none)

    UnlockStoredSkill (Ok val) ->
      (model, Cmd.none)

    UnlockStoredSkill (Err _) ->
      (model, Cmd.none)

postSkill : Skill -> Http.Request String
postSkill skill =
  let
    url =
      "/skills/skills"

    payload =
      Json.Encode.object
        [ ("name", Json.Encode.string skill.name)
        , ("description", Json.Encode.string skill.description)
        ]
  in
    post url (Http.jsonBody payload) (Json.Decode.field "id" Json.Decode.string)

patchSkill : Skill -> Json.Encode.Value -> Json.Encode.Value -> Http.Request (List String)
patchSkill skill field value =
  let
    url =
      "/skills/skills/" ++ skill.id

    payload =
      Json.Encode.object
        [ ("field", field)
        , ("value", value)
        ]
  in
    patch url (Http.jsonBody payload) (Json.Decode.list Json.Decode.string)

patch : String -> Http.Body -> Json.Decode.Decoder (List String) -> Http.Request (List String)
patch url body decoder =
  Http.request
    { method = "PATCH"
    , headers = []
    , url = url
    , body = body
    , expect = Http.expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ addTimeModal model.userSkills
    , addSkillModal model.skillGenerator
    , overvallProgress model.userSkills
    , hr [] []
    , skillList model.userSkills
    ]

addTimeModal : Array Skill -> Html Msg
addTimeModal list =
  let
    minutes =
      List.range 1 12
        |> List.map (\n -> n * 5)
        |> (::) 1
        |> List.map (\n -> option [ value (toString n) ] [ text (toString n) ])

    skills =
      list
        |> Array.filter (\{locked} -> not locked)
        |> Array.map .name
        |> indexedMap (,)
        |> toList
        |> List.map (\(index, name) -> option [ value (toString index) ] [ text name ])
  in
    div [ class "modal fade", id "addTimeModal" ]
      [ div [ class "modal-dialog modal-lg", attribute "role" "document" ]
          [ div [ class "modal-content" ]
              [ div [ class "modal-header" ]
                  [ h5 [ class "modal-title" ] [ text "Add Time" ]
                  , button [ type_ "button", class "close", attribute "data-dismiss" "modal", attribute "aria-label" "Close" ] [ span [ attribute "aria-hidden" "true" ] [text "×" ] ]
                  ]
              , div [ class "modal-body" ]
                  [ form [ class "form" ]
                      [ div [ class "form-row" ]
                          [ div [ class "col" ]
                              [ select [ class "form-control", on "change" (Json.Decode.map UpdateSelection targetValue) ]
                                  (List.append [ option [] [ text "Select a Skill" ] ] skills)
                              ]
                          , div [ class "col" ]
                              [ select [ class "form-control", on "change" (Json.Decode.map UpdateMinutesToAdd targetValue) ]
                                  (List.append [ option [] [ text "Default time" ] ] minutes)
                              ]
                          , div [ class "col" ]
                              [ button [ type_ "button", class "btn btn-primary", onClick AddMinutesToSelectedSkill ] [ text "Add" ] ]
                          ]
                      ]
                  ]
              ]
          ]
      ]

addSkillModal : Generator -> Html Msg
addSkillModal newSkill =
  div [ class "modal fade", id "addSkillModal" ]
    [ div [ class "modal-dialog modal-lg", attribute "role" "document" ]
        [ div [ class "modal-content" ]
            [ div [ class "modal-header" ]
                [ h5 [ class "modal-title" ] [ text "Add a new Skill" ]
                , button [ type_ "button", class "close", attribute "data-dismiss" "modal", attribute "aria-label" "Close" ] [ span [ attribute "aria-hidden" "true" ] [text "×" ] ]
                ]
            , div [ class "modal-body" ]
                [ form []
                    [ div [ class "form-group row" ]
                        [ label [ for "somethingName", class "col-sm-2 col-form-label" ] [ text "Name" ]
                        , div [ class "col-sm-10" ]
                            [ input [ type_ "text", class "form-control", id "somethingName", onInput UpdateNewSkillName ] [] ]
                        ]
                    , div [ class "form-group row" ]
                        [ label [ for "somethingDescription", class "col-sm-2 col-form-label" ] [ text "Description" ]
                        , div [ class "col-sm-10" ]
                            [ input [ type_ "text", class "form-control", id "somethingDescription", onInput UpdateNewSkillDescription ] [] ]
                        ]
                    , button [ type_ "button", class "btn btn-primary float-right", onClick CreateNewSkill ] [ text "Add" ]
                    ]
                ]
            ]
        ]
    ]

overvallProgress : Array Skill -> Html Msg
overvallProgress list =
  let
    totalMinutes =
      Array.foldr (+) 0 (Array.map .minutes list)

    marker =
      if totalMinutes > 3000 then 600000
      else if totalMinutes > 1260 then 3000
      else 1260

    progress =
      (toFloat totalMinutes) / marker * 100
  in
    div [ class "row p-4" ]
      [ div [ class "col" ]
        [ div [ class "card" ]
          [ div [ class "card-body" ]
              [ h4 [ class "card-title" ] [ text "Overall Progress" ]
              , div [ class "progress" ]
                  [ div [ class "progress-bar", style [ ("width", (toString progress) ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" (toString progress), attribute "aria-valuemin" "0", attribute "aria-valuemax" (toString marker) ] [] ]
              ]
          ]
        ]
      ]

skillList : Array Skill -> Html Msg
skillList list =
  let
    totalMinutes =
      Array.foldr (+) 0 (Array.map .minutes list)

    totalSlots =
      if totalMinutes > 3000 then 24
      else if totalMinutes > 1260 then 9
      else 3

    usedSlots =
      Array.length (Array.filter (\{locked} -> not locked) list)

    availableSlots =
      totalSlots - usedSlots

    componentList =
      list
        |> Array.map (\n -> (,) n (availableSlots > 0))
        |> indexedMap skillComponent
        |> toList
  in
    div [ class "row p-4" ]
      [ div [ class "col" ] componentList ]

skillComponent : Int -> (Skill, Bool) -> Html Msg
skillComponent index (skill, availableToUnlock) =
  let
    marker =
      if skill.minutes > 3000 then 600000
      else if skill.minutes > 1260 then 3000
      else 1260

    progress =
      (toFloat skill.minutes) / marker * 100

    textClass =
      if skill.locked then "card-body text-secondary" else "card-body"

    btnStyle =
      if skill.locked then [ ("display", "block") ] else [ ("display", "none") ]
  in
    div [ class "card" ]
      [ div [ class textClass ]
          [ button [ type_ "button", class "btn btn-lg btn-primary float-right", style btnStyle, onClick (UnlockSkill index), disabled (not availableToUnlock) ] [ text "Unlock" ]
          , h4 [ class "card-title" ] [ text skill.name ]
          , p [ class "card-text" ] [ text skill.description ]
          , div [ class "progress" ]
              [ div [ class "progress-bar", style [ ("width", (toString progress) ++ "%") ], attribute "role" "progressbar", attribute "aria-valuenow" (toString progress), attribute "aria-valuemin" "0", attribute "aria-valuemax" (toString marker) ] [] ]
          ]
      ]
