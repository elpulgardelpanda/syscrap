defmodule Syscrap.Mixfile do
  use Mix.Project

  def project do
    [app: :syscrap,
     version: get_version_number,
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
      {:harakiri, "0.6.0"},
      {:sshex, "2.0.1"},
      # {:bottler, "0.5.0"},
      {:bottler, github: "rubencaro/bottler"}, # for now get it from master
      {:populator, github: "rubencaro/populator"}, # for now get it from master
    ]
  end

  defp get_version_number do
    commit = :os.cmd('git rev-parse --short HEAD') |> to_string |> String.rstrip(?\n)
    v = "1.0.0+#{commit}"
    if Mix.env == :dev, do: v = v <> "dev"
    v
  end
end
