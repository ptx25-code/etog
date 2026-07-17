defmodule ElixTogether.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixTogether.Posts.Post

  schema "comments" do
    field :name, :string
    field :content, :string
    belongs_to :post, Post, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:name, :content, :post_id])
    |> validate_required([:name, :content, :post_id])
  end
end
