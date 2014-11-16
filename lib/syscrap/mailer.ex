defmodule Syscrap.Mailer do
  @moduledoc """
    Send email.

    ## Example:
      Syscrap.Mailer.send_mail("recipient@email.com", "some subject", "some body")
  """

  @doc """
    Sends an email using some sensible defaults
    It will get smpt settings from `config/private_config.exs`
  """
  def send_mail(to \\ nil, subject \\ '[Syscrap] email', body \\ 'default super useful body') do
    address = Application.get_env(:syscrap, :email_settings)[:address]
    username = Application.get_env(:syscrap, :email_settings)[:username]
    password = Application.get_env(:syscrap, :email_settings)[:password]
    port = Application.get_env(:syscrap, :email_settings)[:port]
    default_to = Application.get_env(:syscrap, :email_settings)[:default_to]
    to = to || default_to

    # Erlang needs strings to be charlists:
    to = to_char_list to
    subject = to_char_list subject
    body = to_char_list body

    :application.start(:gen_smtpc)
    options = [{:host, address}, {:port, port}]
    :gen_smtpc.send({username, password}, to, subject, body, options)
  end
end
