module Cards exposing (..)

{-| Card definitions.
-}

import Card exposing (Card)


explorer : Card
explorer =
    { name = "Explorer"
    , cost = 2
    , trade = 2
    , combat = 0
    }


scout : Card
scout =
    { name = "Scout"
    , cost = 0
    , trade = 1
    , combat = 0
    }


viper : Card
viper =
    { name = "Viper"
    , cost = 0
    , trade = 0
    , combat = 1
    }



{- These cards are fictional. Their purpose is to act as fillers for the trade
   deck until other cards are implemented.
-}


fighter : Card
fighter =
    { name = "Fighter"
    , cost = 3
    , trade = 0
    , combat = 5
    }


interceptor : Card
interceptor =
    { name = "Interceptor"
    , cost = 2
    , trade = 1
    , combat = 3
    }
