defmodule DiscussWeb.PollController do
  use DiscussWeb, :controller
  alias Discuss.Votes

  plug DiscussWeb.VerifyUserSession when action in [:new, :create]

  def index(conn, params) do
    %{"page" => page, "per_page" => per_page} = normalize_paging_params(params)
    IO.puts(page)
    IO.puts(per_page)
    polls = Votes.list_most_recent_polls_with_extra(page, per_page)

    opts = paging_options(polls, page, per_page)
    IO.inspect(opts)
    render(conn, "index.html", polls: Enum.take(polls, per_page), opts: opts)
  end

  defp normalize_paging_params(params) do
    IO.puts("normalize_paging_params")
    IO.inspect(params)

    c =
      Map.merge(
        %{"page" => 1, "per_page" => 25},
        params
      )

    IO.inspect(c)

    paging_params(c)
  end

  defp paging_options(polls, page, per_page) do
    IO.puts("paging_options;")
    IO.puts(page)
    IO.puts(per_page)

    %{
      include_next_page: Enum.count(polls) > per_page,
      include_prev_page: page > 0,
      page: page,
      per_page: per_page
    }
  end

  defp paging_params(%{"page" => page, "per_page" => per_page}) do
    page =
      case is_binary(page) do
        true -> String.to_integer(page)
        _ -> page
      end

    per_page =
      case is_binary(per_page) do
        true -> String.to_integer(per_page)
        _ -> per_page
      end

    %{"page" => page, "per_page" => per_page}
  end

  def new(conn, _params) do
    poll = Votes.new_poll()
    render(conn, "new.html", poll: poll)
  end

  def create(conn, %{
        "poll" => poll_params,
        "options" => options,
        "image_data" => image_data
      }) do
    split_options = String.split(options, ",")

    with user <- get_session(conn, :user),
         poll_params <- Map.put(poll_params, "user_id", user.id),
         {:ok, _poll} <- Votes.create_poll_with_options(poll_params, split_options, image_data) do
      conn
      |> put_flash(:info, "Poll created successfully!")
      |> redirect(to: Routes.poll_path(conn, :index))
    else
      {:error, _poll} ->
        conn
        |> put_flash(:error, "Error creating poll!")
        |> redirect(to: Routes.poll_path(conn, :new))
    end
  end

  def create(conn, %{"poll" => _poll_params, "options" => _options} = params) do
    create(conn, Map.put(params, "image_data", nil))
  end

  def vote(conn, %{"id" => id}) do
    voter_ip =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    with {:ok, option} <- Votes.vote_on_option(id, voter_ip) do
      conn
      |> put_flash(:info, "Placed a vote for #{option.title}!")
      |> redirect(to: Routes.poll_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Could not vote!")
        |> redirect(to: Routes.poll_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    with poll <- Votes.get_poll(id),
         messages <- Votes.list_poll_messages(poll.id) |> Enum.reverse() do
      render(conn, "show.html", %{poll: poll, messages: messages})
    end
  end
end
