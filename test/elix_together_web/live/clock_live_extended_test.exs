defmodule ElixTogetherWeb.ClockLiveExtendedTest do
  use ElixTogetherWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "clock live view" do
    test "mount initializes socket with current time", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/clock")

      # The HTML should contain time in HH:MM:SS format
      assert html =~ ~r/\d{2}:\d{2}:\d{2}/
    end

    test "initial render includes clock emoji", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/clock")
      assert html =~ "🕒"
    end

    test "render returns correct structure", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/clock")
      html = render(view)

      assert html =~ "h1"
      assert html =~ "text-8xl"
      assert html =~ "bg-"
    end

    test "connected? guard works on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/clock")

      # After mount, the timer should be running
      # We can test this by sending a :tick and checking if time updates
      initial_html = render(view)
      initial_time = Regex.run(~r/\d{2}:\d{2}:\d{2}/, initial_html) |> hd()

      Process.sleep(1100)
      send(view.pid, :tick)

      updated_html = render(view)
      updated_time = Regex.run(~r/\d{2}:\d{2}:\d{2}/, updated_html) |> hd()

      # Times should be different after a second
      refute initial_time == updated_time
    end

    test "tick message handler updates time", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/clock")

      time1 = Regex.run(~r/\d{2}:\d{2}:\d{2}/, render(view)) |> hd()

      # Trigger a tick manually
      Process.sleep(1100)
      send(view.pid, :tick)

      time2 = Regex.run(~r/\d{2}:\d{2}:\d{2}/, render(view)) |> hd()

      # Times should differ
      refute time1 == time2
    end

    test "time format is consistent", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/clock")

      for _ <- 1..5 do
        html = render(view)
        # Extract time and verify format
        [time] = Regex.run(~r/\d{2}:\d{2}:\d{2}/, html)

        # Verify HH:MM:SS format
        assert String.match?(time, ~r/^\d{2}:\d{2}:\d{2}$/)

        Process.sleep(100)
        send(view.pid, :tick)
      end
    end

    test "rendered output is not empty", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/clock")

      assert byte_size(html) > 0
      assert String.contains?(html, ["clock", "flex", "bg"])
    end

    test "navigation link back to home exists", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/clock")

      assert html =~ "Back to Home"
      assert html =~ ~p"/"
    end

    test "instructions card is present", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/clock")

      assert html =~ "Clock Demo Info"
      assert html =~ "LiveView"
    end
  end
end
