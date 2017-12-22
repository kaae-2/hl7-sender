port module Connection.Subs exposing (..)


port connected : (() -> msg) -> Sub msg


port disconnected : (() -> msg) -> Sub msg


port connectionError : (String -> msg) -> Sub msg


port sent : (() -> msg) -> Sub msg
