defmodule Paranoid.Ecto do
  import Ecto.Query

  @moduledoc """
  Module for interacting with an Ecto Repo that leverages soft delete functionality.
  """

  defmacro __using__(opts) do
    verify_ecto_dep()

    if repo = Keyword.get(opts, :repo) do
      quote do
        def all(queryable, opts \\ []) do
          unquote(repo)
          |> apply(:all, [update_queryable(queryable, opts), opts])
        end

        def stream(queryable, opts \\ []) do
          unquote(repo)
          |> apply(:stream, [update_queryable(queryable, opts), opts])
        end

        def get(queryable, id, opts \\ []) do
          unquote(repo)
          |> apply(:get, [update_queryable(queryable, opts), id, opts])
        end

        def get!(queryable, id, opts \\ []) do
          unquote(repo)
          |> apply(:get!, [update_queryable(queryable, opts), id, opts])
        end

        def get_by(queryable, clauses, opts \\ []) do
          unquote(repo)
          |> apply(:get_by, [update_queryable(queryable, opts), clauses, opts])
        end

        def get_by!(queryable, clauses, opts \\ []) do
          unquote(repo)
          |> apply(:get_by!, [update_queryable(queryable, opts), clauses, opts])
        end

        def one(queryable, opts \\ []) do
          unquote(repo)
          |> apply(:one, [update_queryable(queryable, opts), opts])
        end

        def one!(queryable, opts \\ []) do
          unquote(repo)
          |> apply(:one!, [update_queryable(queryable, opts), opts])
        end

        def aggregate(queryable, aggregate, field, opts \\ []) do
          unquote(repo)
          |> apply(:aggregate, [update_queryable(queryable, opts), aggregate, field, opts])
        end

        def insert_all(schema_or_source, entries, opts \\ []) do
          unquote(repo)
          |> apply(:insert_all, [schema_or_source, entries, opts])
        end

        def update_all(queryable, updates, opts \\ []) do
          unquote(repo)
          |> apply(:update_all, [update_queryable(queryable, opts), updates, opts])
        end

        def delete_all(queryable, opts \\ []) do
          delete_all(queryable, opts, has_deleted_column?(queryable))
        end

        def delete_all(queryable, opts, _has_deleted_column = true) do
          unquote(repo)
          |> apply(:update_all, [update_queryable(queryable, opts), [set: [deleted_at: DateTime.utc_now()]]])
        end

        def delete_all(queryable, opts, _no_deleted_column) do
          unquote(repo)
          |> apply(:delete_all, [queryable, opts])
        end

        def insert(struct, opts \\ []) do
          unquote(repo)
          |> apply(:insert, [struct, opts])
        end

        def insert!(struct, opts \\ []) do
          unquote(repo)
          |> apply(:insert!, [struct, opts])
        end

        def update(struct, opts \\ []) do
          unquote(repo)
          |> apply(:update, [struct, opts])
        end

        def update!(struct, opts \\ []) do
          unquote(repo)
          |> apply(:update!, [struct, opts])
        end

        def insert_or_update(changeset, opts \\ []) do
          unquote(repo)
          |> apply(:insert_or_update, [changeset, opts])
        end

        def insert_or_update!(changeset, opts \\ []) do
          unquote(repo)
          |> apply(:insert_or_update!, [changeset, opts])
        end

        def delete(struct, opts \\ []) do
          delete(struct, opts, has_deleted_column?(struct))
        end

        def delete(struct, opts, _has_deleted_column = true) do
          unquote(repo)
          |> apply(:update, [delete_changeset(struct), opts])
        end

        def delete(struct, opts, _no_deleted_column = false) do
          unquote(repo)
          |> apply(:delete, [struct, opts])
        end

        def delete!(struct, opts \\ []) do
          delete!(struct, opts, has_deleted_column?(struct))
        end

        def delete!(struct, opts, _has_deleted_column = true) do
          unquote(repo)
          |> apply(:update!, [delete_changeset(struct), opts])
        end

        def delete!(struct, opts, _no_deleted_column = false) do
          unquote(repo)
          |> apply(:delete!, [struct, opts])
        end

        def undelete!(struct, opts \\ []) do
          unquote(repo)
          |> apply(:update!, [undelete_changeset(struct), opts])
        end

        defp delete_changeset(struct) do
          struct.__struct__.paranoid_delete_changeset(struct, %{})
        end

        defp undelete_changeset(struct) do
          struct.__struct__.paranoid_undelete_changeset(struct, %{})
        end

        def preload(struct_or_structs_or_nil, preloads, opts \\ []) do
          unquote(repo)
          |> apply(:preload, [struct_or_structs_or_nil, preloads, opts])
        end

        def load(schema_or_types, data) do
          unquote(repo)
          |> apply(:load, [schema_or_types, data])
        end

        defp update_queryable(queryable, opts) when is_list(opts) do
          queryable
          |> update_queryable(Enum.into(opts, %{}))
        end

        defp update_queryable(queryable, %{include_deleted: true}) do
          queryable
        end

        defp update_queryable(queryable, %{has_deleted_column: false}), do: queryable

        defp update_queryable(queryable, %{has_deleted_column: true}) do
          queryable
          |> where([t], is_nil(t.deleted_at))
        end

        defp update_queryable(queryable, opts) do
          opts = opts |> Map.put(:has_deleted_column, has_deleted_column?(queryable))

          queryable
          |> update_queryable(opts)
        end

        defp has_deleted_column?(%{from: %{source: {_, struct}}}) do
          struct.__schema__(:fields)
          |> Enum.member?(:deleted_at)
        end

        defp has_deleted_column?(%{} = struct) do
          struct.__struct__.__schema__(:fields)
          |> Enum.member?(:deleted_at)
        end

        defp has_deleted_column?(queryable) do
          queryable |> Ecto.Queryable.to_query() |> has_deleted_column?()
        end
      end
    else
      raise ArgumentError, """
      expected :repo to be provided as an option.
      Example:

      use Paranoid.Ecto, repo: MyApp.Repo
      """
    end
  end

  defp verify_ecto_dep do
    unless Code.ensure_loaded?(Ecto) do
      raise "Paranoid requires Ecto to be added as a dependency."
    end
  end
end
