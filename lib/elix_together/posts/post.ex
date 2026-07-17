defmodule ElixTogether.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixTogether.Comments.Comment

  schema "posts" do
    field :title, :string
    field :body, :string
    has_many :comments, Comment, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
