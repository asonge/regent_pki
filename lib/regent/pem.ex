defmodule Regent.Pem do
  @moduledoc """
  Utility for decoding and/or decrypting PEM files
  """
  alias Regent.Records, as: R
  alias Regent.{Der}
  require R

  def decode(bin, opts \\ []) do
    with entries <- :public_key.pem_decode(bin),
        {:ok, decoded_entries} <- decode_entries(entries, opts) do
      {:ok, decoded_entries}
    end
  end

  def decode_entry(entry, opts \\ [])
  def decode_entry(entry, opts) do
    password = Keyword.get(opts, :password, "")
    try do
      :public_key.pem_entry_decode(entry, to_charlist(password))
    catch
      error ->
        {:error, error}
    else
      R.cert()=cert -> {:ok, cert}
      R.cert_req()=cr -> {:ok, cr}
      R.rsa_private_key()=key -> {:ok, key}
      R.private_key_info(version: :v1, privateKey: pk) ->
        {:ok, R.rsa_private_key()} = Der.decode(:RSAPrivateKey, pk)
      {:RSAPrivateKey, _, _}=key ->
        IO.puts "IMPLEMENT MEEEEE"
        {:ok, key}
    end
  end

  defp decode_entries(entries, opts) do
    map_or_die(entries, &decode_entry(&1, opts))
  end

  # def encode(bin, opts \\ []) do
  #
  # end

  defp map_or_die(list, fun, acc \\ [])
  defp map_or_die([], _, acc), do: {:ok, Enum.reverse(acc)}
  defp map_or_die([first|rest], fun, acc) do
    case fun.(first) do
      {:ok, value} ->
        map_or_die(rest, fun, [value|acc])
      {:error, err} ->
        {:error, err}
    end
  end

end
