defmodule MissionControl.ServerMetricsGenerator do
  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    schedule_work()

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:work, state) do
    :telemetry.execute([:mission_control, :server], %{
      usage: Enum.random(0..100)
    })

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    # 2 seconds
    Process.send_after(self(), :work, 2 * 1000)
  end
end
