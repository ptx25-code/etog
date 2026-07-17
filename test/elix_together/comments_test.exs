defmodule ElixTogether.CommentsTest do
  use ElixTogether.DataCase

  alias ElixTogether.Comments
  alias ElixTogether.Posts

  describe "comments" do
    alias ElixTogether.Comments.Comment

    import ElixTogether.PostFixtures

    @valid_comment_attrs %{author: "Alice", content: "Great post!"}
    @invalid_comment_attrs %{author: nil, content: nil}

    setup do
      post = post_fixture()
      {:ok, post: post}
    end

    test "list_comments/0 returns all comments", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      comments = Comments.list_comments()
      assert length(comments) >= 1
      assert Enum.any?(comments, &(&1.id == comment.id))
    end

    test "get_comment!/1 returns the comment with given id", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      fetched_comment = Comments.get_comment!(comment.id)
      assert fetched_comment.id == comment.id
      assert fetched_comment.author == "Alice"
    end

    test "create_comment/1 with valid data creates a comment", %{post: post} do
      valid_attrs = Map.put(@valid_comment_attrs, "post_id", post.id)
      assert {:ok, %Comment{} = comment} = Comments.create_comment(valid_attrs)
      assert comment.author == "Alice"
      assert comment.content == "Great post!"
      assert comment.post_id == post.id
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(@invalid_comment_attrs)
    end

    test "create_comment/1 requires post_id", %{post: post} do
      attrs = Map.put(@valid_comment_attrs, "post_id", post.id)
      {:ok, comment} = Comments.create_comment(attrs)
      assert comment.post_id == post.id
    end

    test "update_comment/2 with valid data updates the comment", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      update_attrs = %{author: "Bob", content: "Updated comment"}

      assert {:ok, %Comment{} = updated} = Comments.update_comment(comment, update_attrs)
      assert updated.author == "Bob"
      assert updated.content == "Updated comment"
    end

    test "update_comment/2 with invalid data returns error changeset", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      assert {:error, %Ecto.Changeset{}} = Comments.update_comment(comment, @invalid_comment_attrs)
      assert comment == Comments.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      assert {:ok, %Comment{}} = Comments.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Comments.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset", %{post: post} do
      {:ok, comment} = Comments.create_comment(Map.put(@valid_comment_attrs, "post_id", post.id))
      assert %Ecto.Changeset{} = Comments.change_comment(comment)
    end
  end
end
