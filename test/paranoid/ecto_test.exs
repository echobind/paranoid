defmodule Paranoid.Repo do
  use Paranoid.Ecto, repo: Paranoid.TestRepo
end

defmodule Paranoid.EctoTest do
  use Paranoid.EctoCase
  import Ecto.Query
  alias Paranoid.TestRepo
  alias Paranoid.Repo
  alias Paranoid.User

  def insert_user() do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()
    user
  end

  def insert_deleted_user() do
    {:ok, user} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> TestRepo.insert()

    {:ok, deleted_user } = Repo.delete(user)
    deleted_user
  end

  def query(user) do
    User |> where([u], u.id == ^user.id)
  end


  test "all/2 respects deleted_at" do
    user = insert_user()

    assert Repo.all(User) == [user]

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.all(User) == []
  end

  test "all/2 included deleted if option is present" do
    user = insert_user()

    assert Repo.all(User) == [user]

    {:ok, updated_user} = Repo.delete(user)

    assert Repo.all(User, include_deleted: true) == [updated_user]
  end

  test "stream/2 respects deleted_at" do
    user = insert_user()

    stream = Repo.stream(User)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == [user]
    end)

    {:ok, _user} = Repo.delete(user)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == []
    end)
  end

  test "stream/2 includes deleted if option present" do
    user = insert_user()

    stream = Repo.stream(User, include_deleted: true)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == [user]
    end)

    {:ok, user} = Repo.delete(user)

    TestRepo.transaction(fn() ->
      assert Enum.to_list(stream) == [user]
    end)
  end

  test "get/2 respects deleted_at" do
    user = insert_user()

    assert Repo.get(User, user.id) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.get(User, user.id) == nil
  end

  test "get/2 includes deleted if option present" do
    user = insert_user()

    assert Repo.get(User, user.id) == user

    {:ok, updated_user} = Repo.delete(user)

    assert Repo.get(User, user.id, include_deleted: true) == updated_user
  end

  test "get!/2 respects deleted_at" do
    user = insert_user()

    assert Repo.get!(User, user.id) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get!(User, user.id)
    end
  end

  test "get!/2 includes deleted if option present" do
    user = insert_user()

    assert Repo.get!(User, user.id) == user

    {:ok, updated_user} = Repo.delete(user)

    user = Repo.get!(User, user.id, include_deleted: true)

    assert user == updated_user
  end

  test "get_by/2 respects deleted_at" do
    user = insert_user()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.get_by(User, name: user.name) == nil
  end

  test "get_by/2 includes deleted if option present" do
    user = insert_user()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, updated_user} = Repo.delete(user)

    assert Repo.get_by(User, %{name: user.name}, include_deleted: true) == updated_user
  end

  test "get_by!/2 respects deleted_at" do
    user = insert_user()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.get_by!(User, name: user.name)
    end
  end

  test "get_by!/2 includes deleted if option present" do
    user = insert_user()

    assert Repo.get_by(User, name: user.name) == user

    {:ok, updated_user} = Repo.delete(user)

    user = Repo.get_by!(User, %{name: user.name}, include_deleted: true)
    assert user == updated_user
  end

  test "one/2 respects deleted_at" do
    user = insert_user()

    query = User |> where([u], u.id == ^user.id)

    assert Repo.one(query) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.one(query) == nil
  end

  test "one/2 includes deleted if option present" do
    user = insert_user()

    query = User |> where([u], u.id == ^user.id)

    assert Repo.one(query) == user

    {:ok, updated_user} = Repo.delete(user)

    assert Repo.one(query, include_deleted: true) == updated_user
  end

  test "one!/2 respects deleted_at" do
    user = insert_user()

    query = User |> where([u], u.id == ^user.id)
    assert Repo.one!(query) == user

    {:ok, _updated_user} = Repo.delete(user)

    assert_raise Ecto.NoResultsError, fn ->
      Repo.one!(query)
    end
  end

  test "one!/2 includes deleted if option present" do
    user = insert_user()

    query = User |> where([u], u.id == ^user.id)

    assert Repo.one!(query) == user

    {:ok, updated_user} = Repo.delete(user)

    assert Repo.one!(query, include_deleted: true) == updated_user
  end

  test "aggregate/4 respects deleted_at" do
    user = insert_user()
    query = query(user)
    assert Repo.aggregate(query, :sum, :id) != nil

    {:ok, _updated_user} = Repo.delete(user)

    assert Repo.aggregate(query, :sum, :id) == nil
  end

  test "aggregate/4 includes deleted if option present " do
    user = insert_user()
    query = User |> where([u], u.id == ^user.id)
    assert Repo.aggregate(query, :sum, :id) != nil

    {:ok, updated_user} = Repo.delete(user)

    response = Repo.aggregate(query, :sum, :id, include_deleted: true) |> Decimal.to_integer
    assert response == updated_user.id
  end

  test "insert_all/3 functions normally" do
    Repo.insert_all(User, [%{name: "Test User 1"}, %{name: "Test User 2"}])

    user_count = Repo.all(User) |> length()
    assert user_count == 2
  end

  test "update_all/3 respects deleted_at" do
    visible_user = insert_user()
    insert_deleted_user()

    {count, [updated_user]} = from(u in User, select: map(u, [:id, :name]))
                              |> Repo.update_all([set: [name: "Test"]])
    assert updated_user.name == "Test"
    assert updated_user.id == visible_user.id
    assert count == 1
  end

  test "update_all/3 includes delete records if option present" do
    visible_user = insert_user()
    deleted_user = insert_deleted_user()

    {count, updated_users} = from(u in User, select: map(u, [:id, :name]))
                              |> Repo.update_all([set: [name: "Test"]], include_deleted: true)
    assert count == 2
    user_ids = updated_users |> Enum.map(&(&1.id)) |> Enum.sort()

    assert user_ids == [visible_user.id, deleted_user.id]
  end

  test "delete_all/2 respects deleted_at" do
    insert_user()
    insert_deleted_user()

    {count, nil} = Repo.delete_all(User)
    assert count == 1
  end

  test "insert/2 functions normally" do
     assert {:ok, %User{}} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> Repo.insert()
  end

  test "insert!/2 functions normally" do
     assert %User{name: "Test User"} = %User{}
           |> User.changeset(%{name: "Test User"})
           |> Repo.insert!()
  end

  test "update/2 functions normally" do
    user = insert_user()
    changeset = User.changeset(user, %{name: "Updated Name"})

    {:ok, updated_user} = Repo.update(changeset)
    assert updated_user.name == "Updated Name"
  end

  test "update!/2 functions normally" do
    user = insert_user()
    changeset = User.changeset(user, %{name: "Updated Name"})

    %User{} = updated_user = Repo.update!(changeset)
    assert updated_user.name == "Updated Name"
  end

  test "insert_or_update/2 functions normally" do
    user = insert_user()
    changeset = User.changeset(user, %{name: "Updated Name"})

    {:ok, updated_user} = Repo.insert_or_update(changeset)
    assert updated_user.name == "Updated Name"
  end

  test "insert_or_update!/2 functions normally" do
    user = insert_user()
    changeset = User.changeset(user, %{name: "Updated Name"})

    %User{} = updated_user = Repo.insert_or_update!(changeset)
    assert updated_user.name == "Updated Name"
  end

  test "delete/2 updates deleted_at timestamp" do
    user = insert_user()
    {:ok, user} = Repo.delete(user)

    assert user.deleted_at != nil
  end

  test "delete!/2 updates deleted_at timestamp" do
    user = insert_user()
    %User{} = user = Repo.delete!(user)

    assert user.deleted_at != nil
  end

  test "undelete!/2 nullifies the deleted_at timestamp" do
    user = insert_deleted_user()
    assert user.deleted_at != nil

    %User{} = user = Repo.undelete!(user)

    assert user.deleted_at == nil
  end

  test "preload/3 functions normally" do
    user = insert_user()
    address = %{house_number: "123", street: "Main Street", city: "Boston", state: "MA", zip: "02116"}
    address = Ecto.build_assoc(user, :addresses, address)
    {:ok, %Paranoid.Address{} = address} = TestRepo.insert(address)

    user = Repo.get(User, user.id) |> Repo.preload(:addresses)
    addresses = user.addresses
    assert addresses == [address]
  end

end
