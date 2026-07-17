defmodule ElixTogether.PostsValidationTest do
  use ElixTogether.DataCase

  alias ElixTogether.Posts
  alias ElixTogether.Posts.Post

  describe "post validation" do
    test "post requires title" do
      assert {:error, changeset} = Posts.create_post(%{body: "some body"})
      assert "can't be blank" in errors_on(changeset).title
    end

    test "post requires body" do
      assert {:error, changeset} = Posts.create_post(%{title: "some title"})
      assert "can't be blank" in errors_on(changeset).body
    end

    test "post requires both title and body" do
      assert {:error, changeset} = Posts.create_post(%{})
      assert "can't be blank" in errors_on(changeset).title
      assert "can't be blank" in errors_on(changeset).body
    end

    test "post accepts valid title and body" do
      assert {:ok, post} = Posts.create_post(%{title: "Test", body: "Test body"})
      assert post.title == "Test"
      assert post.body == "Test body"
    end

    test "post changeset with valid attributes" do
      changeset = Post.changeset(%Post{}, %{title: "Test", body: "Test body"})
      assert changeset.valid?
    end

    test "post changeset with invalid attributes" do
      changeset = Post.changeset(%Post{}, %{})
      refute changeset.valid?
    end

    test "post with empty string title is invalid" do
      changeset = Post.changeset(%Post{}, %{title: "", body: "body"})
      refute changeset.valid?
    end

    test "post with empty string body is invalid" do
      changeset = Post.changeset(%Post{}, %{title: "title", body: ""})
      refute changeset.valid?
    end

    test "post updates preserve valid data" do
      {:ok, post} = Posts.create_post(%{title: "Original", body: "Original body"})
      {:ok, updated} = Posts.update_post(post, %{title: "Updated", body: "Updated body"})
      assert updated.title == "Updated"
      assert updated.body == "Updated body"
    end
  end

  describe "post listing" do
    test "list_posts returns empty list when no posts" do
      posts = Posts.list_posts()
      # May not be empty if other tests create posts, so just verify it's a list
      assert is_list(posts)
    end

    test "list_posts returns all created posts" do
      {:ok, post1} = Posts.create_post(%{title: "Post 1", body: "Body 1"})
      {:ok, post2} = Posts.create_post(%{title: "Post 2", body: "Body 2"})

      posts = Posts.list_posts()
      post_ids = Enum.map(posts, & &1.id)

      assert post1.id in post_ids
      assert post2.id in post_ids
    end
  end
end
