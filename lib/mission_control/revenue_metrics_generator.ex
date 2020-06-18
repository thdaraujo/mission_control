defmodule MissionControl.RevenueMetricsGenerator do
  use GenServer

  def start_link(_initial_state) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    schedule_work()

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:work, _state) do
    current_ts = :os.system_time(:millisecond)
    # TODO send state
    subscriptions = MissionControl.Stripe.subscriptions()

    # for subscription <- subscriptions, do: measure(subscription)

    schedule_work()

    {:noreply, current_ts}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 60 * 1000)
  end
end
