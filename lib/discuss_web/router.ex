defmodule DiscussWeb.Router do
  use DiscussWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug DiscussWeb.VerifyApiKey
  end

  scope "/", DiscussWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/polls", PollController, only: [:index, :new, :create, :show]
    resources "/users", UserController, only: [:new, :show, :create]

    resources "/sessions", SessionController, only: [:create]

    get "/login", SessionController, :new
    get "/logout", SessionController, :delete

    get "/options/:id/vote", PollController, :vote
    get "/history", PageController, :history
    post "/users/:id/generate_api_key", UserController, :generate_api_key
  end

  scope "/api", DiscussWeb do
    pipe_through :api

    resources "/polls", Api.PollController, only: [:index, :show]
  end
end
