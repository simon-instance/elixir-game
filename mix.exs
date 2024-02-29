defmodule Minesweeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :minesweeper,
      version: "1.0.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      dependencies: deps()
    ]
  end

  def application do
    [
      mod: {Minesweeper, []},
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      # {:GameBoard, path: "GameBoard.exs"}
    ]
  end
end
