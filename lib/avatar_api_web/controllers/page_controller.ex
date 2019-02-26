defmodule AvatarApiWeb.PageController do
  use AvatarApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def avatar(conn, params) do

    name = params["name"]
    shape = params["shape"]
    color = params["color"]
    size = params["size"] |> parse_number

    key = conn.query_string

    return=
    	case Cachex.get(:my_cache, key) do
    		{:ok, nil} -> HashColorAvatar.gen_avatar(name, [shape: shape, color: color, size: size]) |> cache(key)
    		{:ok, something} -> something
    		_other -> HashColorAvatar.gen_avatar(name, [shape: shape, color: color, size: size]) |> cache(key)
    	end

    conn
    |> put_resp_content_type("image/svg+xml")    
    |> send_resp(200, return)

  end  

  def cache(value, key) do
  	Cachex.put(:my_cache, key, value)
  	value
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
