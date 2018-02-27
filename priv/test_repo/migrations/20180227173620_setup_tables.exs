defmodule Paranoid.TestRepo.Migrations.SetupTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :deleted_at, :utc_datetime
    end
  end
end
