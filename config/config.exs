use Mix.Config

config :paranoid,
  ecto_repos: [Paranoid.TestRepo]

if Mix.env  == :test do
  import_config "#{Mix.env}.exs"
end
