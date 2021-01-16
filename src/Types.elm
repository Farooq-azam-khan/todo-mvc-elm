module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Http
import Url


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , todos : List Todo
    , new_todo : String 
    , fetched_todos : FetchTodos
    , filted_option : FilterOption
    }


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTodos (Result Http.Error (List Todo))
    | UpdateTodo String 
    | CreateNewTodo
    | CompleteTodo Todo Bool 
    | ChangeFilterOption FilterOption
    | ClearCompleted

type FetchTodos
    = Failure
    | Loading
    | NotFetching
    | Success (List Todo)


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }

type FilterOption = All | Active | Completed