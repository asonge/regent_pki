defmodule Regent.Records do
  import Record, only: [defrecord: 3]

  @records Record.extract_all(from_lib: "public_key/include/public_key.hrl")

  defrecord(:attr, :AttributeTypeAndValue, @records[:AttributeTypeAndValue])
  defrecord(:attr_pkcs10, :"AttributePKCS-10", @records[:"AttributePKCS-10"])

  defrecord(:cert, :Certificate, @records[:Certificate])
  defrecord(:tbs_cert, :TBSCertificate, @records[:TBSCertificate])
  defrecord(:otp_cert, :OTPCertificate, @records[:OTPCertificate])

  defrecord(:cert_req, :CertificationRequest, @records[:CertificationRequest])
  defrecord(:cert_req_signatureAlgorithm, :CertificationRequest_signatureAlgorithm, @records[:CertificationRequest_signatureAlgorithm])
  defrecord(:cert_reqinfo, :CertificationRequestInfo, @records[:CertificationRequestInfo])
  defrecord(:cert_reqinfo_subject_pkinfo, :CertificationRequestInfo_subjectPKInfo, @records[:CertificationRequestInfo_subjectPKInfo])
  defrecord(:cert_reqinfo_subject_pkinfo_algorithm, :CertificationRequestInfo_subjectPKInfo_algorithm, @records[:CertificationRequestInfo_subjectPKInfo_algorithm])

  defrecord(:dsa_private_key, :DSAPrivateKey, @records[:DSAPrivateKey])

  defrecord(:enc_private_key_info, :EncryptedPrivateKeyInfo, @records[:EncryptedPrivateKeyInfo])
  defrecord(:enc_private_key_info_enc_alg, :EncryptedPrivateKeyInfo_encryptionAlgorithm, @records[:EncryptedPrivateKeyInfo_encryptionAlgorithm])

  defrecord(:rsa_private_key, :RSAPrivateKey, @records[:RSAPrivateKey])
  defrecord(:rsa_public_key, :RSAPublicKey, @records[:RSAPublicKey])

  defrecord(:private_key_info, :PrivateKeyInfo, @records[:PrivateKeyInfo])

  def to_keywords(record) do
    tag = elem(record, 0)
    @records[tag]
    |> Enum.with_index(1)
    |> Enum.map(fn {{key, _value}, offset} -> {key, elem(record, offset)} end)
  end

end

{:ok, trees} = :code.lib_dir(:public_key)
                 |> Path.join("include/OTP-PUB-KEY.hrl")
                 |> :epp_dodger.parse_file()
constants = trees
            |> Enum.map(&:erl_syntax_lib.strip_comments/1)
            |> Enum.reject(&match?({:record, _},:erl_syntax_lib.analyze_attribute(&1)))
            |> Enum.map(fn {:tree, :attribute, {:attr, _, _, :none}, {:attribute, {:atom, _, :define}, [{:atom,_,_}=a,b]}} ->
              {:erl_syntax.concrete(a), :erl_syntax.concrete(b)};
              _ -> nil
            end)

defmodule Regent.Asn1 do

  @constants constants

  def null(), do: {:asn1_OPENTYPE, <<5, 0>>}

  def oid(atom)
  for {name, oid} <- @constants do
    def oid(unquote(name)), do: unquote(Macro.escape(oid))
  end

  def name(oid) do
    @constants |> Enum.filter(&match?({_, ^oid}, &1)) |> Enum.map(&elem(&1, 0))
  end

end
