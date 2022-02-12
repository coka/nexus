module Game exposing (Game, Move, init, update, view)

import Card exposing (Card)
import Cards
import Deck exposing (Deck, viewHand)
import Decks
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Player exposing (Player, discardHand, draw)
import Random
import Random.List exposing (shuffle)
import Tuple exposing (first, second)
import Turn exposing (Turn(..), next)
import Utilities exposing (randomPair, randomTriplet)



-- MODEL


type alias Game =
    { explorerDeck : Deck
    , players : ( Player, Player )
    , remainingCombat : Int
    , remainingTrade : Int
    , scrapHeap : Deck
    , tradeDeck : Deck
    , tradeRow : Deck
    , turn : Turn
    }


type Move
    = AcquireCard Card
    | DealDecks ( Deck, Deck, Deck )
    | DrawRemainingCards ( Deck, Int )
    | EndTurn


init : ( Game, Cmd Move )
init =
    let
        game =
            { explorerDeck = Decks.explorer
            , players = ( Player.create PlayerOne, Player.create PlayerTwo )
            , remainingCombat = 0
            , remainingTrade = 0
            , scrapHeap = Deck.empty "Scrap Heap"
            , tradeDeck = Decks.trade
            , tradeRow = Deck.empty "Trade Row"
            , turn = PlayerOne
            }
    in
    ( game
    , shuffleInitialDecks
        (game |> playerOne |> .deck)
        (game |> playerOne |> .deck)
        game.tradeDeck
    )



-- UPDATE


update : Move -> Game -> ( Game, Cmd Move )
update action game =
    case action of
        AcquireCard card ->
            game |> acquireCard card

        DealDecks decks ->
            game |> dealDecks decks

        DrawRemainingCards ( deck, n ) ->
            drawRemainingCards game deck n

        EndTurn ->
            endTurn game


acquireCard : Card -> Game -> ( Game, Cmd Move )
acquireCard card game =
    let
        player =
            activePlayer game

        updatedPlayer =
            { player | discard = Deck.add [ card ] player.discard }
    in
    if card == Cards.explorer then
        ( { game
            | explorerDeck = Deck.without card game.explorerDeck
            , remainingTrade = game.remainingTrade - card.cost
          }
            |> updateActivePlayer updatedPlayer
        , Cmd.none
        )

    else
        let
            { tradeRow, tradeDeck } =
                game

            ( updatedTradeDeck, updatedTradeRow ) =
                Deck.move 1 tradeDeck <|
                    Deck.without card tradeRow
        in
        ( { game | remainingTrade = game.remainingTrade - card.cost }
            |> updateActivePlayer updatedPlayer
            |> updateTradeRow updatedTradeRow
            |> updateTradeDeck updatedTradeDeck
        , Cmd.none
        )


dealDecks : ( Deck, Deck, Deck ) -> Game -> ( Game, Cmd Move )
dealDecks decks game =
    let
        setDeck =
            \deck player -> { player | deck = deck }

        ( playerOneDeck, playerTwoDeck, tradeDeck ) =
            decks

        updatedPlayerOne =
            game |> playerOne |> setDeck playerOneDeck |> draw 3

        updatedPlayerTwo =
            game |> playerTwo |> setDeck playerTwoDeck |> draw 5

        ( updatedTradeDeck, updatedTradeRow ) =
            Deck.move 5 tradeDeck game.tradeRow

        newGame =
            { game
                | players = ( updatedPlayerOne, updatedPlayerTwo )
                , tradeDeck = updatedTradeDeck
                , tradeRow = updatedTradeRow
            }
                |> refreshResources
    in
    ( newGame, Cmd.none )


drawRemainingCards : Game -> Deck -> Int -> ( Game, Cmd Move )
drawRemainingCards game shuffledDiscard n =
    let
        player =
            activePlayer game

        ( updatedDeck, updatedDiscard ) =
            Deck.moveInto player.deck shuffledDiscard

        newPlayer =
            { player
                | deck = updatedDeck
                , discard = updatedDiscard
            }
                |> draw n

        newGame =
            game
                |> updateActivePlayer newPlayer
                |> passTurn
    in
    ( newGame, Cmd.none )


endTurn : Game -> ( Game, Cmd Move )
endTurn game =
    let
        player =
            activePlayer game

        deckSize =
            Deck.size player.deck

        additionalCardsToDraw =
            if (deckSize - 5) < 0 then
                abs (deckSize - 5)

            else
                0

        newGame =
            game
                |> updateActivePlayer
                    (player
                        |> discardHand
                        |> draw 5
                    )
    in
    if additionalCardsToDraw > 0 then
        ( newGame
        , newGame |> shuffleDiscardIntoDeckAndDraw additionalCardsToDraw
        )

    else
        ( newGame |> passTurn
        , Cmd.none
        )


shuffleDiscardIntoDeckAndDraw : Int -> Game -> Cmd Move
shuffleDiscardIntoDeckAndDraw n game =
    let
        { discard } =
            activePlayer game
    in
    randomPair
        (Deck.shuffle discard)
        (Random.constant n)
        |> Random.generate DrawRemainingCards


shuffleInitialDecks : Deck -> Deck -> Deck -> Cmd Move
shuffleInitialDecks playerOneDeck playerTwoDeck tradeDeck =
    randomTriplet
        (Deck.shuffle playerOneDeck)
        (Deck.shuffle playerTwoDeck)
        (Deck.shuffle tradeDeck)
        |> Random.generate DealDecks



-- VIEW


view : Game -> Html Move
view game =
    div [ class "app" ]
        [ div [ class "banner" ] [ viewBanner game ]
        , div [ class "board" ] [ viewBoard game ]
        ]


viewBanner : Game -> Html Move
viewBanner game =
    let
        stats =
            \p ->
                case p.turn of
                    PlayerOne ->
                        playerName p ++ " " ++ String.fromInt p.authority

                    PlayerTwo ->
                        String.fromInt p.authority ++ " " ++ playerName p

        ( playerOneStats, playerTwoStats ) =
            Tuple.mapBoth stats stats game.players

        tradeStats =
            "Remaining trade: " ++ String.fromInt game.remainingTrade

        combatStats =
            "Combat: " ++ String.fromInt game.remainingCombat
    in
    div []
        [ p [] [ (activePlayer game |> playerName) ++ "'s turn" |> text ]
        , p [] [ tradeStats |> text ]
        , p [] [ combatStats |> text ]
        , p [] [ playerOneStats ++ " - " ++ playerTwoStats |> text ]
        ]


viewBoard : Game -> Html Move
viewBoard game =
    div []
        [ game |> playerOne |> Player.view game.turn
        , div
            [ class "row" ]
            [ Deck.viewExposed
                (maybeAcquireCard game.remainingTrade)
                game.explorerDeck
            , div
                [ class "row__main" ]
                [ viewTradeRow game ]
            , Deck.view game.tradeDeck
            , Deck.viewExposed (\_ -> Nothing) game.scrapHeap
            ]
        , game |> playerTwo |> Player.view game.turn
        , div
            [ class "end-turn" ]
            [ button
                [ onClick EndTurn ]
                [ text "End Turn" ]
            ]
        ]


viewTradeRow : Game -> Html Move
viewTradeRow game =
    viewHand (maybeAcquireCard game.remainingTrade) game.tradeRow



-- TRANSFORM


applyCombatDamage : Game -> Game
applyCombatDamage game =
    let
        updatedPlayer =
            game |> opposingPlayer |> Player.damage game.remainingCombat
    in
    game |> updateOpposingPlayer updatedPlayer


passTurn : Game -> Game
passTurn game =
    game
        |> applyCombatDamage
        |> updateTurn (next game.turn)
        |> refreshResources


refreshResources : Game -> Game
refreshResources game =
    { game
        | remainingCombat = game |> activePlayer |> .hand |> Deck.combat
        , remainingTrade = game |> activePlayer |> .hand |> Deck.trade
    }


updateActivePlayer : Player -> Game -> Game
updateActivePlayer player game =
    case game.turn of
        PlayerOne ->
            { game | players = ( player, second game.players ) }

        PlayerTwo ->
            { game | players = ( first game.players, player ) }


updateOpposingPlayer : Player -> Game -> Game
updateOpposingPlayer player game =
    case game.turn of
        PlayerOne ->
            { game | players = ( first game.players, player ) }

        PlayerTwo ->
            { game | players = ( player, second game.players ) }


updateTradeDeck : Deck -> Game -> Game
updateTradeDeck deck game =
    { game | tradeDeck = deck }


updateTradeRow : Deck -> Game -> Game
updateTradeRow deck game =
    { game | tradeRow = deck }


updateTurn : Turn -> Game -> Game
updateTurn turn game =
    { game | turn = turn }



-- UTILITIES


activePlayer : Game -> Player
activePlayer game =
    case game.turn of
        PlayerOne ->
            playerOne game

        PlayerTwo ->
            playerTwo game


maybeAcquireCard : Int -> (Card -> Maybe Move)
maybeAcquireCard availableTrade =
    \card ->
        if availableTrade >= card.cost then
            Just (AcquireCard card)

        else
            Nothing


opposingPlayer : Game -> Player
opposingPlayer game =
    case game.turn of
        PlayerOne ->
            playerTwo game

        PlayerTwo ->
            playerOne game


playerOne : Game -> Player
playerOne game =
    first game.players


playerName : Player -> String
playerName player =
    case player.turn of
        PlayerOne ->
            "Player 1"

        PlayerTwo ->
            "Player 2"


playerTwo : Game -> Player
playerTwo game =
    second game.players
