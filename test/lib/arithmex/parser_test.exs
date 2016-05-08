defmodule Arithmex.ParserTest do
  use ExUnit.Case
  use EQC.ExUnit

  setup_all do
    Arithmex.Parser.generate_parser
    {:ok, :arithmex} = :compile.file('priv/arithmex.erl')
    :ok
  end

  property "integer" do
    forall a <- int() do
      ensure Arithmex.Parser.parse("#{a}") == a
    end
  end

  property "addition" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}+#{b}") == a+b
    end
  end

  property "addition with unicode" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}\u002b#{b}") == a+b
    end
  end

  property "subtraction" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}-#{b}") == a-b
    end
  end

  property "subtraction with unicode" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}\u2212#{b}") == a-b
    end
  end

  property "multiplication" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}*#{b}") == a*b
    end
  end

  property "multiplication with unicode" do
    forall {a,b} <- {int(), int()} do
      ensure Arithmex.Parser.parse("#{a}\u00d7#{b}") == a*b
    end
  end

  property "integer division" do
    forall {a,b} <- {int(), non_zero_integer} do
      ensure Arithmex.Parser.parse("#{a}/#{b}") == div(a,b)
    end
  end

  property "integer division with unicode" do
    forall {a,b} <- {int(), non_zero_integer} do
      ensure Arithmex.Parser.parse("#{a}\u00f7#{b}") == div(a,b)
    end
  end

  property "correctly parses with precedence" do
    forall {a,b,c} <- {int(), int(), int()} do
      ensure Arithmex.Parser.parse("#{a}-#{b}*#{c}") == a-b*c
    end
  end

  property "correctly parses with parens" do
    forall {a,b,c} <- {int(), int(), int()} do
      ensure Arithmex.Parser.parse("(#{a}+#{b})*#{c}") == (a+b)*c
    end
  end

  property "subtraction is left associative" do
    forall {a,b,c} <- {int(), int(), int()} do
      ensure Arithmex.Parser.parse("(#{a}-#{b})-#{c}") == a-b-c
    end
  end

  property "correctly parses complex expression" do
    forall {a, b} <- {int(), list(op_number)} do
      expression = Enum.reduce(b, "#{a}", fn({operation, number}, expr) -> expr <> "#{operation}#{number}" end)
      ensure {Arithmex.Parser.parse(expression), []} == Code.eval_string(clean_expression(expression))
    end
  end

  def non_zero_integer do
    such_that n <- int(), do: n != 0
  end

  def op_number do
    such_that {a,b} <- {oneof(["+", "-", "*", "/", "\u00f7", "\u00d7", "\u2212", "\u002b"]), nat()} do
      a != "/" && a != "\u00f7" && b != 0
    end
  end

  def clean_expression expression do
    expression
    |> String.replace("\u002b", "+")
    |> String.replace("\u2212", "-")
    |> String.replace("\u00d7", "*")
    |> String.replace("\u00f7", "/")
  end
end
