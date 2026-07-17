defmodule ElixTogetherWeb.PostControllerTest do
  use ElixTogetherWeb.ConnCase, async: true

  import ElixTogether.PostFixtures

  @valid_post %{title: "First post", body: "Hello world!"}
  @invalid_post %{title: "", body: ""}

  # @valid_comment %{author: "Alice", content: "Nice post!"}
  @invalid_comment %{author: "", content: ""}

  test "GET /posts lists posts", %{conn: conn} do
    conn = get(conn, ~p"/posts")
    assert html_response(conn, 200) =~ "Listing Posts"
  end

  test "GET /posts/new renders new form", %{conn: conn} do
    conn = get(conn, ~p"/posts/new")
    assert html_response(conn, 200) =~ "New Post"
  end

  test "POST /posts creates post with valid data", %{conn: conn} do
    conn = post(conn, ~p"/posts", post: @valid_post)
    assert redirected_to(conn) =~ "/posts/"
  end

  test "POST /posts fails with invalid data", %{conn: conn} do
    conn = post(conn, ~p"/posts", post: @invalid_post)
    assert html_response(conn, 200) =~ "New Post"
  end

  test "GET /posts/:id shows post", %{conn: conn} do
    post = post_fixture(@valid_post)
    conn = get(conn, ~p"/posts/#{post.id}")
    assert html_response(conn, 200) =~ post.title
  end

  test "GET /posts/:id/edit renders edit form", %{conn: conn} do
    post = post_fixture(@valid_post)
    conn = get(conn, ~p"/posts/#{post.id}/edit")
    assert html_response(conn, 200) =~ "Edit Post"
  end

  test "PUT /posts/:id updates post with valid data", %{conn: conn} do
    post = post_fixture(@valid_post)
    conn = put(conn, ~p"/posts/#{post.id}", post: %{title: "Updated", body: "Changed"})
    assert redirected_to(conn) == ~p"/posts/#{post.id}"
  end

  test "PUT /posts/:id fails with invalid data", %{conn: conn} do
    post = post_fixture(@valid_post)
    conn = put(conn, ~p"/posts/#{post.id}", post: @invalid_post)
    assert html_response(conn, 200) =~ "Edit Post"
  end

  test "DELETE /posts/:id deletes post", %{conn: conn} do
    post = post_fixture(@valid_post)
    conn = delete(conn, ~p"/posts/#{post.id}")
    assert redirected_to(conn) == ~p"/posts"
  end

  # test "POST /posts/:id/comment adds comment with valid data", %{conn: conn} do
  #   post = post_fixture(@valid_post)

  #   # Initially, there should be 0 comments
  #   assert ElixTogether.Posts.get_number_of_comments(post.id) == 0

  #   # Submit a valid comment
  #   conn = post(conn, ~p"/posts/#{post.id}/comment", comment: @valid_comment)
  #   assert redirected_to(conn) == ~p"/posts/#{post.id}"

  #   # Now the count should be 1
  #   assert ElixTogether.Posts.get_number_of_comments(post.id) == 1
  # end

  test "POST /posts/:id/comment fails with invalid data", %{conn: conn} do
    post = post_fixture(@valid_post)

    conn = post(conn, ~p"/posts/#{post.id}/comment", comment: @invalid_comment)
    assert redirected_to(conn) == ~p"/posts/#{post.id}"

    conn = get(conn, ~p"/posts/#{post.id}")
    assert html_response(conn, 200) =~ "Oops! Couldn&#39;t add comment!"
  end
end
