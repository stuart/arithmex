module Puzzle where
import Html exposing (div, ul, li, text, h2)
import Html.Attributes exposing (class, id)
import String
import StartApp.Simple
import Html.Events exposing (onClick)
import Time exposing (..)

main : Signal Html.Html
main =
  StartApp.Simple.start {
    model = init,
    update = update,
    view = view
  }

init : Puzzle
init =
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
   time = 0
  }

--- VIEW ---
view : Signal.Address Action -> Puzzle -> Html.Html
view address puzzle =
  div[][
    h2 [] [ puzzleTitle puzzle ],
    div[ class "timer_wrap"] [
      div [class "large_small"] [ puzzleDesc puzzle ],
      div [class "timer"][ ],
      div [class "timer_count"] [ ]
    ],
    div[ class "solution"] [ solutionField puzzle ],
    div[ id "target", class "number target"] [ text (toString puzzle.target) ],
    ul[ id "numbers", class "numbers" ] ( List.map (tokenItem address puzzle) puzzle.numbers ),
    ul[ id "operators", class "operators" ] ( List.map (tokenItem address puzzle) operators ),
    ul[ id "edit", class "edit_keys"] [ clearKey address puzzle,
                                        delKey address puzzle ]
  ]

puzzleTitle : Puzzle -> Html.Html
puzzleTitle puzzle =
  text (String.concat [ "Puzzle ", toString(puzzle.id) ])

puzzleDesc : Puzzle -> Html.Html
puzzleDesc puzzle =
  text( String.concat( [toString(puzzle.n_large), " large and ", toString(6 - puzzle.n_large), " small"]))

tokenItem : Signal.Address Action -> Puzzle -> Token -> Html.Html
tokenItem address puzzle token =
  let
    takenClass =
      if isAvailable puzzle token then "available " else "taken "
    validClass =
      if isValid puzzle.solution token then "valid " else "invalid "
    typeClass =
      if token.token_type == NumberToken then "number " else "operator "
  in
    li [ class (typeClass ++ takenClass ++ validClass), onClick address (AddNumber token) ] [ text token.value ]

clearKey address puzzle =
  li [ class ("operator"), onClick address (Clear)] [ text "C" ]

delKey address puzzle =
  li [ class ("operator"), onClick address (Del)] [ text "←"]

operators : List Token
operators = [
  {id = 1, value = "+", token_type = OperatorToken},
  {id = 2, value = "−", token_type = OperatorToken},
  {id = 3, value = "×", token_type = OperatorToken},
  {id = 4, value = "÷", token_type = OperatorToken},
  {id = 5, value = "(", token_type = LPar},
  {id = 6, value = ")", token_type = RPar}]

solutionField : Puzzle -> Html.Html
solutionField puzzle =
  text(String.concat( List.reverse (solutionValue puzzle.solution) ))

solutionValue : List Token -> List String
solutionValue solution =
  List.map .value solution

update : Action -> Puzzle -> Puzzle
update action puzzle =
  case action of
    AddNumber number -> addTokenToSolution puzzle number
    AddOperator operator -> addTokenToSolution puzzle operator
    Clear -> clearSolution puzzle
    Del -> deleteToken puzzle

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

-- Numbers become unavailable if already used in the solution --
isAvailable : Puzzle -> Token -> Bool
isAvailable puzzle token =
  let
    notInSolution solutionToken =
      solutionToken /= token || token.token_type /= NumberToken
  in List.all notInSolution puzzle.solution

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

type alias Puzzle =
  {
    id: Int,
    n_large: Int,
    numbers: List Token,
    target: Int,
    solution: List Token,
    time: Float
  }

type alias Token =
  {
    id: Int,
    token_type: TokenType,
    value: String
  }

type alias Operator = String
type alias Solution = List Token
type Action = AddNumber Token | AddOperator Token | Clear | Del
type TokenType = OperatorToken | NumberToken | LPar | RPar
