defmodule ElixTogetherWeb.ListingsLiveExtendedTest do
  use ElixTogetherWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "listings live view initialization" do
    test "mount initializes all assigns correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      # Check that initial assigns are set
      assert view.assigns.submitted_notes == []
      assert view.assigns.show_chart == false
      assert view.assigns.chart_type == "pie"
    end

    test "mount renders form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/listings")
      assert html =~ "Add Item and Quantity"
    end

    test "page title is correct", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/listings")
      assert html =~ "Quietboard"
    end
  end

  describe "adding notes to listings" do
    test "form submission with valid data adds note", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Apples", "value" => "5", "color" => "#ff0000"})

      html = render(view)
      assert html =~ "Apples"
      assert html =~ "5"
    end

    test "multiple notes can be added", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Apples", "value" => "5", "color" => "#ff0000"})

      view
      |> element("form")
      |> render_submit(%{"content" => "Oranges", "value" => "3", "color" => "#ffa500"})

      html = render(view)
      assert html =~ "Apples"
      assert html =~ "Oranges"
    end

    test "submitted_notes list grows after each submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      assert length(view.assigns.submitted_notes) == 0

      view
      |> element("form")
      |> render_submit(%{"content" => "Note 1", "value" => "1", "color" => "#000000"})

      assert length(view.assigns.submitted_notes) == 1

      view
      |> element("form")
      |> render_submit(%{"content" => "Note 2", "value" => "2", "color" => "#111111"})

      assert length(view.assigns.submitted_notes) == 2
    end
  end

  describe "deleting notes from listings" do
    test "delete button removes note from list", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "To Delete", "value" => "1", "color" => "#000000"})

      assert render(view) =~ "To Delete"

      view
      |> element("button[phx-click=delete_note]")
      |> render_click()

      refute render(view) =~ "To Delete"
    end

    test "deleting multiple notes works", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      # Add three notes
      view |> element("form") |> render_submit(%{"content" => "Note 1", "value" => "1", "color" => "#000000"})
      view |> element("form") |> render_submit(%{"content" => "Note 2", "value" => "2", "color" => "#111111"})
      view |> element("form") |> render_submit(%{"content" => "Note 3", "value" => "3", "color" => "#222222"})

      assert length(view.assigns.submitted_notes) == 3

      # Delete one
      view
      |> element("button[phx-click=delete_note]")
      |> render_click()

      assert length(view.assigns.submitted_notes) == 2
    end
  end

  describe "chart type selection" do
    test "chart type can be changed to bar", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Data", "value" => "10", "color" => "#000000"})

      view
      |> element("select")
      |> render_change(%{"chart_type" => "bar"})

      assert view.assigns.chart_type == "bar"
    end

    test "chart type can be changed to doughnut", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Data", "value" => "10", "color" => "#000000"})

      view
      |> element("select")
      |> render_change(%{"chart_type" => "doughnut"})

      assert view.assigns.chart_type == "doughnut"
    end

    test "default chart type is pie", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")
      assert view.assigns.chart_type == "pie"
    end

    test "chart type persists after adding notes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("select")
      |> render_change(%{"chart_type" => "bar"})

      view
      |> element("form")
      |> render_submit(%{"content" => "Data", "value" => "5", "color" => "#000000"})

      assert view.assigns.chart_type == "bar"
    end
  end

  describe "navigation and layout" do
    test "back to home link exists", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/listings")
      assert html =~ "Back to Home"
    end

    test "instructions card is displayed", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/listings")
      assert html =~ "Quietboard"
      assert html =~ "Tech Overview"
    end

    test "form has required input fields", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/listings")
      # Check for input fields in the form
      assert html =~ ~r/<input[^>]*placeholder/
    end
  end

  describe "note attributes" do
    test "note stores all attributes correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Test Item", "value" => "42", "color" => "#aabbcc"})

      [note] = view.assigns.submitted_notes
      assert note[:content] == "Test Item"
      assert note[:value] == "42"
      assert note[:color] == "#aabbcc"
    end

    test "numeric value is stored as string", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/listings")

      view
      |> element("form")
      |> render_submit(%{"content" => "Item", "value" => "100", "color" => "#000000"})

      [note] = view.assigns.submitted_notes
      assert note[:value] == "100"
    end
  end
end
