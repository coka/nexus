module Utilities exposing (..)

import Random


{-| Surround a string in brackets.

    Utilities.inBrackets "foo" == "(foo)"

-}
inBrackets : String -> String
inBrackets s =
    "(" ++ s ++ ")"


type alias Gen a =
    Random.Generator a


{-| Generate a pair of random values. This is a re-export of `Random.pair`.
-}
randomPair : Gen a -> Gen b -> Gen ( a, b )
randomPair genA genB =
    Random.pair genA genB


{-| Generate a 3-tuple of random values using the same implementation approach
as `Random.pair`. We need to generate 3 decks when the game starts.

    import Random
    import Random.List
    import Utilities

    randomDecks : Random.Generator ( Deck, Deck, Deck )
    randomDecks =
        Utilities.randomTriplet
            (Random.List.shuffle deckOne)
            (Random.List.shuffle deckTwo)
            (Random.List.shuffle deckThree)

-}
randomTriplet : Gen a -> Gen b -> Gen c -> Gen ( a, b, c )
randomTriplet genA genB genC =
    Random.map3 (\a b c -> ( a, b, c )) genA genB genC
