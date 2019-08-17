defmodule Discuss.Accounts do
  import Ecto.Query, warn: false

  alias Discuss.Repo
  alias Discuss.Accounts.User

  def list_users, do: Repo.all(User)

  def new_user, do: User.changeset(%User{}, %{})

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def generate_api_key(user) do
    user
    |> User.changeset(%{api_key: random_string(user.username, 32)})
    |> Repo.update()
  end

  def random_string(username, length) do
    key = "#{username}:" <> :crypto.strong_rand_bytes(length)
    Base.url_encode64(key)
  end

  def verify_api_key(username, api_key) do
    case Repo.get_by(User, username: username, api_key: api_key) do
      nil -> false
      _user -> true
    end
  end
end
