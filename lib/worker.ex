defmodule ElixirWeather.Worker do
  @api_key "9dcd0927590b78c2d532c1da4451505c"

  def loop() do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})

      _ ->
        IO.puts("don't know how to process this message")
    end
    loop()
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{@api_key}"
  end

  # TODO@dohyeunglee 아래 방법 말고 nested map에 대하여 try-rescue 구문 없이 {:ok, value} 또는 :error를 내뱉는 API가 있는지 조사할 것
  defp compute_temperature(json) do
    with {:ok, main} <- Map.fetch(json, "main"),
         {:ok, temp} <- Map.fetch(main, "temp") do
      {:ok, (temp - 273.15) |> Float.round(1)}
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> Poison.decode!() |> compute_temperature
  end

  defp parse_response(_), do: :error

  def temperature_of(location) do
    result =
      location
      |> url_for
      |> HTTPoison.get()
      |> parse_response

    case result do
      {:ok, temp} ->
        "#{location}: #{temp} C"

      :error ->
        "#{location} not found"
    end
  end
end
