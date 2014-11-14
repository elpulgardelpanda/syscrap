require Logger
defmodule Syscrap.Mailer do
  def send_mail() do
    address = Application.get_env(:syscrap, :email_settings)[:address]
    username = Application.get_env(:syscrap, :email_settings)[:username]
    password = Application.get_env(:syscrap, :email_settings)[:password]
    port = Application.get_env(:syscrap, :email_settings)[:port]
    default_to = Application.get_env(:syscrap, :email_settings)[:default_to]

    #:gen_smtp_client.send({to, [to], "Subject: #{subject}\r\nFrom: #{to}\r\nTo: #{to}\r\n\r\n#{body}"}, [{:relay, address}, {:username, username}, {:password, password}])
    :application.start(:gen_smtpc)
    options = [{:host, 'smtp.sendgrid.net'}, {:port, 587}]
    :gen_smtpc.send({username, password}, default_to, 'Subject', 'Mail body', options)
    #:gen_smtp_client.send({to, [to], "Subject: #{subject}\r\nFrom: #{to}\r\nTo: #{to}\r\n\r\n#{body}"}, [{:relay, address}, {:username, username}, {:password, password}])
    #a = "Subject: #{subject}\r\nFrom: Syscrap\r\nTo: Some Dude \r\n\r\n#{body}"# |> to_char_list
    #:gen_smtp_client.send({to, [to], a}, [{:relay, address}, {:port, port}, {:username, username}, {:password, password}])
  end
end
