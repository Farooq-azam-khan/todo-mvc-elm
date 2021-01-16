module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Http
import Url


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , todos : List Todo
    , filted_option : FilterOption
    }


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTodos (Result Http.Error (List Todo))


type FetchTodos
    = Failure
    | Loading
    | Success (List Todo)


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }

type FilterOption = All | Active | Completed