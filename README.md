# Paranoid

[![CircleCI](https://circleci.com/gh/echobind/paranoid.svg?style=svg)](https://circleci.com/gh/echobind/paranoid)

**Paranoid is a project providing soft delete capabilities**

Paranoid provides an easy mechanism for Ecto-driven projects to soft delete
records in the database. This makes for easy recovery in case of accidental
deletion or to simply retain data.

## Installation

**To install simply add paranoid to your dependencies**

Update `mix.exs` by adding Paranoid.

```elixir
def deps() do
  [
    {:paranoid, "~> 0.1.4"}
  ]
```

Once installed, a module must be created similar to the following.

```elixir

defmodule MyApp.Paranoid do
  use Paranoid.Ecto, repo: MyApp.Repo
end
```

This will become the primary method of interacting with the Ecto repo.

### Setting up modules for soft delete

In order to support soft delete, each module requires a migration, an instance
of the `use` macro, and updating the schema to include a `deleted_at`
utc_datetime.

**Migration**

Paranoid works by considering any non-null `deleted_at` timestamp to be
"deleted". This migration adds this column.

```elixir
alter table(:your_table) do
  add :deleted_at, :utc_datetime
end
```

**Module Updates**

Paranoid makes available changesets for soft deleting and recovery of records. Leveraging `use`, we bring in these functions and make them overridable for any special use cases a project might have.

```elixir
  use Paranoid.Changeset
```

In order to leverage the newly added field, the field must be added to your schema.

```elixir
field(:deleted_at, :utc_datetime)
```

### Deleting Records ###

Deleting records is as simple as calling `MyApp.Paranoid.delete(struct)`. If the
given module has `deleted-at` as a column, it will be soft deleted. If it does not, it will simply delete the record.


### Retrieving Soft Deleted Records

Backups are only as good as their recovery. To retrieve soft deleted records, there are two steps.

* Retrieve the deleted record
* Undelete the record

```elixir
# retrieve soft deleted user by adding opts of `include_deleted: true`
user = MyApp.Paranoid.get(MyApp.User, 1, include_deleted: true)

# undelete! the user by setting the deleted_at timestamp to nil
MyApp.Paranoid.undelete!(user)

```

Leveraging `MyApp.Paranoid`, an application can call any of the available
`Ecto.Repo` functions. These will respect the `deleted_at` flag wherever
appropriate. Additionally, these functions will retrieve soft deleted records
when the option `include_deleted` is present.

## License

Paranoid is free software and distributed under the MIT license. More information can be found in the [LICENSE](/LICENSE) file.

## About Echobind

Echobind is a software development consultancy that specializes in Elixir. If you have a software project that needs another set of eyes, learn more at our
[website][website].

[website]: https://echobind.com?utm_source=paranoid
