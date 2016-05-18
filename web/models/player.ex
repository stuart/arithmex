defmodule Arithmex.Player do
  use Arithmex.Web, :model

  schema "players" do
    field :name, :string, unique: true
    field :email, :string, unique: true
    field :crypted_password, :string

    timestamps
  end

  @required_fields ~w(name email)
  @optional_fields ~w(crypted_password)

  def changeset(model, params = %{"password" => password}) do
    model
    |> cast(Map.merge(params, %{"crypted_password" => Comeonin.Bcrypt.hashpwsalt(password)}),
        @required_fields, @optional_fields)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
  end

  def changeset(model, params) do
    model
    |> cast(params,@required_fields, @optional_fields)
  end
end
