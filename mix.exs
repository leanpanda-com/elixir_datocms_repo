defmodule DatoCMS.Repo.MixProject do
  use Mix.Project

  def project do
    [
      app: :datocms_repo,
      version: "0.6.4",
      elixir: "~> 1.9",
      name: "DatoCMS Repo wrapping the REST client",
      description: "DatoCMS Repo wrapping the REST client",
      package: package(),
      source_url: "https://github.com/leanpanda-com/elixir_datocms_repo",
      homepage_url: "https://github.com/leanpanda-com/elixir_datocms_repo",
      docs: [
        main: "DatoCMS.Repo",
        extras: ["README.md"]
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DatoCMS.Repo.Loader, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:datocms_rest_client, "~> 0.6.0 and >= 0.6.2"},
      {:fermo_helpers, "~> 0.8.2"},
      {:memoize, "~> 1.3"}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/leanpanda-com/elixir_datocms_repo"
      },
      maintainers: ["Joe Yates"]
    }
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
