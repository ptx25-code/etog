defmodule ElixTogetherWeb.PageController do
  use ElixTogetherWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
