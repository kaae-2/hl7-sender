port module Connection.Update exposing (..)

import Char
import Msg as Main exposing (..)
import Model as Main exposing (..)
import Connection.Model as Connection exposing (Model)
import Connection.Msg as Connection exposing (..)
import Connection.Validations exposing (..)


update : Connection.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
update msg model =
    case msg of
        ChangeDestinationIp newIp ->
            ( { model
                | connection = updateIpAddress model.connection newIp
              }
            , Cmd.none
            )

        ChangeDestinationPort newPort ->
            case validatePort newPort of
                ValidPort validatedPort ->
                    ( { model
                        | connection = updatePort model.connection validatedPort
                      }
                    , Cmd.none
                    )

                EmptyPort ->
                    ( { model
                        | connection = updatePort model.connection 0
                      }
                    , Cmd.none
                    )

                InvalidPort ->
                    ( model, Cmd.none )

        Connected ->
            connected model
                |> log "info" "Connected"

        Disconnected ->
            disconnected model
                |> log "info" "Disconnected"

        ConnectionError errorMsg ->
            disconnected model
                |> log "error" errorMsg

        Sent ->
            updateSentCount model
                |> log "info" "Sent a message"

        ClearLog ->
            ( { model | logs = [] }, Cmd.none )

        Send ->
            ( model, send (getWrappedHl7 model) )

        ToggleConnection ->
            case model.connection.isConnected of
                False ->
                    ( model
                    , connect
                        ( model.connection.destinationIp
                        , model.connection.destinationPort
                        )
                    )

                True ->
                    ( model
                    , disconnect ()
                    )


updateIpAddress connection newIp =
    { connection | destinationIp = newIp }


updatePort connection newPort =
    { connection | destinationPort = clamp 1 65535 newPort }


connected model =
    { model
        | connection = updateConnectionStatus model.connection True "Connected"
    }


disconnected model =
    { model
        | connection = updateConnectionStatus model.connection False "Disconnected"
    }


updateConnectionStatus connection isConnected message =
    { connection
        | isConnected = isConnected
        , connectionMessage = message
    }


updateSentCount model =
    { model
        | connection = Connection.updateSentCount model.connection
    }


port connect : ( String, Int ) -> Cmd msg


port disconnect : () -> Cmd msg


port send : String -> Cmd msg


getWrappedHl7 : Main.Model -> String
getWrappedHl7 model =
    getCharStr model.settings.controlCharacters.startOfText
        ++ getStrWithCarriageReturns (model.home.hl7)
        ++ getCharStr model.settings.controlCharacters.endOfLine
        ++ getCharStr model.settings.controlCharacters.endOfText


getStrWithCarriageReturns : String -> String
getStrWithCarriageReturns str =
    String.split "\n" str
        |> String.join "\x0D"


getCharStr : Int -> String
getCharStr i =
    String.fromChar (Char.fromCode i)
