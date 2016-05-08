defmodule Arithmex.Parser do
  def generate_parser do
    :neotoma.file 'priv/arithmex.peg', []
  end

  def parse(:no_solution) do
    0
  end

  def parse(statement) do
    statement
    |> :arithmex.parse
    |> handle_parse
  end

  def handle_parse(result) when is_integer(result) do
    result
  end

  def handle_parse(r) do
    r
  end
end
