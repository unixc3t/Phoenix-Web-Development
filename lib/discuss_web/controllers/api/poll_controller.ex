defmodule DiscussWeb.Api.PollController do
  use DiscussWeb, :controller
  alias Discuss.Votes
  action_fallback DiscussWeb.Api.ErrorController

  def index(conn, _params) do
    polls = Votes.list_most_recent_polls()
    render(conn, "index.json", polls: polls)
  end

  def show(conn, %{"id" => id}) do
    case Votes.get_poll(id) do
      nil -> {:error, :not_found}
      poll -> render(conn, "show.json", poll: poll)
    end
  end
end
