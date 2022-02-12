module Player exposing (..)

import Deck exposing (Deck, viewHand, viewHiddenHand)
import Decks
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Turn exposing (Turn(..))


type alias Player =
    { authority : Int
    , deck : Deck
    , discard : Deck
    , hand : Deck
    , turn : Turn
    }



-- CREATE


create : Turn -> Player
create turn =
    { authority = 50
    , deck = Decks.starter
    , discard = Deck.empty "Discard Pile"
    , hand = Deck.empty "Hand"
    , turn = turn
    }



-- TRANSFORM


damage : Int -> Player -> Player
damage amount player =
    { player | authority = player.authority - amount }


discardHand : Player -> Player
discardHand player =
    let
        ( updatedDiscard, updatedHand ) =
            Deck.moveInto player.discard player.hand
    in
    { player
        | discard = updatedDiscard
        , hand = updatedHand
    }


draw : Int -> Player -> Player
draw n player =
    let
        ( updatedDeck, updatedHand ) =
            Deck.move n player.deck player.hand
    in
    { player
        | deck = updatedDeck
        , hand = updatedHand
    }


{-| Determine the amount of trade present in a player's hand.
-}
tradeInHand : Player -> Int
tradeInHand player =
    Deck.trade player.hand



-- VIEW


view : Turn -> Player -> Html msg
view turn player =
    let
        hand =
            if turn == player.turn then
                [ viewHand (\_ -> Nothing) player.hand ]

            else
                [ viewHiddenHand player.hand ]
    in
    div
        [ class "row" ]
        [ Deck.viewExposed (\_ -> Nothing) player.discard
        , div [ class "row__main" ] hand
        , Deck.view player.deck
        ]
