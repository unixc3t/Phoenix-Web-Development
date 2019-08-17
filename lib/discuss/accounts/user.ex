defmodule Discuss.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discuss.Accounts.User
  alias Discuss.Votes.Poll

  schema "users" do
    field :username, :string
    field :email, :string
    field :active, :boolean, default: true
    field :encrypted_password, :string
    field :api_key, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :polls, Poll
    has_many :images, Discuss.Votes.Image

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :active, :password, :password_confirmation, :api_key])
    |> validate_confirmation(:password, message: "does not match password!")
    |> validate_format(:email, ~r/@/)
    |> encrypt_password()
    |> validate_required([:username, :email, :active, :encrypted_password])
    |> unique_constraint(:username)
  end

  def encrypt_password(changeset) do
    with password when not is_nil(password) <-
           get_change(
             changeset,
             :password
           ) do
      put_change(changeset, :encrypted_password, Bcrypt.hash_pwd_salt(password))
    else
      _ -> changeset
    end
  end
end
