defmodule DiscussWeb.Api.ErrorController do
  use DiscussWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(DiscussWeb.ErrorView, "404.json")
  end

  def call(conn, _) do
    conn
    |> put_status(500)
    |> render(DiscussWeb.ErrorView, "500.json")
  end
end
