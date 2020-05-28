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
    charges = MissionControl.Stripe.charges()

    for charge <- charges, do: measure(charge)

    schedule_work()

    {:noreply, current_ts}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 10 * 1000)
  end

  defp measure(charge) do
    :telemetry.execute([:revenue], %{
      charge: charge.amount
    })
  end
end
