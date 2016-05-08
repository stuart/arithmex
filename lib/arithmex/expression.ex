defmodule Expression do
  use GenServer

  defmacro is_token(token) do

  end

  def init([]) do
    {:ok, []}
  end

  def tokens do
  end

  def add_token(token) when is_binary(token) do

  end

  def total pid do
    {:ok, total} = GenServer.send(pid, :total)
  end

  def handle_cast({:add_token, token},tokens) do
    {:noreply, tokens ++ [token]}
  end

  def handle_call(:tokens, _from, tokens) do
    {:reply, tokens, tokens}
  end

  def handle_call(:total, _from, tokens) do
    {:reply, 10, tokens}
  end
end
