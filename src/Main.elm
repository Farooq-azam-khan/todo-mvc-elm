module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (Decoder, bool, field, int, map3, string)
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


todoDecoder : Decoder Todo
todoDecoder =
    map3 Todo (field "id" int) (field "title" string) (field "completed" bool)

getTodos : Cmd Msg 
getTodos = Http.get
        { url = "https://jsonplaceholder.typicode.com/todos"
        , expect = Http.expectJson GotTodos (D.list todoDecoder)
        }
init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key, url = url, todos = [Todo 1 "test" False] 
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
            ({model | new_todo=str}, Cmd.none)
        
        CreateNewTodo -> 
            let 
                theTodo = Todo ((List.length model.todos) + 1) model.new_todo False 
                newTodos = List.append model.todos [theTodo]
            in 
                ({model | todos = newTodos, new_todo = ""}, Cmd.none)

        ChangeFilterOption filter_op -> 
            ({model | filted_option = filter_op}, Cmd.none)
        CompleteTodo  todo bool -> 
            let 
                update_todo = Todo todo.id todo.title (not todo.completed)
                updated_todos = List.map (\aTodo -> if aTodo.id == todo.id then update_todo else aTodo) model.todos
            in
                ({model | todos = updated_todos}, Cmd.none)
        ClearCompleted -> 
            ({model | todos = List.filter (\todo -> not todo.completed) model.todos}, Cmd.none)
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
        [ text "The current URL is: "
        , b [] [ text (Url.toString model.url) ]
        , ul []
            [ viewLink "/home"
            , viewLink "/profile"
            , viewLink "/todos/"
            ]
        , case model.todos of
            Success ts ->
                todosView ts

            Failure ->
                text "failed to load todos"

            Loading ->
                text "loading todos"
        ]
    }


todosView : List Todo -> Html Msg
todosView todos =
    ul [] (List.map showTodo todos)


showTodo : Todo -> Html Msg
showTodo todo =
    li [] [ text todo.title ]


viewLink : String -> Html Msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]


subs : Model -> Sub msg
subs _ =
    Sub.none
