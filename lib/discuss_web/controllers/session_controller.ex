defmodule DiscussWeb.SessionController do
  use DiscussWeb, :controller
  alias Discuss.Accounts

  def new(conn, _) do
    render(conn, "new.html")
  end

  def delete(conn, _) do
    conn
    |> delete_session(:user)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end

  def create(conn, %{"username" => username, "password" => password}) do
    with user <- Accounts.get_user_by_username(username),
         {:ok, login_user} <- login(user, password) do
      conn
      |> put_flash(:info, "Logged in successfully!")
      |> put_session(:user, %{
        id: login_user.id,
        username: login_user.username,
        email: login_user.email
      })
      |> redirect(to: "/")
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid username/password!")
        |> render("new.html")
    end
  end

  defp login(user, password) do
    IO.inspect(user)
    IO.puts(password)
    Bcrypt.check_pass(user, password)
  end
end
