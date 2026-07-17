defmodule ElixTogether.PostFixtures do
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> ElixTogether.Posts.create_post()

    post
  end
end
