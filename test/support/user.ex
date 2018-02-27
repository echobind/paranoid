defmodule Paranoid.User do
  import Ecto.Changeset
  use Paranoid.Changeset
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :deleted_at, :utc_datetime
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name])
  end
end
