defmodule MissionControl.Stripe do
  import Enum, only: [map: 2, random: 1]
  import Map, only: [take: 2]

  def charges(created \\ 0) do
    {:ok, charges} = Stripe.Charge.list(%{created: %{gte: created}})

    charges.data
    |> map(fn charge -> convert_attributes(charge) end)
  end

  def seed! do
    # create customer and payment methods
    {:ok, customer} = Stripe.Customer.create(%{email: "test@hexdevs.com"})
    {:ok, _} = Stripe.Card.create(%{customer: customer.id, source: "tok_amex"})

    # charge customer
    for _ <- 1..20, do: random_charge!(customer)
  end

  defp random_charge!(%Stripe.Customer{id: customer_id}) do
    amount = random(1_000..5_000)

    Stripe.Charge.create(%{
      amount: amount,
      currency: "USD",
      customer: customer_id
    })
  end

  defp convert_attributes(charge) do
    charge
    |> take([:created, :amount])
    |> convert_timestamps
    |> convert_amounts
  end

  defp convert_timestamps(%{created: ts} = charge) do
    {:ok, created_date} = DateTime.from_unix(ts, :second)
    %{charge | created: created_date}
  end

  defp convert_amounts(%{amount: amount} = charge) do
    %{charge | amount: amount / 100}
  end
end
