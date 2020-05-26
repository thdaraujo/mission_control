defmodule MissionControl.Stripe do
  import Enum, only: [map: 2, random: 1]
  import Map, only: [take: 2]

  def charges do
    {:ok, charges} = Stripe.Charge.list()

    charges.data
    |> map(fn charge -> take(charge, [:amount]) end)
  end

  def seed! do
    # create customer and payment methods
    {:ok, customer} = Stripe.Customer.create(%{email: "test@hexdevs.com"})
    {:ok, _} = Stripe.Card.create(%{customer: customer.id, source: "tok_amex"})

    # charge customer
    for _ <- 1..10, do: random_charge!(customer)
  end

  defp random_charge!(%Stripe.Customer{id: customer_id}) do
    amount = random(1_000..5_000)
    Stripe.Charge.create(%{amount: amount, currency: "USD", customer: customer_id})
  end
end
