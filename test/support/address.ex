defmodule Paranoid.Address do
  import Ecto.Changeset
  use Paranoid.Changeset
  use Ecto.Schema

  schema "addresses" do
    field :house_number, :string
    field :street, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :deleted_at, :utc_datetime
    belongs_to :user, Paranoid.User
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:house_number, :street, :city, :state, :zip])
    |> put_assoc(:user, attrs.user)
  end

end
