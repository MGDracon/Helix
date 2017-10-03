defmodule Helix.Server.State.Websocket.GC do
  @moduledoc """
  ServerWebsocketChannelState GC timer.

  Every 30 minutes, or whatever is set to `@interval`, GC will be applied,
  removing unused servers from the Server ETS table set at SerWSChannelState.
  """

  use GenServer

  alias Helix.Server.State.Websocket.Channel, as: ServerWebsocketChannelState

  @interval 30 * 60 * 1000  # 30 minutes
  @registry_name :server_channel_gc

  def start_link(interval \\ @interval),
    do: GenServer.start_link(__MODULE__, interval, name: @registry_name)

  def set_interval(interval),
    do: GenServer.call(@registry_name, {:set_interval, interval})

  def init(interval) do
    timer_ref = schedule(interval)
    {:ok, %{timer_ref: timer_ref, interval: interval}}
  end

  def handle_call({:set_interval, new_interval}, _from, state) do
    Process.cancel_timer(state.timer_ref)
    new_timer = schedule(new_interval)
    {:reply, :ok, %{timer_ref: new_timer, interval: new_interval}}
  end

  def handle_info(:sync, state) do
    ServerWebsocketChannelState.gc()
    timer_ref = schedule(state.interval)
    {:noreply, %{state | timer_ref: timer_ref}}
  end

  defp schedule(interval),
    do: Process.send_after(@registry_name, :sync, interval)
end
