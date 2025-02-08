defmodule Designex.MixProject do
  use Mix.Project

  @version "1.0.2"
  @source_url "https://github.com/netoum/designex"

  def project do
    [
      app: :designex,
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      package: package(),
      description: "Mix tasks for installing and invoking Designex CLI",
      package: [
        links: %{
          "GitHub" => @source_url
        },
        licenses: ["MIT"]
      ],
      docs: [
        main: "Designex",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["CHANGELOG.md"]
      ],
      aliases: aliases()
    ]
  end

  defp package do
    [
      maintainers: ["Karim Semmoud"],
      licenses: ["MIT"],
      files: ~w(lib CHANGELOG.md LICENSE.md mix.exs package.json README.md .formatter.exs)
    ]
  end

  def application do
    [
      extra_applications: [:logger, inets: :optional, ssl: :optional],
      mod: {Designex, []},
      env: [default: []]
    ]
  end

  defp deps do
    [
      {:castore, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp aliases do
    [
      "designex.build": "mix designex",
      test: ["designex.install --if-missing", "test"],
      "archive.build": &raise_on_archive_build/1
    ]
  end

  defp raise_on_archive_build(_) do
    Mix.raise("""
    You are trying to install "designex" as an archive, which is not supported.
    """)
  end
end
