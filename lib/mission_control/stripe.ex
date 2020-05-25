defmodule MissionControl.Stripe do
  import Enum, only: [map: 2]
  import Map, only: [take: 2]

  def charges do
    {:ok, charges} = Stripe.Charge.list()

    charges.data
    |> map(fn charge -> take(charge, [:amount]) end)
  end
end
