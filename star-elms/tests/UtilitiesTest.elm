module UtilitiesTest exposing (..)

import Expect
import Test exposing (Test, describe, test)
import Utilities


utilitiesTestSuite : Test
utilitiesTestSuite =
    describe "The Utilities module"
        [ describe "Utilities.inBrackets"
            [ test "surrounds a string in brackets" <|
                \_ -> Expect.equal "(foo)" (Utilities.inBrackets "foo")
            ]
        ]
