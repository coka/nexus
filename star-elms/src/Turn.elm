module Turn exposing (..)


type Turn
    = PlayerOne
    | PlayerTwo


next : Turn -> Turn
next turn =
    case turn of
        PlayerOne ->
            PlayerTwo

        PlayerTwo ->
            PlayerOne
