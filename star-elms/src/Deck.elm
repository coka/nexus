module Deck exposing
    ( Deck
    , add
    , combat
    , create
    , empty
    , move
    , moveInto
    , shuffle
    , size
    , trade
    , view
    , viewExposed
    , viewHand
    , viewHiddenHand
    , without
    )

import Card exposing (Card)
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import List as L
import List.Extra as L
import Random exposing (Generator, constant)
import Random.List
import Utilities exposing (inBrackets)


type alias Deck =
    { name : String
    , cards : List Card
    }



-- CREATE


create : String -> List Card -> Deck
create name cards =
    { name = name
    , cards = cards
    }


empty : String -> Deck
empty name =
    create name []



-- TRANSFORM


{-| Add cards to the top of a deck.
-}
add : List Card -> Deck -> Deck
add cards deck =
    { deck | cards = L.foldl (::) deck.cards cards }


{-| Move a number of cards from one deck to another. The cards are "scooped" in
such a way that the rightmost card ends up on top.
-}
move : Int -> Deck -> Deck -> ( Deck, Deck )
move n from to =
    ( { from | cards = List.drop n from.cards }
    , add (List.take n from.cards) to
    )


{-| Move an entire deck to another.
-}
moveInto : Deck -> Deck -> ( Deck, Deck )
moveInto deckA deckB =
    let
        ( newDeckB, newDeckA ) =
            move (size deckB) deckB deckA
    in
    ( newDeckA, newDeckB )


{-| Remove a card from a deck in a position-unaware way.
-}
without : Card -> Deck -> Deck
without card deck =
    { deck | cards = L.remove card deck.cards }



-- UTILITIES


{-| Determine the amount of combat present in a deck.
-}
combat : Deck -> Int
combat deck =
    deck.cards
        |> L.map (\c -> c.combat)
        |> L.sum


shuffle : Deck -> Generator Deck
shuffle deck =
    Random.map2 Deck
        (Random.constant deck.name)
        (Random.List.shuffle deck.cards)


{-| Get the number of cards in a deck.
-}
size : Deck -> Int
size deck =
    List.length deck.cards


{-| Determine the amount of trade present in a deck.
-}
trade : Deck -> Int
trade deck =
    deck.cards
        |> List.map (\c -> c.trade)
        |> List.sum



-- VIEW


view : Deck -> Html msg
view deck =
    if deck.cards == [] then
        viewEmpty deck

    else
        Card.viewFaceDown
            |> frame (label deck)


viewExposed : (Card -> Maybe msg) -> Deck -> Html msg
viewExposed maybeWhenCardClicked deck =
    case L.head deck.cards of
        Nothing ->
            viewEmpty deck

        Just card ->
            Card.view (maybeWhenCardClicked card) card
                |> frame (label deck)


viewHand : (Card -> Maybe msg) -> Deck -> Html msg
viewHand maybeWhenCardClicked hand =
    hand.cards
        |> L.map (\c -> Card.view (maybeWhenCardClicked c) c)
        |> div [ class "deck--hand" ]
        |> frame (label hand)


viewHiddenHand : Deck -> Html msg
viewHiddenHand hand =
    L.repeat (size hand) Card.viewFaceDown
        |> div [ class "deck--hand" ]
        |> frame (label hand)



-- PRIVATE


frame : String -> Html msg -> Html msg
frame bottomLabel content =
    div
        [ class "deck__frame" ]
        [ div [] [ content ], p [] [ text bottomLabel ] ]


label : Deck -> String
label deck =
    if deck.cards == [] then
        deck.name

    else
        deck.name ++ " " ++ (deck |> size |> String.fromInt |> inBrackets)


viewEmpty : Deck -> Html msg
viewEmpty deck =
    div [ class "deck--empty" ] [] |> frame deck.name
