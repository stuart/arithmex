defmodule Arithmex.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :email, :string
      add :crypted_password, :string
      timestamps
    end

    create unique_index(:players, [:email])
    create unique_index(:players, [:name])
  end
end
