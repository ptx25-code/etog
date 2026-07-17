defmodule ElixTogetherWeb.ListingsLiveTest do
  use ElixTogetherWeb.ConnCase
  import Phoenix.LiveViewTest

  test "mount sets initial assigns", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/listings")
    html = render(view)
    assert html =~ "Quietboard-like"
    assert html =~ "Add Notes"
  end

  test "submit_note adds a note", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/listings")

    view
    |> element("form")
    |> render_submit(%{"content" => "Test note", "value" => "42", "color" => "#ff0000"})

    html = render(view)
    assert html =~ "Test note - 42"
  end

  test "delete_note removes a note", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/listings")

    view
    |> element("form")
    |> render_submit(%{"content" => "Delete me", "value" => "1", "color" => "#000000"})

    html = render(view)
    assert html =~ "Delete me - 1"

    view
    |> element("button[phx-click=delete_note]")
    |> render_click()

    html = render(view)
    refute html =~ "Delete me - 1"
  end

  test "change_chart_type updates chart_type", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/listings")

    # Add a note so the chart is rendered
    view
    |> element("form")
    |> render_submit(%{"content" => "Chart test", "value" => "10", "color" => "#123456"})

    # Change chart type
    view
    |> element("select")
    |> render_change(%{"chart_type" => "bar"})

    html = render(view)
    assert html =~ "data-chart-type=\"bar\""
  end

  test "download_json pushes event", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/listings")

    # Add a note
    view
    |> element("form")
    |> render_submit(%{"content" => "Export", "value" => "5", "color" => "#00ff00"})

    # Trigger download
    view |> element("#save-btn") |> render_click()

    # Assert push_event payload
    assert_push_event(view, "download_json", %{json: json})
    assert json =~ "Export"
  end
end
