module Utilities exposing (..)
import Debug


getPortDisplay : Int -> String
getPortDisplay destinationPort =
    if destinationPort == 0 then
        ""
    else
        Debug.toString destinationPort
