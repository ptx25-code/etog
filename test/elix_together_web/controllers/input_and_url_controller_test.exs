defmodule ElixTogetherWeb.InputANDUrlControllerTest do
  use ElixTogetherWeb.ConnCase, async: true

  test "GET /playground renders input form", %{conn: conn} do
    conn = get(conn, ~p"/playground")
    # look for a keyword in inputForm.heex
    assert html_response(conn, 200) =~ "form"
  end

  test "POST /playground renders submitted inputs", %{conn: conn} do
    params = %{"content" => "Hello", "value" => "42", "color" => "#ff0000"}
    conn = post(conn, ~p"/playground", params)
    body = html_response(conn, 200)
    assert body =~ "Hello"
    assert body =~ "42"
    assert body =~ "#ff0000"
  end

  test "GET /playground/:urlEntry renders showFromUrl template", %{conn: conn} do
    conn = get(conn, ~p"/playground/test123")
    assert html_response(conn, 200) =~ "test123"
  end
end
