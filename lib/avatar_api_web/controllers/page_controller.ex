defmodule AvatarApiWeb.PageController do
  use AvatarApiWeb, :controller

  def index(conn, _params) do

  generated =
  	case Cachex.get(:my_cache, "generated") do
  		{:ok, nil} -> 1
  		{:ok, value} -> value
  		_other -> 1
  	end
    render(conn, "index.html", generated: generated)
  end

  def avatar(conn, params) do
  	Cachex.incr(:my_cache, "generated", 1, initial: 3000)
    name = params["name"]
    set = params["set"]
    color = params["color"]
    size = params["size"] |> parse_number
    border = params["border"] |> parse_border 

    key = conn.query_string

	return =
    case color do
    	"random" -> HashColorAvatar.gen_avatar(name, set: set, color: color, size: size, border: border)
    	_else -> 
		      case Cachex.get(:my_cache, key) do
		        {:ok, nil} ->
		          HashColorAvatar.gen_avatar(name, set: set, color: color, size: size, border: border) |> cache(key)

		        {:ok, something} ->
		          something

		        _other ->             
		          HashColorAvatar.gen_avatar(name, set: set, color: color, size: size, border: border) |> cache(key)
		      end
    end

    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(200, return)
  end

  def cache(value, key) do
    Cachex.put(:my_cache, key, value)
    value
  end

  defp parse_border(nil) do
    5
  end

  defp parse_border(string) do
    case Integer.parse(string) do
      {integer, _} -> integer
      :error -> 5
    end
  end

  defp parse_number(nil) do
    100
  end

  defp parse_number(string) do
    case Integer.parse(string) do
      {integer, _} -> integer
      :error -> 100
    end
  end
end
