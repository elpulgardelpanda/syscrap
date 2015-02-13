defmodule Syscrap.Mixfile do
  use Mix.Project

  def project do
    [app: :syscrap,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :ssh, :harakiri],
     included_applications: [:mix, :iex],
     mod: {Syscrap, []}]
  end

  defp deps do
    [ {:gen_smtp, "0.9.0"},
      {:mongo, "~> 0.5"},
      {:poolboy, "~> 1.4.0"},
      {:harakiri, "0.2.0"},
      {:sshex, "1.0.0"} ]
  end
end
