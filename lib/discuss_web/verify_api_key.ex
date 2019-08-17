defmodule DiscussWeb.VerifyApiKey do
  import Plug.Conn, only: [halt: 1, put_status: 2]
  import Phoenix.Controller, only: [render: 3]
  alias Discuss.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    is_valid_api_key?(conn)
    |> handle_conn(conn)
  end

  def fetch_authorization_header(conn) do
    IO.inspect(conn.req_headers)

    conn.req_headers
    |> Enum.into(%{})
    |> Map.fetch("authorization")
  end

  def invalid_api_key(conn) do
    conn
    |> put_status(401)
    |> render(DiscussWeb.ErrorView, "invalid_api_key.json")
    |> halt()
  end

  def decode_authorization_header(auth_header) do
    [type, key] = String.split(auth_header, " ")

    case String.downcase(type) do
      # Base.decode64(key)
      "basic" -> {:ok, Base.url_decode64(key), key}
      _ -> {:error, "Invalid Authorization Header Format"}
    end
  end

  def get_username_key({:ok, key}) do
    String.split(key, ":")
  end

  def is_valid_api_key?(conn) do
    with {:ok, header} <- fetch_authorization_header(conn),
         {:ok, decoded_header, kk} <- decode_authorization_header(header),
         [username, _key] <- get_username_key(decoded_header) do
      Accounts.verify_api_key(username, kk)
    else
      {:error, _} -> false
      _ -> false
    end
  end

  def handle_conn(true, conn), do: conn
  def handle_conn(_, conn), do: invalid_api_key(conn)
end
