defmodule Syscrap.Mixfile do
  use Mix.Project

  def project do
    [app: :syscrap,
     version: get_version_number,
     elixir: "~> 1.2",
     deps: deps]
  end

  def application do
    [applications: [:logger, :ssh, :harakiri],
     included_applications: [:mix, :iex],
     mod: {Syscrap, []}]
  end

  defp deps do
    [ {:gen_smtp, "0.9.0"},
      {:poolboy, "~> 1.5"},
      {:mongo, "~> 0.5"},
      {:sshex, "~> 2.0"},
      {:harakiri, github: "rubencaro/harakiri"}, # for now get it from master
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
