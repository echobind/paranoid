defmodule Paranoid.MixProject do
  use Mix.Project

  @version "0.1.4"
  @project_url "https://github.com/echobind/paranoid"

  def project do
    [
      app: :paranoid,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Library for soft deletion of database records.",
      elixirc_paths: elixirc_paths(Mix.env),
      docs: [main: "readme", extras: ["README.md"]],
      aliases: aliases(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: app_list(Mix.env),
    ]
  end

  def app_list(:test), do: app_list() ++ [:ecto, :postgrex]
  def app_list(_), do: app_list()
  def app_list(), do: [:logger]

  defp deps do
    [
      {:ecto, "~> 3.1", optional: true},
      {:ecto_sql, "~> 3.1.6"},
      {:earmark, ">= 0.0.0", only: :dev},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:ex_doc, "~> 0.18.3", only: :dev}
    ]
  end

  defp package() do
    [
      maintainers: ["Robert Beene"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @project_url,
        "Made by echobind" => "https://echobind.com"
      }
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support", "test/support/models"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]


  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
