defmodule ElixirWeather do
  def temperature_of(cities) do
    coordinator_pid = spawn(ElixirWeather.Coordinator, :loop, [[], Enum.count(cities)])

    cities
    |> Enum.each(fn city ->
      worker_pid = spawn(ElixirWeather.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end
end
