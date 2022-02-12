module Decks exposing (..)

{-| Deck definitions.
-}

import Cards
import Deck exposing (Deck, create)
import List exposing (repeat)


explorer : Deck
explorer =
    Deck.create
        "Explorers"
        (repeat 10 Cards.explorer)


starter : Deck
starter =
    Deck.create
        "Deck"
        (repeat 8 Cards.scout ++ repeat 2 Cards.viper)


trade : Deck
trade =
    Deck.create
        "Trade Deck"
        (repeat 40 Cards.fighter ++ repeat 40 Cards.interceptor)
