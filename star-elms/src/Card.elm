module Card exposing (Card, view, viewFaceDown)

import Html exposing (Html, br, div, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List exposing (intersperse, map, singleton)
import Utilities exposing (inBrackets)


type alias Card =
    { name : String
    , cost : Int
    , trade : Int
    , combat : Int
    }



-- VIEW


view : Maybe msg -> Card -> Html msg
view maybeWhenClicked card =
    let
        baseContainerAttributes =
            [ class "card"
            , class "card--face-up"
            ]

        containerAttributes =
            case maybeWhenClicked of
                Nothing ->
                    baseContainerAttributes

                Just whenClicked ->
                    class "card--interactive"
                        :: onClick whenClicked
                        :: baseContainerAttributes

        cost =
            card.cost
                |> String.fromInt
                |> inBrackets

        trade =
            card.trade
                |> String.fromInt
                |> String.append "Trade: \u{00A0}"

        combat =
            card.combat
                |> String.fromInt
                |> String.append "Combat: "
    in
    div containerAttributes
        [ multilineText [ cost, card.name ]
        , div [ class "card__separator" ] []
        , multilineText [ trade, combat ]
        ]


viewFaceDown : Html msg
viewFaceDown =
    div
        [ class "card", class "card--face-down" ]
        [ multilineText [ "STAR", "ELMS" ] ]



-- PRIVATE


multilineText : List String -> Html msg
multilineText lines =
    let
        break =
            br [] []
    in
    lines
        |> map text
        |> intersperse break
        |> p []
        |> singleton
        |> div []
