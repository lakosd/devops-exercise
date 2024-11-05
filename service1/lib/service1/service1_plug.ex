defmodule Service1.Service1Plug do
  use Plug.Builder

  import Plug.Conn

  plug :ask_limiter
  plug Service1.ResponderPlug

  def ask_limiter(conn, _opts) do
    case GenServer.call(Service1.Limiter, :request) do
      :denied ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(503, "Service unavailable")
        |> halt()
      :accepted ->
        conn
    end
  end
end
