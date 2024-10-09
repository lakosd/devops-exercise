defmodule Service1.Service1Plug do
  import Plug.Conn

  @disk_space_cmd ~s(df | awk '$6 == "/" {print $4}')
  @processes_cmd ~s(ps)
  @uptime_cmd ~s<uptime | sed 's/^ [^ ]* up \\([^,]*,[^,]*\\),.*/\\1/'>
  @ip_cmd ~s(hostname -i)

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response_body())
  end

  defp response_body() do
    service2_resp = Req.get!("http://service2:8198/").body
    {:ok, json_str} =
      JSON.encode([
        service1: [
          ip: ip(),
          processes: processes(),
          diskSpace: disk_space(),
          uptime: uptime()
        ],
        service2: service2_resp
      ])

    json_str
  end

  defp disk_space() do
    {disk_space, 0} = System.shell(@disk_space_cmd)
    String.trim(disk_space)
  end

  defp ip() do
    {ip, 0} = System.shell(@ip_cmd)
    String.trim(ip)
  end

  defp uptime() do
    {uptime, 0} = System.shell(@uptime_cmd)
    String.trim(uptime)
  end

  defp processes() do
    {processes, 0} = System.shell(@processes_cmd)

    processes
    |> String.split("\n", trim: true)
    |> tl()
    |> Enum.map(&split_proc_info/1)
  end

  defp split_proc_info(process_str) do
    process_info = String.split(process_str, ~r{\s}, trim: true, parts: 4)
    Enum.zip([:pid, :user, :time, :command], process_info)
  end
end
