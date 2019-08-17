# defmodule My do
#  defstruct password: "", apassword_hash: "", aencrypted_password: ""
# end

defmodule MyTests do
  # use Discuss.DataCase
  use ExUnit.Case
  # alias Bcrypt.Base
  # import Ecto.Changeset
  # alias Discuss.Accounts.User
  # alias Discuss.Accounts

  @moduledoc """
  import Ecto.Changeset
  alias Discuss.Accounts.User

  test "test1" do
  a =
    Discuss.Accounts.User.changeset(%User{}, %{
      username: "test",
      email: "test@test.com",
      password: "123",
      password_confirmation: "123"
    })

  with password <- get_change(a, :username) do
    # IO.inspect(password)
  end

  # IO.inspect(a)
  end

  @valid_attrs %{
    username: "test",
    email: "test@test.com",
    active: true,
    password: "test",
    password_confirmation: "test"
  }
  def user_fixture(attrs \\ %{}) do
    with create_attrs <- Map.merge(@valid_attrs, attrs),
         {:ok, user} <- Accounts.create_user(create_attrs) do
      user |> Map.merge(%{password: nil, password_confirmation: nil})
    else
      error -> error
    end
  end

  def check_vectors(_password, _salt, _stored_hash) do
    user = user_fixture()
    p = Map.merge(user, %{password: nil, password_confirmation: nil, encrypted_password: "test"})

    m = %My{
      :password => "123",
      :apassword_hash => Bcrypt.hash_pwd_salt("111111"),
      :aencrypted_password => Bcrypt.hash_pwd_salt("111111")
    }

    temp = %{:hash_key => "apassword_hash"}

    re = Bcrypt.check_pass(m, "111111", %{:hash_key => :apassword_hash})
    ra = Bcrypt.check_pass(p, "test")
  end

  test "test" do
    check_vectors("111111", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.", "12")
  end
  """

  def hello(%{name: table} = state) do
    IO.puts(table)
    IO.inspect(state)
  end

  test "ddf" do
    dave = %{name: "hello", zz: "tx", likes: "paint"}

    hello(dave)

    case dave do
      %{zz: some_state} = person ->
        IO.puts("#{person.name} lives in #{some_state}")

      _ ->
        IO.puts("NO matches")
    end
  end

  test "map.mergd" do
    s = :crypto.strong_rand_bytes(32)

    # <<116, 101, 115, 116, 58, 0>>
    # = "test:" <> <<0>>

    # IO.inspect(String.slice(b, 0, 4))
    c = "test:" <> s

    IO.inspect(c)
    dd = Base.url_encode64(c)
    {:ok, he} = Base.url_decode64(dd)
    IO.inspect(String.split(he, ":"))

    zz =
      <<122, 80, 226, 203, 18, 160, 167, 65, 143, 136, 93, 198, 219, 3, 131, 65, 6, 225, 241, 126,
        13, 151, 111, 239, 228, 54, 103, 115, 245, 204, 253, 183>>

    IO.inspect(Base.decode64(dd))
  end
end
