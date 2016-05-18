module Puzzle.Solution exporting (Solution Token addToken solutionString evaluableSolutionString)
  type alias Solution = List Token
  type TokenType = OperatorToken | NumberToken | LPar | RPar
  type alias Token =
    {
      id: Int,
      token_type: TokenType,
      value: String
    }

addToken : Solution -> Token -> Solution
addToken solution token =
  if notInSolution solution token == True && isValid solution token then
    token :: solution
  else
    solution

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

notInSolution solution, token =
  let
    notInSolution solutionToken =
      solutionToken /= token || token.token_type /= NumberToken
  in List.all notInSolution solution

solutionComplete : Solution -> Bool
solutionComplete solution =
  let
    last_added = List.head solution
  in
    case last_added of
      Nothing -> False
      Just last_token -> parCount solution == 0 && (last_token.token_type == NumberToken || last_token.token_type == RPar)
