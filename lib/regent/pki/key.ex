defmodule Regent.PKI.RSAPrivateKey do
  alias __MODULE__
  import Regent.Records, only: [rsa_private_key: 0, rsa_private_key: 1, rsa_private_key: 2]
  
  defstruct [:key]
  
  def from_record(rsa_private_key()=key), do: struct(__MODULE__, key: key)
  def to_record(%RSAPrivateKey{key: key}), do: key

  defimpl Inspect do
    import Inspect.Algebra
    import Regent.Records, only: [rsa_private_key: 1]

    def inspect(%{key: rsa_private_key(modulus: mod, publicExponent: exp)}, opts) do
      ["#", to_doc(RSAPrivateKey, opts), "{", to_doc(mod, opts), to_doc(exp, opts), "}"]
    end
  end
end

defmodule Regent.PKI.RSAPublicKey do
  alias __MODULE__
  
  import Regent.Records, only: [rsa_public_key: 0, rsa_public_key: 1, rsa_private_key: 1]
  
  defstruct [:key]

  def from_privatekey(%Regent.PKI.RSAPrivateKey{}=key) do
    key
    |> Regent.PKI.RSAPrivateKey.to_record()
    |> from_record()
  end

  def from_record(rsa_private_key(modulus: mod, publicExponent: exp)) do
    from_record(rsa_public_key(modulus: mod, publicExponent: exp))
  end
  def from_record(rsa_public_key()=key) do
    struct(__MODULE__, key: key)
  end

  def to_record(%RSAPublicKey{key: key}), do: key

  defimpl Inspect do
    import Inspect.Algebra
    import Regent.Records, only: [rsa_public_key: 1]

    def inspect(%{key: rsa_public_key(modulus: mod, publicExponent: exp)}, opts) do
      ["#", to_doc(RSAPublicKey, opts),"{", to_doc(mod, opts), to_doc(exp, opts), "}"]
    end
  end

end
