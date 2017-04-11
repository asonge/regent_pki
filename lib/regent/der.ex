defmodule Regent.Der do

  def decode(type, bin) do
    {:ok, :public_key.der_decode(type, bin)}
  end

end
