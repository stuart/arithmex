defmodule Arithmex.PuzzleGenerator do
  alias Arithmex.Puzzle
  @doc """
    Generates an Arithmex puzzle.

    Params:
       * n_large: how many large numbers to pick. Must be from 0 to 4
       * random: wether the target is randomly chosen or a guaranteed solution.

    Returns a puzzle struct all filled in.
  """
  def generate(n_large, random \\ false) do
    numbers = generate_numbers(n_large)
    %Puzzle{numbers: numbers, target: generate_target(numbers, random), n_large: n_large, guaranteed_solution: !random}
    |> Arithmex.Lily.solve
  end

  defp generate_numbers(n_large) when n_large <= 4 and n_large >= 0 do
    small = [1,2,3,4,5,6,7,8,9]
    large = [25,50,75,100]

    n_small = 6 - n_large

    l = Enum.take_random(large, n_large)
    Enum.reduce(1..n_small, l, fn(_, acc) -> [ Enum.random(small) | acc] end)
  end

  defp generate_target(numbers, false) do
    do_generate(numbers, 0)
  end

  defp generate_target(_, true) do
    :crypto.rand_uniform(100,999)
  end

  defp do_generate(_, t) when t > 99 and t < 1000 do
    t
  end

  defp do_generate(numbers, _) do
    funs = [fn(a,b) -> a + b end,
            fn(a,b) -> a + b end,
            fn(a,b) -> a * b end,
            fn(a,b) -> a * b end,
            fn
              (a,0) -> a
              (a,b) when rem(a,b) == 0 -> div(a,b)
              (a,b) when rem(b,a) == 0 -> div(b,a)
              (a,b) -> a * b
            end,
            fn
              (a,b) when a >= b -> a - b
              (a,b) when a < b -> b - a
            end,
          ]

    do_generate(numbers,
      numbers
      |> Enum.shuffle
      |> Enum.take(:crypto.rand_uniform(4,6))
      |> Enum.reduce(0, fn(a,b) -> Enum.random(funs).(a,b) end)
    )
  end
end
