defmodule DiscussWeb.PageController do
  use DiscussWeb, :controller
  alias Discuss.Votes
  alias Discuss.ChatCache

  def index(conn, _params) do
    messages = Votes.list_lobby_messages() |> Enum.reverse()
    render(conn, "index.html", messages: messages)
  end

  def history(conn, _params) do
    IO.puts("888888888888")
    IO.inspect(ChatCache.lookup())
    IO.puts("888888888888")
    render(conn, "history.html", logs: ChatCache.lookup())
  end
end
