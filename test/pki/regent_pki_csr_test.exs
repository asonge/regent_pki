defmodule Regent.PKI.CSRTest do
  use ExUnit.Case
  alias Regent.PKI.CSR
  doctest CSR

  test "create a new signing request" do
    assert {pubkey, privkey} = :public_key.generate_key({:rsa, 2048, 0x10001})
    alg = CSR.new(info: [subject: [countryName: "US", commonName: "Alice Doe"]],
                  signature_algorithm: :sha1WithRSAEncryption,
                  sign_with: privkey)
    assert %CSR{info: %CSR.Info{}, signature_algorithm: %CSR.SignatureAlgorithm{}, signature: _} = alg
  end

  test "omg wtf" do
    assert true == true
  end

end