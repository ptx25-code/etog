defmodule ElixTogether.PostsCommentsIntegrationTest do
  use ElixTogether.DataCase

  alias ElixTogether.Posts
  alias ElixTogether.Comments

  import ElixTogether.PostFixtures
  import ElixTogether.CommentFixtures

  describe "post and comments relationship" do
    test "post with comments returns comment count" do
      post = post_fixture()
      comment_fixture(post, %{author: "Alice", content: "First comment"})
      comment_fixture(post, %{author: "Bob", content: "Second comment"})

      count = Posts.get_number_of_comments(post.id)
      assert count == 2
    end

    test "post without comments returns zero count" do
      post = post_fixture()
      count = Posts.get_number_of_comments(post.id)
      assert count == 0
    end

    test "adding comment to post increments count" do
      post = post_fixture()
      assert Posts.get_number_of_comments(post.id) == 0

      Posts.add_comment(post.id, %{author: "Alice", content: "First comment"})
      assert Posts.get_number_of_comments(post.id) == 1

      Posts.add_comment(post.id, %{author: "Bob", content: "Second comment"})
      assert Posts.get_number_of_comments(post.id) == 2
    end

    test "deleting comment from post decrements count" do
      post = post_fixture()
      {:ok, comment} = Comments.create_comment(%{
        author: "Alice",
        content: "Comment to delete",
        post_id: post.id
      })

      assert Posts.get_number_of_comments(post.id) == 1

      Comments.delete_comment(comment)
      assert Posts.get_number_of_comments(post.id) == 0
    end

    test "post preload includes all comments" do
      post = post_fixture()
      comment_fixture(post, %{author: "Alice"})
      comment_fixture(post, %{author: "Bob"})

      # Manually fetch and preload
      loaded_post =
        Posts.get_post!(post.id)
        |> ElixTogether.Repo.preload([:comments])

      assert length(loaded_post.comments) == 2
      assert Enum.any?(loaded_post.comments, &(&1.author == "Alice"))
      assert Enum.any?(loaded_post.comments, &(&1.author == "Bob"))
    end

    test "deleting post cascades delete to comments" do
      post = post_fixture()
      {:ok, comment} = Comments.create_comment(%{
        author: "Alice",
        content: "Comment",
        post_id: post.id
      })

      assert Posts.get_number_of_comments(post.id) == 1

      Posts.delete_post(post)

      assert_raise Ecto.NoResultsError, fn ->
        Comments.get_comment!(comment.id)
      end
    end

    test "multiple posts have independent comment counts" do
      post1 = post_fixture(%{title: "Post 1", body: "Body 1"})
      post2 = post_fixture(%{title: "Post 2", body: "Body 2"})

      comment_fixture(post1, %{author: "Alice"})
      comment_fixture(post1, %{author: "Bob"})
      comment_fixture(post2, %{author: "Charlie"})

      assert Posts.get_number_of_comments(post1.id) == 2
      assert Posts.get_number_of_comments(post2.id) == 1
    end
  end
end
