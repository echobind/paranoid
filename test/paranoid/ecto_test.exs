defmodule Paranoid.Repo do
  use Paranoid.Ecto, repo: Paranoid.TestRepo
end

defmodule Paranoid.EctoTest do
  use Paranoid.EctoCase
  import Ecto.Query
  alias Paranoid.TestRepo
  alias Paranoid.Repo
  alias Paranoid.User


  test "all/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    assert Repo.all(User) == [user]

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.all(User) == []
  end

  test "stream/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()


    stream = Repo.stream(User)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == [user]
    end)

    {:ok, _user} = Repo.delete(user)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == []
    end)
  end

  test "get/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    assert Repo.get(User, user.id) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.get(User, user.id) == nil
  end

  test "get!/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    assert Repo.get!(User, user.id) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get!(User, user.id)
    end
  end

  test "get_by/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.get_by(User, name: user.name) == nil
  end

  test "get_by!/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get_by!(User, name: user.name)
    end
  end

  test "one/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    query = User |> where([u], u.id == ^user.id)

    assert Repo.one(query) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.one(query) == nil
  end

  test "one!/2 respects deleted_at" do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    query = User |> where([u], u.id == ^user.id)
    assert Repo.one!(query) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.one!(query)
    end
  end

end
