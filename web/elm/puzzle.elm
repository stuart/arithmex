port module Puzzle exposing (..)

import Html.App as Html
import Html exposing (div, ul, li, text, h2)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Platform.Cmd as Cmd exposing (Cmd)
import Task exposing (Task)
import String
import Debug exposing (log)
import Solution exposing (..)
import Http
import Task
import Json.Decode as Json exposing ((:=))

main : Program Never
main =
  Html.program
    { init = init, update = update, view = view, subscriptions = subscriptions }

init : (Puzzle, Cmd Msg)
init =
  let
    puzzle =
       {id = 0, n_large = 0, numbers = [], solution = [], target = 0, time = 30, total = 0}
    in
    ( puzzle, get)

get : Cmd Msg
get =
  Task.perform getFail getSucceed (Http.get puzzleDecoder "http://localhost:4000/api/puzzle")

getFail result =
  let
    l = log "failed" result
  in FetchFail

getSucceed result =
  FetchSucceed (log "succeed" result)

puzzleDecoder : Json.Decoder { id : Int
        , n_large : Int
        , numbers : List Int
        , solution : List Token
        , target : Int
        , time : Int
        , total : Int
        }

puzzleDecoder =
  Json.object7 Puzzle
      ("id" := Json.int)
      ("n_large" := Json.int)
      ("numbers" := Json.list Json.int)
      ("target" := Json.int)
      ("solution" := Json.succeed [ ])
      ("time" := Json.int)
      ("total" := Json.int)

--- VIEW ---
view : Puzzle -> Html.Html Msg
view puzzle =
  div[][
    h2 [] [ puzzleTitle puzzle ],
    div[ class "timer_wrap"] [
      div [class "large_small"] [ puzzleDesc puzzle ],
      div [class "timer"][ ],
      div [class "timer_count"] [ ]
    ],
    div[ class "solution"] [ solutionField puzzle,
        div[ class "total"] [ text (toString (puzzle.total)) ]],
    div[ id "target", class "token target"] [ text (toString puzzle.target) ],
    ul[ id "numbers", class "numbers" ] ( List.map (numberItem puzzle) puzzle.numbers ),
    ul[ id "operators", class "operators" ] ( List.map (tokenItem puzzle) operators ),
    ul[ id "edit", class "edit_keys"] [ clearKey puzzle,
                                        delKey puzzle,
                                        checkKey puzzle ]
  ]

puzzleTitle : Puzzle -> Html.Html Msg
puzzleTitle puzzle =
  text (String.concat [ "Puzzle ", toString(puzzle.id) ])

puzzleDesc : Puzzle -> Html.Html Msg
puzzleDesc puzzle =
  text( String.concat( [toString(puzzle.n_large), " large and ", toString(6 - puzzle.n_large), " small"]))

numberItem : Puzzle -> Int -> Html.Html Msg
numberItem puzzle num =
  tokenItem puzzle (toToken num)

tokenItem : Puzzle -> Token -> Html.Html Msg
tokenItem puzzle token =
  let
    takenClass =
      if Solution.isAvailable puzzle.solution token then "available " else "taken "
    validClass =
      if Solution.isValid puzzle.solution token then "valid " else "invalid "
    typeClass =
      if token.token_type == NumberToken then "number " else "operator "
  in
    li [ class ("token " ++ typeClass ++ takenClass ++ validClass), onClick (AddNumber token) ] [ text token.value ]

clearKey puzzle =
  li [ class ("token operator"), onClick (Clear)] [ text "C" ]

delKey puzzle =
  li [ class ("token operator"), onClick (Del)] [ text "←"]

checkKey puzzle =
  li [ class ("token operator"), onClick (Check)] [ text "="]

operators : List Token
operators = [
  {id = 1, value = "+", token_type = OperatorToken},
  {id = 2, value = "−", token_type = OperatorToken},
  {id = 3, value = "×", token_type = OperatorToken},
  {id = 4, value = "÷", token_type = OperatorToken},
  {id = 5, value = "(", token_type = LPar},
  {id = 6, value = ")", token_type = RPar}]

solutionField : Puzzle -> Html.Html Msg
solutionField puzzle =
  text(solutionString(puzzle.solution))

update : Msg -> Puzzle -> (Puzzle, Cmd Msg)
update msg puzzle =
  case msg of
    AddNumber number -> (addTokenToSolution puzzle number, Cmd.none)
    AddOperator operator -> (addTokenToSolution puzzle operator, Cmd.none)
    Clear -> (clearSolution puzzle, Cmd.none)
    Del -> (deleteToken puzzle, Cmd.none)
    Check -> (puzzle, check(evaluableSolutionString puzzle.solution))
    CalcTotal newTotal -> (updateTotal puzzle newTotal, Cmd.none)
    FetchFail -> (puzzle, Cmd.none)
    FetchSucceed newPuzzle -> (log "puzzle:" newPuzzle, Cmd.none)

addTokenToSolution : Puzzle -> Token -> Puzzle
addTokenToSolution puzzle token =
  { puzzle | solution = Solution.addToken puzzle.solution token  }

clearSolution : Puzzle -> Puzzle
clearSolution puzzle =
  { puzzle | solution = Solution.clear }

deleteToken : Puzzle -> Puzzle
deleteToken puzzle =
  { puzzle | solution = Solution.deleteToken puzzle.solution }

updateTotal : Puzzle -> Int -> Puzzle
updateTotal puzzle newTotal =
  { puzzle | total = newTotal}

-- Subscriptions --
-- We use a port here to send to JS to eval the cleaned up solution string --
port check : String -> Cmd msg
port total : (Int -> msg) -> Sub msg

subscriptions : Puzzle -> Sub Msg
subscriptions puzzle =
  total CalcTotal

toToken : Int -> Solution.Token
toToken num =
  { id = 2, value = toString(num), token_type = Solution.NumberToken }

-- Typedefs --
type alias Puzzle =
  {
    id: Int,
    n_large: Int,
    numbers: List Int,
    target: Int,
    solution: List Token,
    time: Int,
    total: Int
  }

type alias Total =
  { total: Int }

type alias Operator = String
type Msg = AddNumber Token | AddOperator Token | Clear | Del | Check | CalcTotal (Int) | FetchFail | FetchSucceed (Puzzle)
