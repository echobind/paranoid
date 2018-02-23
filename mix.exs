defmodule Paranoid.MixProject do
  use Mix.Project

  @version "0.1.0"
  @project_url "https://github.com/echobind/paranoid"

  def project do
    [
      app: :paranoid,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Library for soft deletion of database records.",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.2"},
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
end
