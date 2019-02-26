defmodule AvatarApiWeb.Router do
  use AvatarApiWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AvatarApiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    # get "/avatar.svg", PageController, :avatar 
  end

  # Other scopes may use custom stacks.
  scope "/", AvatarApiWeb do
    # pipe_through :api

    get("/avatar.svg", PageController, :avatar)
  end
end
