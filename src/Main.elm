module Main exposing (main)

-- import Http
-- import Json.Decode as D exposing (Decoder, bool, field, int, map3, string)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subs
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- todoDecoder : Decoder Todo
-- todoDecoder =
--     map3 Todo (field "id" int) (field "title" string) (field "completed" bool)
-- getTodos : Cmd Msg
-- getTodos =
--     Http.get
--         { url = "https://jsonplaceholder.typicode.com/todos"
--         , expect = Http.expectJson GotTodos (D.list todoDecoder)
--         }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , todos = [ Todo 1 "Testing Default" False ]
      , fetched_todos = NotFetching
      , new_todo = ""
      , filted_option = All
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        UpdateTodo str ->
            ( { model | new_todo = str }, Cmd.none )

        CreateNewTodo ->
            let
                theTodo =
                    Todo (List.length model.todos + 1) model.new_todo False

                newTodos =
                    List.append model.todos [ theTodo ]
            in
            ( { model | todos = newTodos, new_todo = "" }, Cmd.none )

        ChangeFilterOption filter_op ->
            ( { model | filted_option = filter_op }, Cmd.none )

        CompleteTodo todo _ ->
            let
                update_todo =
                    Todo todo.id todo.title (not todo.completed)

                updated_todos =
                    List.map
                        (\aTodo ->
                            if aTodo.id == todo.id then
                                update_todo

                            else
                                aTodo
                        )
                        model.todos
            in
            ( { model | todos = updated_todos }, Cmd.none )

        ClearCompleted ->
            ( { model | todos = List.filter (\todo -> not todo.completed) model.todos }, Cmd.none )

        GotTodos result ->
            case result of
                Ok d ->
                    ( { model | fetched_todos = Success d }, Cmd.none )

                Err _ ->
                    ( { model | fetched_todos = Failure }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Todo MVC"
    , body =
        [ div [ class "bg-gray-100 flex flex-col justify-center" ]
            [ h1 [ class "text-6xl opacity-50 text-red-300 text-center" ] [ text "todos" ]
            , Html.form
                [ onSubmit CreateNewTodo
                , class "flex items-center justify-center mt-10"
                ]
                [ input
                    [ placeholder "What needs to be done?"
                    , value model.new_todo
                    , onInput UpdateTodo
                    , class "px-10 py-2 shadow-xl"
                    ]
                    []
                ]
            , if not (List.length model.todos == 0) then
                div []
                    [ todosView model.todos model.filted_option
                    , div [ class "flex justify-between " ]
                        [ text (String.append (String.fromInt (displayCheckedItems model.todos)) " items left")
                        , div [ class "flex items-center space-x-6" ]
                            [ filterButton All "All"
                            , filterButton Active "Active"
                            , filterButton Completed "Completed"
                            ]
                        , button [ onClick ClearCompleted ] [ text "Clear Completed" ]
                        ]
                    ]

              else
                div [] []
            ]
        ]
    }


filterButton : FilterOption -> String -> Html Msg
filterButton filted_option filter_text =
    button
        [ onClick (ChangeFilterOption filted_option)
        , class ""
        ]
        [ text filter_text ]


getUnCompletedTodos : List Todo -> List Todo
getUnCompletedTodos =
    List.filter (\todo -> not todo.completed)


displayCheckedItems : List Todo -> Int
displayCheckedItems todos =
    List.length (getUnCompletedTodos todos)


todosView : List Todo -> FilterOption -> Html Msg
todosView todos filtered_options =
    case filtered_options of
        All ->
            ul [] (List.map showTodo todos)

        Active ->
            ul [] (List.map showTodo (List.filter (\todo -> not todo.completed) todos))

        Completed ->
            ul [] (List.map showTodo (List.filter (\todo -> todo.completed) todos))


showTodo : Todo -> Html Msg
showTodo todo =
    li []
        [ input [ type_ "checkbox", onCheck (CompleteTodo todo), checked todo.completed ] []
        , text todo.title
        ]



-- viewLink : String -> Html Msg
-- viewLink path =
--     li [] [ a [ href path ] [ text path ] ]


subs : Model -> Sub msg
subs _ =
    Sub.none
