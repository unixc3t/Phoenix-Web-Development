defmodule DiscussWeb.PollsChannel do
  use DiscussWeb, :channel

  def join("polls:" <> _poll_id, %{"remote_ip" => remote_ip}, socket) do
    {:ok, assign(socket, :remote_ip, remote_ip)}
  end

  def handle_in("ping", _payload, socket) do
    broadcast(socket, "pong", %{message: "pong"})
    {:reply, {:ok, %{message: "pong"}}, socket}
  end

  def handle_in("vote", %{"option_id" => option_id}, %{assigns: %{remote_ip: remote_ip}} = socket) do
    IO.puts("____")
    IO.inspect(socket)
    IO.puts("____")

    with {:ok, option} <- Discuss.Votes.vote_on_option(option_id, remote_ip) do
      broadcast(socket, "new_vote", %{"option_id" => option.id, "votes" => option.votes})
      {:reply, {:ok, %{"option_id" => option.id, "votes" => option.votes}}, socket}
    else
      {:error, _} ->
        {:reply, {:error, %{message: "Failed to vote for option!"}}, socket}
    end
  end
end
