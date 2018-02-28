defmodule Paranoid.TestRepo.Migrations.SetupTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :deleted_at, :utc_datetime
    end

    create table(:addresses) do
      add :house_number, :string
      add :street, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :deleted_at, :utc_datetime
      add :user_id, references(:users)
    end
  end
end
