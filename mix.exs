defmodule Hsluv.MixProject do
  use Mix.Project

  def project do
    [
      app: :hsluv,
      version: "0.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "HSLuv",
      source_url: "https://git.goyman.com/kuon/ex-hsluv"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A library to convert between RGB and HSLuv color spaces"
  end

  defp package() do
    [
      licenses: ["Apache-2.0", "MIT"],
      links: %{"Git" => "https://git.goyman.com/kuon/ex-hsluv"}
    ]
  end
end
