defmodule ElixTogether.CommentFixtures do
  import ElixTogether.PostFixtures

  def comment_fixture(attrs \\ %{}) do
    post = post_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        author: "Test Author",
        content: "Test comment content",
        post_id: post.id
      })
      |> ElixTogether.Comments.create_comment()

    comment
  end

  def comment_fixture(post, attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        author: "Test Author",
        content: "Test comment content",
        post_id: post.id
      })
      |> ElixTogether.Comments.create_comment()

    comment
  end
end
