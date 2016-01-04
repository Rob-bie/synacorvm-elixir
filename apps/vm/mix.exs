defmodule VM.Mixfile do
  use Mix.Project

  def project do
    [app: :vm,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {VM, []}]
  end

  defp deps do
    []
  end

end
