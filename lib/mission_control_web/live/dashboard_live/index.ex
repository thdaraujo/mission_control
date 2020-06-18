defmodule MissionControlWeb.DashboardLive.Index do
  use MissionControlWeb, :live_view
  alias Contex.{Sparkline, BarChart, Plot, Dataset}

  # def render(assigns) do
  # end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(chart_options: %{refresh_rate: 1000, number_of_points: 50})
      |> assign(process_counts: [0])
      |> make_test_data()
      |> add_data

    if connected?(socket),
      do: Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    {:ok, socket}
  end

  def handle_event("chart_options_changed", %{} = params, socket) do
    options =
      socket.assigns.chart_options
      |> update_if_positive_int(:number_of_points, params["number_of_points"])
      |> update_if_positive_int(:refresh_rate, params["refresh_rate"])

    socket = assign(socket, chart_options: options)

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, socket.assigns.chart_options.refresh_rate)

    socket =
      socket
      |> make_test_data()

    {:noreply, socket}
  end

  defp update_if_positive_int(map, key, possible_value) do
    case Integer.parse(possible_value) do
      {val, ""} ->
        if val > 0, do: Map.put(map, key, val), else: map

      _ ->
        map
    end
  end

  defp calculate_mrr(subscriptions) do
    total = Enum.map(subscriptions, fn subscription -> subscription.amount end) |> Enum.sum()
    qty = Enum.count(subscriptions)

    total / qty

    # TODO
    # Enum.group_by(subscriptions, fn subscription -> month_year(subscription.created), fn g -> )
  end

  defp make_plot(data) do
    # Enum.map(data, fn subscription -> subscription.amount end)
    amounts = [200, 220, 240, 290, 250, 256, 400, 512, 500, 550, 570, 680, 700, 750]
    plot = Sparkline.new(amounts)

    %{plot | height: 100, width: 800}
    |> Sparkline.draw()
  end

  defp make_red_plot(data) do
    plot = Sparkline.new(data)

    %{plot | height: 100, width: 800}
    |> Sparkline.colours("#fad48e", "#ff9838")
    |> Sparkline.draw()
  end

  defp make_test_data(socket) do
    number_of_points = socket.assigns.chart_options.number_of_points

    result =
      1..number_of_points
      |> Enum.map(fn _ -> :rand.uniform(50) - 100 end)

    assign(socket, test_data: result)
  end

  defp add_data(socket) do
    subscriptions = MissionControl.Stripe.subscriptions()
    assign(socket, subscriptions: subscriptions)
  end

  defp format_date(date), do: date |> Timex.format!("{YYYY}/{M}/{D}")

  defp year_month(date), do: date |> Timex.format!("{YYYY}/{M}")

  # def basic_plot(data) do
  #   charges =
  #     MissionControl.Stripe.charges()
  #     |> Enum.map(fn charges -> {DateTime.to_unix(charges.created), charges.amount} end)

  #   dataset = Dataset.new(charges, ["x", "y"])

  #   plot_content =
  #     BarChart.new(dataset)
  #     |> BarChart.data_labels(true)
  #     |> BarChart.orientation(:vertical)
  #     |> BarChart.colours(["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"])

  #   plot =
  #     Plot.new(800, 400, plot_content)
  #     |> Plot.titles("Stripe", "Charges")

  #   Plot.to_svg(plot)
  # end
end
