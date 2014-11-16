defmodule Syscrap.Mailer do

  @doc """

    Sends given raw body to given `to` address as given `from` address.

    Body is raw means it's the actual email payload, including desired headers.
    Is up to the sender to provide a suitable body to send.

    Example of use:

    ```
      raw_body = "Subject: crappy subject\r\n" <>
                  "From: crappy@syscrap.com\r\n" <>
                  "To: crappier@syscrap.com\r\n" <>
                  "\r\n" <>
                  "Actual body"

      raw_body |> send from: 'crappy@syscrap.com', to: 'crappier@syscrap.com'
    ```
  """

  def send(body, [from: from, to: to]) do
    opts = Application.get_env(:syscrap, :smtp_opts)
    email = { to, [from], body }

    :gen_smtp_client.send_blocking(email,opts)
  end

end
