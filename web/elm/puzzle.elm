port module Puzzle exposing (..)

import Html.App as Html
import Html exposing (div, ul, li, text, h2)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Platform.Cmd as Cmd exposing (Cmd)
import Task exposing (Task)
import String
import Debug exposing (log)

main : Program Never
main =
  Html.program
    { init = init, update = update, view = view, subscriptions = subscriptions }

init : (Puzzle, Cmd Msg)
init =
  let
    puzzle =
      {
       id = 123456,
       n_large = 2,
       numbers = [ {id = 1, value = "2", token_type = NumberToken},
                   {id = 2, value = "4", token_type = NumberToken},
                   {id = 3, value = "7", token_type = NumberToken},
                   {id = 4, value = "2", token_type = NumberToken},
                   {id = 5, value = "25", token_type = NumberToken},
                   {id = 6, value = "100", token_type = NumberToken}
                   ],
       target = 532,
       solution = [ ],
       time = 0,
       total = 0
      }
    in
    ( puzzle, Cmd.none )

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
    ul[ id "numbers", class "numbers" ] ( List.map (tokenItem puzzle) puzzle.numbers ),
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

tokenItem : Puzzle -> Token -> Html.Html Msg
tokenItem puzzle token =
  let
    takenClass =
      if isAvailable puzzle token then "available " else "taken "
    validClass =
      if isValid puzzle.solution token then "valid " else "invalid "
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

solutionValue : List Token -> List String
solutionValue solution =
  List.map .value solution

solutionString : Solution -> String
solutionString solution =
  String.concat(List.reverse (solutionValue solution))

-- Convert a solution to an evaluable version --
evaluableSolutionString : Solution -> String
evaluableSolutionString solution =
  case solutionComplete solution of
    True ->
        let makeEval token acc =
          case token.value of
            "×" -> acc ++ "*"
            "÷" -> acc ++ "/"
            "−" -> acc ++ "-"
            val -> acc ++ val
        in
          List.foldr makeEval "" solution
    False -> ""

update : Msg -> Puzzle -> (Puzzle, Cmd Msg)
update msg puzzle =
  case msg of
    AddNumber number -> (addTokenToSolution puzzle number, Cmd.none)
    AddOperator operator -> (addTokenToSolution puzzle operator, Cmd.none)
    Clear -> (clearSolution puzzle, Cmd.none)
    Del -> (deleteToken puzzle, Cmd.none)
    Check -> (puzzle, check(evaluableSolutionString puzzle.solution))
    CalcTotal newTotal -> (updateTotal puzzle newTotal, Cmd.none)

addTokenToSolution : Puzzle -> Token -> Puzzle
addTokenToSolution puzzle token =
  if isAvailable puzzle token == True && isValid puzzle.solution token then
    { puzzle | solution = token :: puzzle.solution  }
  else
    puzzle

clearSolution : Puzzle -> Puzzle
clearSolution puzzle =
  { puzzle | solution = [ ] }

deleteToken : Puzzle -> Puzzle
deleteToken puzzle =
  case List.tail puzzle.solution of
    Just t -> { puzzle | solution =  t}
    Nothing -> puzzle

updateTotal : Puzzle -> Int -> Puzzle
updateTotal puzzle newTotal =
  { puzzle | total = newTotal}

-- Numbers become unavailable if already used in the solution --
isAvailable : Puzzle -> Token -> Bool
isAvailable puzzle token =
  let
    notInSolution solutionToken =
      solutionToken /= token || token.token_type /= NumberToken
  in List.all notInSolution puzzle.solution

-- Is a token valid for adding to the solution --
isValid : Solution -> Token -> Bool
isValid solution token =
  let
    last_added = List.head solution
  in
    case last_added of
      Nothing -> token.token_type == NumberToken || token.token_type == LPar
      Just last_token -> case last_token.token_type of
        NumberToken -> (token.token_type == OperatorToken) || (token.token_type == RPar && parCount solution > 0)
        OperatorToken -> (token.token_type == NumberToken) || (token.token_type == LPar)
        LPar -> token.token_type == NumberToken
        RPar -> token.token_type == OperatorToken

parCount : Solution -> Int
parCount solution =
  let
    parCountToken token acc =
        case token.token_type of
          LPar -> acc + 1
          RPar -> acc - 1
          _ -> acc
  in List.foldl parCountToken 0 solution

-- We use a port here to send to JS to eval the cleaned up solution string --
port check : String -> Cmd msg
port total : (Int -> msg) -> Sub msg

subscriptions : Puzzle -> Sub Msg
subscriptions puzzle =
  total CalcTotal

solutionComplete : Solution -> Bool
solutionComplete solution =
  let
    last_added = List.head solution
  in
    case last_added of
      Nothing -> False
      Just last_token -> parCount solution == 0 && (last_token.token_type == NumberToken || last_token.token_type == RPar)

type alias Puzzle =
  {
    id: Int,
    n_large: Int,
    numbers: List Token,
    target: Int,
    solution: List Token,
    time: Float,
    total: Int
  }

type alias Token =
  {
    id: Int,
    token_type: TokenType,
    value: String
  }

type alias Total =
  { total: Int }

type alias Operator = String
type alias Solution = List Token
type Msg = AddNumber Token | AddOperator Token | Clear | Del | Check | CalcTotal (Int)
type TokenType = OperatorToken | NumberToken | LPar | RPar
