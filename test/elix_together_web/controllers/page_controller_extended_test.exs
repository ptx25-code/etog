defmodule ElixTogetherWeb.PageControllerExtendedTest do
  use ElixTogetherWeb.ConnCase, async: true

  describe "page controller home page" do
    test "GET / returns 200 status", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert conn.status == 200
    end

    test "GET / returns HTML response", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200)
    end

    test "homepage contains main heading", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "🚀 High-Level Summary"
    end

    test "homepage has correct content type", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert String.contains?(conn |> get_resp_header("content-type"), ["text/html"])
    end

    test "homepage is not empty", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert byte_size(response) > 100
    end

    test "homepage contains Phoenix branding", %{conn: conn} do
      conn = get(conn, ~p"/")
      html = html_response(conn, 200)
      # Check for typical Phoenix app content
      assert html =~ ~r/(Phoenix|Elixir|LiveView)/i
    end

    test "navigation links are present", %{conn: conn} do
      conn = get(conn, ~p"/")
      html = html_response(conn, 200)
      # Should have links to main features
      assert html =~ ~r/(clock|listings|posts|post)/i
    end

    test "homepage renders without errors", %{conn: conn} do
      # This should not raise any exceptions
      conn = get(conn, ~p"/")
      assert conn.status in [200, 404, 500]  # At least should get a response
      assert conn.status == 200
    end

    test "stylesheet links are present", %{conn: conn} do
      conn = get(conn, ~p"/")
      html = html_response(conn, 200)
      # Should have CSS links
      assert html =~ ~r/<link[^>]*rel.*stylesheet/i or html =~ ~r/style/i
    end

    test "page is properly structured HTML", %{conn: conn} do
      conn = get(conn, ~p"/")
      html = html_response(conn, 200)
      # Basic HTML structure checks
      assert html =~ ~r/<html/i or html =~ ~r/<!DOCTYPE/i
    end
  end
end
