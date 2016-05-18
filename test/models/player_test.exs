defmodule Arithmex.PlayerTest do
  use Arithmex.ModelCase

  alias Arithmex.Player

  @valid_attrs %{"password" => "password", "email" => "some content", "name" => "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset encrypts the password" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert Comeonin.Bcrypt.checkpw("password", changeset.changes.crypted_password)
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end
