defmodule Paranoid.Changeset do
  defmacro __using__(_opts) do
    quote do
      def paranoid_delete_changeset(struct, %{deleted_at: _deleted_at} = attrs) do
        struct
        |> Ecto.Changeset.cast(attrs, [:deleted_at])
      end

      def paranoid_delete_changeset(struct, attrs) do
        attrs = attrs |> add_deleted_at_time()
        paranoid_delete_changeset(struct, attrs)
      end

      def paranoid_undelete_changeset(struct, %{deleted_at: nil} = attrs) do
        struct
        |> Ecto.Changeset.cast(attrs, [:deleted_at])
      end

      def paranoid_undelete_changeset(struct, attrs) do
        attrs = attrs |> nullify_deleted_at_time()
        paranoid_undelete_changeset(struct, attrs)
      end

      defp add_deleted_at_time(attrs) do
        attrs |> Map.put(:deleted_at, DateTime.utc_now())
      end

      defp nullify_deleted_at_time(attrs) do
        attrs |> Map.put(:deleted_at, nil)
      end

      defoverridable paranoid_delete_changeset: 2, paranoid_undelete_changeset: 2
    end
  end
end
