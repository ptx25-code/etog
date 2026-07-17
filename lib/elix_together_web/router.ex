defmodule ElixTogetherWeb.Router do
  use ElixTogetherWeb, :router

  # adding put_layout <- so that every controller action that does thru the :browser pipeline will automatically use the app.html.heex layout
  # (which has all the top bar,centre positioning all laid out properly)
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixTogetherWeb.Layouts, :root}
    plug :put_layout, {ElixTogetherWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixTogetherWeb do
    pipe_through :browser
    get "/", PageController, :home #homepage is a controller action, not liveview
    live "/clock", ClockLive #liveview
    live "/listings", ListingsLive #liveview

    resources "/posts", PostController do
      post "/comment", PostController, :add_comment
    end

    get "/playground/:urlEntry", InputANDUrlController, :showFromUrl
    get "/playground", InputANDUrlController, :getInputform
    post "/playground", InputANDUrlController, :showInputs
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixTogetherWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:elix_together, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ElixTogetherWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
