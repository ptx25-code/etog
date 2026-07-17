defmodule ElixTogetherWeb.PostControllerIntegrationTest do
  use ElixTogetherWeb.ConnCase

  import ElixTogether.PostFixtures

  describe "post controller integration" do
    @valid_post %{title: "Integration Test Post", body: "This is a test body"}
    @invalid_post %{title: "", body: ""}

    test "create post redirects to show page", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @valid_post)
      assert redirected_to(conn) =~ "/posts/"
    end

    test "show post displays post content", %{conn: conn} do
      post = post_fixture(@valid_post)
      conn = get(conn, ~p"/posts/#{post.id}")

      assert html_response(conn, 200) =~ "Integration Test Post"
      assert html_response(conn, 200) =~ "This is a test body"
    end

    test "edit form pre-fills post data", %{conn: conn} do
      post = post_fixture(%{title: "Edit Test", body: "Edit body"})
      conn = get(conn, ~p"/posts/#{post.id}/edit")

      html = html_response(conn, 200)
      assert html =~ "Edit Test"
      assert html =~ "Edit body"
    end

    test "update post persists changes", %{conn: conn} do
      post = post_fixture(@valid_post)

      conn = put(conn, ~p"/posts/#{post.id}", post: %{title: "New Title", body: "New Body"})
      assert redirected_to(conn) == ~p"/posts/#{post.id}"

      conn = get(conn, ~p"/posts/#{post.id}")
      assert html_response(conn, 200) =~ "New Title"
      assert html_response(conn, 200) =~ "New Body"
    end

    test "delete post removes it from listing", %{conn: conn} do
      post = post_fixture(%{title: "To Delete", body: "Delete this"})

      delete(conn, ~p"/posts/#{post.id}")

      conn = get(conn, ~p"/posts")
      refute html_response(conn, 200) =~ "To Delete"
    end

    test "listing page shows all posts", %{conn: conn} do
      post1 = post_fixture(%{title: "Post One", body: "Body one"})
      post2 = post_fixture(%{title: "Post Two", body: "Body two"})

      conn = get(conn, ~p"/posts")
      html = html_response(conn, 200)

      assert html =~ "Post One"
      assert html =~ "Post Two"
    end

    test "create with invalid data shows form errors", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_post)
      assert html_response(conn, 200) =~ "New Post"
    end

    test "update with invalid data shows form errors", %{conn: conn} do
      post = post_fixture(@valid_post)
      conn = put(conn, ~p"/posts/#{post.id}", post: @invalid_post)
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "non-existent post returns 404", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, ~p"/posts/999999")
      end)
    end

    test "new post form renders", %{conn: conn} do
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end
end
