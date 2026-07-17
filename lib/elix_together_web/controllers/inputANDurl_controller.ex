defmodule ElixTogetherWeb.InputANDUrlController do
  use ElixTogetherWeb, :controller

  def showFromUrl(conn, %{"urlEntry" => urlEntry}) do
    render(conn, :showFromUrl, urlEntry: urlEntry)
  end

  def getInputform(conn, _params) do
    # no changeset, just render the template
    render(conn, :inputForm)
  end

  # POST /playground → process form submission
  def showInputs(conn, params) do
    IO.inspect(params, label: "Form params")
    render(conn, :showInputs, inputs: params)
  end
end
