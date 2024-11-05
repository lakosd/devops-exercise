defmodule Service1.Limiter do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    {:ok, %{processing?: false}}
  end

  def handle_call(:request, _from, state) do
    case state.processing? do
      true ->
        {:reply, :denied, state}
      false ->
        Process.send_after(self(), :timeout, 2000)
        {:reply, :accepted, %{state | processing?: true}}
    end
  end

  def handle_info(:timeout, state) do
    {:noreply, %{state | processing?: false}}
  end
end
