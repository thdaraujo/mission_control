defmodule MissionControl.Stripe do
  import Enum, only: [map: 2]
  import Map, only: [take: 2]

  def subscriptions() do
    {:ok, subscriptions} = Stripe.Subscription.list()

    subscriptions.data
    |> Enum.flat_map(fn subscription -> subscription.items.data end)
    |> Enum.map(fn item ->
      %{
        created: item.created,
        plan_amount: item.plan.amount / 100,
        quantity: item.quantity,
        interval: item.plan.interval
      }
    end)
    |> map(&convert_attributes/1)
  end

  defp convert_attributes(subscription) do
    subscription
    |> convert_timestamps
    |> normalize_amounts
  end

  defp convert_timestamps(%{created: ts} = subscription) do
    {:ok, created_date} = DateTime.from_unix(ts, :second)
    %{subscription | created: created_date}
  end

  defp normalize_amounts(subscription) do
    total = subscription.plan_amount * subscription.quantity

    case subscription.interval do
      "year" ->
        Map.put(subscription, :amount, total / 12)

      _ ->
        Map.put(subscription, :amount, total)
    end
  end

  # SEED

  def seed! do
    {:ok, plan} =
      Stripe.Plan.create(%{
        amount: 199_00,
        currency: "cad",
        interval: "month",
        product: %{
          name: Faker.Commerce.En.product_name()
        }
      })

    for _ <- 1..10, do: create_subscriber!(plan)
  end

  defp create_subscriber!(plan) do
    {:ok, customer} =
      Stripe.Customer.create(%{
        email: Faker.Internet.email(),
        name: Faker.StarWars.character()
      })

    {:ok, card} =
      Stripe.Card.create(%{
        customer: customer.id,
        source: "tok_amex"
      })

    {:ok, subscription} =
      Stripe.Subscription.create(%{
        customer: customer.id,
        items: [
          %{
            plan: plan.id
          }
        ]
      })

    IO.inspect(%{
      action: :created,
      customer: customer.email,
      card: card.id,
      subscription: subscription.id
    })
  end
end
