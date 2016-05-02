defmodule Diplomat.Mixfile do
  use Mix.Project

  def project do
    [app: :diplomat,
     version: "0.0.2",
     elixir: "~> 1.2",
     description: "A library for interacting with Google's Cloud Datastore",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :goth, :exprotobuf, :httpoison, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:goth, "~> 0.1.1"},
      {:exprotobuf, "~> 1.0.0"},
      {:httpoison, "~> 0.8.0"},
      {:poison, "~> 2.1"},
      {:timex, "~> 2.0"},
      # {:chatterbox, github: "joedevivo/chatterbox"},
      {:bypass, "~> 0.1", only: :test},
      {:mix_test_watch, "~> 0.2.5", only: :dev},
      {:uuid, "~> 1.1", only: :test}
    ]
  end
end
