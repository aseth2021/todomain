module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDPipeline exposing (..)
import Json.Encode as E exposing (..)



--- MAIN ---


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }



---- MODEL ----


type Selection
    = All
    | Progress
    | Completed


type TaskStatus
    = NewTask
    | InProgressTask
    | CompletedTask


type alias Task =
    { id : Int
    , name : String
    , status : Int
    }


initialTask =
    { id = 0
    , name = ""
    , status = 0
    }


type alias Model =
    { tasks : List Task, task : Task, content : String, status : Int, selection : Selection }


init : ( Model, Cmd Msg )
init =
    ( { tasks = [], task = initialTask, content = "", status = 0, selection = All }, getTasks )



-- HTTP


getTasks : Cmd Msg
getTasks =
    Http.get
        { url = "http://localhost:4000/api/tasks"
        , expect = Http.expectJson CreateTable (JD.list taskDecoder)
        }


taskDecoder : JD.Decoder Task
taskDecoder =
    JD.succeed Task
        |> JDPipeline.required "id" JD.int
        |> JDPipeline.required "name" JD.string
        |> JDPipeline.required "status" JD.int


type Msg
    = AddTask
    | Change String
    | CreateTable (Result Http.Error (List Task))
    | TaskCreated (Result Http.Error Task)
    | NoOperation
    | DeleteTask Int
    | TaskDeleted (Result Http.Error ())
    | SelectSelection Selection
    | TaskUpdated (Result Http.Error Task)
    | UpdateTaskStatus Int String



--- UPDATE ---


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TaskUpdated result ->
            case result of
                Ok tasks ->
                    ( model, getTasks )

                Err err ->
                    -- ( { model | content = Debug.toString err }, getTasks )
                    ( model, getTasks )

        UpdateTaskStatus taskId updatedTaskStatus ->
            ( model
            , if updatedTaskStatus == "InProgressTask" then
                updateTask 1 taskId

              else if updatedTaskStatus == "CompletedTask" then
                updateTask 2 taskId

              else if updatedTaskStatus == "NewTask" then
                updateTask 0 taskId

              else
                Cmd.none
            )

        AddTask ->
            ( model, createTask model )

        Change newContent ->
            ( { model | content = newContent }, Cmd.none )

        NoOperation ->
            ( model, Cmd.none )

        SelectSelection selection ->
            ( { model | selection = selection }, Cmd.none )

        CreateTable (Ok newtasks) ->
            ( { model | tasks = newtasks }, Cmd.none )

        CreateTable (Err _) ->
            ( model, Cmd.none )

        TaskCreated result ->
            case result of
                Ok task ->
                    ( { model | content = "" }, getTasks )

                Err err ->
                    ( { model | content = "" }, getTasks )

        DeleteTask item ->
            ( model, removeTask item )

        TaskDeleted result ->
            case result of
                Ok task ->
                    ( model, getTasks )

                Err _ ->
                    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ style "width" "100%" ]
        [ div []
            [ table
                []
                [ caption [] [ h1 [] [ text "" ] ]
                , thead []
                    [ tr []
                        [ div []
                            [ div
                                [ style "display" "flex"
                                ]
                                [ input [ placeholder "Enter Task", value model.content, onInput Change ] []
                                , button
                                    [ onClick AddTask ]
                                    [ text "Add" ]
                                , if List.length [ model.tasks ] > 0 then
                                    div
                                        []
                                        [ select
                                            [ on "change" (JD.map SelectSelection targetValueDecoder) ]
                                            [ viewOption All
                                            , viewOption Progress
                                            , viewOption Completed
                                            ]
                                        ]

                                  else
                                    div [] []
                                ]
                            ]
                        ]
                    ]
                , if List.length [ model.tasks ] == 0 then
                    tbody [] [ h3 [] [ text "No Task Added Yet" ] ]

                  else
                    tbody [] (isTasksView model.tasks model.selection)
                ]
            ]
        ]


isTasksView tasks selection =
    [ div [ style "marginTop" "20px" ]
        [ td [ align "left" ] [ text "Task Name" ]
        , td [ align "left" ] [ text "Status" ]
        , if selection == Completed then
            td [] []

          else
            td [ align "left" ] [ text "Update" ]
        , td [ align "left" ] [ text "Delete" ]
        ]
    , if selection == All then
        div [] (displayAllTaskInfo tasks)

      else if selection == Progress then
        div [] (displayInProgressTaskInfo tasks)

      else
        div [] (displayCompletedTaskInfo tasks)
    ]


displayAllTaskInfo : List Task -> List (Html Msg)
displayAllTaskInfo tasks =
    tasks
        |> List.map
            (\task ->
                tr
                    [ if task.status == 2 then
                        style "color" "black"

                      else if task.status == 1 then
                        style "color" "green"

                      else
                        style "color" "blue"
                    ]
                    [ td
                        []
                        [ td [] [ text task.name ]
                        , td []
                            [ case task.status of
                                0 ->
                                    text "New"

                                1 ->
                                    text "In Progress"

                                2 ->
                                    text "Completed"

                                _ ->
                                    text "Err!!! "
                            ]
                        , td [ align "left", width 100 ]
                            [ select
                                [ onInput (UpdateTaskStatus task.id) ]
                                [ option [ value "NewTask" ] [ text "New" ]
                                , option [ value "InProgressTask" ] [ text "In Progress" ]
                                , option [ value "CompletedTask" ] [ text "Completed" ]
                                ]
                            ]
                        , td [ align "left", width 100 ]
                            [ button
                                [ onClick (DeleteTask task.id) ]
                                [ text "Delete" ]
                            ]
                        ]
                    ]
            )


displayInProgressTaskInfo : List Task -> List (Html Msg)
displayInProgressTaskInfo tasks =
    tasks
        |> List.filter (\task -> task.status == 1)
        |> List.map
            (\task ->
                div []
                    [ tr [ style "color" "green" ]
                        [ td [] [ text task.name ]
                        , td [] [ text "In Progress" ]
                        , td []
                            [ select
                                [ onInput (UpdateTaskStatus task.id) ]
                                [ option [ value "NewTask" ] [ text "New" ]
                                , option [ value "InProgressTask" ] [ text "In Progress" ]
                                , option [ value "CompletedTask" ] [ text "Completed" ]
                                ]
                            ]
                        , td []
                            [ button
                                [ onClick (DeleteTask task.id) ]
                                [ text "Delete" ]
                            ]
                        ]
                    ]
            )


displayCompletedTaskInfo : List Task -> List (Html Msg)
displayCompletedTaskInfo tasks =
    tasks
        |> List.filter (\task -> task.status == 2)
        |> List.map
            (\task ->
                div []
                    [ td []
                        [ td [] [ text task.name ]
                        , td [] [ text "Completed" ]
                        , td []
                            [ button
                                [ onClick (DeleteTask task.id) ]
                                [ text "Delete" ]
                            ]
                        ]
                    ]
            )



--- Functions ---


viewOption : Selection -> Html Msg
viewOption selection =
    option
        [ value <| Debug.toString selection ]
        [ text <| Debug.toString selection ]


targetValueDecoder : JD.Decoder Selection
targetValueDecoder =
    targetValue
        |> JD.andThen
            (\val ->
                case val of
                    "All" ->
                        JD.succeed All

                    "Progress" ->
                        JD.succeed Progress

                    "Completed" ->
                        JD.succeed Completed

                    _ ->
                        JD.fail ("Invalid Role: " ++ val)
            )


saveUrl : String
saveUrl =
    "http://localhost:4000/api/tasks/"


encodeTaskObject : Model -> E.Value
encodeTaskObject model =
    E.object
        [ ( "task", encodeTask model ) ]


encodeTask : Model -> E.Value
encodeTask model =
    E.object
        [ ( "name", E.string model.content )
        , ( "status", E.int model.status )
        ]


createTask : Model -> Cmd Msg
createTask data =
    Http.post
        { url = saveUrl
        , body = encodeTaskObject data |> Http.jsonBody
        , expect = Http.expectJson TaskCreated taskDecoder
        }


removeTask : Int -> Cmd Msg
removeTask task_id =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectWhatever TaskDeleted
        , headers = []
        , method = "DELETE"
        , timeout = Nothing
        , tracker = Nothing
        , url = saveUrl ++ String.fromInt task_id
        }


updateTask : Int -> Int -> Cmd Msg
updateTask status id =
    Http.request
        { body = encodeUpdateTaskObject status |> Http.jsonBody
        , expect = Http.expectJson TaskUpdated taskDecoder
        , headers = []
        , method = "PUT"
        , timeout = Nothing
        , tracker = Nothing
        , url = saveUrl ++ String.fromInt id
        }


encodeUpdateTaskObject : Int -> E.Value
encodeUpdateTaskObject status =
    E.object
        [ ( "task"
          , E.object
                [ ( "status", E.int status )
                ]
          )
        ]


taskFromString : String -> TaskStatus
taskFromString status =
    case status of
        "InProgressTask" ->
            InProgressTask

        "CompletedTask" ->
            CompletedTask

        _ ->
            NewTask
