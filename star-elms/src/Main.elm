module Main exposing (main)

import Browser
import Game exposing (Game, Move)
import Html exposing (Html)


main : Program () Game Move
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Game, Cmd Move )
init _ =
    Game.init


update : Move -> Game -> ( Game, Cmd Move )
update move game =
    Game.update move game


subscriptions : Game -> Sub Move
subscriptions _ =
    Sub.none


view : Game -> Html Move
view game =
    Game.view game
