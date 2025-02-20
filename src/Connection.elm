module Connection exposing (..)

import Array exposing (Array, fromList)
import Json.Decode as Decode exposing (Decoder, decodeString, int)
import Json.Decode.Pipeline
import List.Extra exposing (updateIf)


-- MODEL


type alias Model =
    { name : String
    , destinationIp : String
    , destinationPort : Int
    }


init : Model
init =
    Model "Default" "127.0.0.1" 1337



-- UPDATE


updateSavedConnections : Array Model -> Model -> Array Model
updateSavedConnections connections updatedConnection =
    connections
        |> Array.toList
        |> updateIf (\c -> c.name == updatedConnection.name) (\c -> updatedConnection)
        |> Array.fromList


getInitialConnectionName : Array Model -> String
getInitialConnectionName connections =
    case Array.get 0 connections of
        Just connection ->
            connection.name

        Nothing ->
            ""


findConnectionByName : Array Model -> String -> Maybe Model
findConnectionByName savedConnections connectionName =
    savedConnections
        |> Array.toList
        |> List.Extra.find (\c -> c.name == connectionName)



-- SERIALIZATION


toSavedConnectionsModels : String -> Result String (Array Model)
toSavedConnectionsModels json =
    Decode.decodeString (Decode.array decodeConnection) json


decodeConnection : Decoder Model
decodeConnection =
    Decode.succeed Model
        |> Json.Decode.Pipeline.required "name" Decode.string
        |> Json.Decode.Pipeline.required "destinationIp" Decode.string
        |> Json.Decode.Pipeline.required "destinationPort" Decode.int
