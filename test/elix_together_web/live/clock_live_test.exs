defmodule ElixTogetherWeb.ClockLiveTest do
  use ElixTogetherWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "mount assigns current time", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/clock")
    html = render(view)

    # The clock should render with the 🕒 symbol and a time string
    assert html =~ "🕒"
    assert html =~ ":"
  end

  test "tick updates the time", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/clock")

    initial_time =
      Regex.run(~r/\d{2}:\d{2}:\d{2}/, render(view)) |> hd()

    # Wait one second so the time changes
    Process.sleep(1000)
    send(view.pid, :tick)

    updated_time =
      Regex.run(~r/\d{2}:\d{2}:\d{2}/, render(view)) |> hd()

    refute initial_time == updated_time
  end
end
