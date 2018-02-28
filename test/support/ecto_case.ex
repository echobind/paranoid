defmodule Paranoid.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Paranoid.TestRepo)
  end
end
