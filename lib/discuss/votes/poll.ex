defmodule Discuss.Votes.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discuss.Votes.Poll
  alias Discuss.Votes.Option
  alias Discuss.Accounts.User

  schema "polls" do
    field :title, :string
    has_many :options, Option
    belongs_to :user, User
    has_one :image, Discuss.Votes.Image
    has_many :vote_records, Discuss.Votes.VoteRecord
    has_many :messages, Discuss.Votes.Message

    timestamps()
  end

  def changeset(%Poll{} = poll, attrs) do
    poll
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
