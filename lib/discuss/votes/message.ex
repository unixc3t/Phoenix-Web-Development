defmodule Discuss.Votes.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discuss.Votes.Message

  schema "messages" do
    field :message, :string
    field :author, :string
    belongs_to :poll, Discuss.Votes.Poll
    timestamps()
  end

  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:message, :author, :poll_id])
    |> validate_required([:message, :author])
  end
end
