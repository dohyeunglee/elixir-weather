defmodule ElixirWeatherTest do
  use ExUnit.Case
  doctest ElixirWeather

  test "greets the world" do
    assert ElixirWeather.hello() == :world
  end
end
