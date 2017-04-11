defmodule Regent.PKI.CSR do
  @moduledoc """
  Certificate Signing Request datatype and API
  """

  @type signatureAlgorithms :: tuple |
    :"id-dsa-with-sha1" | :id_dsaWithSHA1 | :md2WithRSAEncryption |
    :"md5-with-rsa-encryption" | :"sha1-with-rsa-encryption" |
    :"sha-1with-rsa-encryption" | :"sha224-with-rsa-encryption" |
    :"sha256-with-rsa-encryption" | :"sha384-with-rsa-encryption" |
    :"sha512-with-rsa-encryption" | :"ecdsa-with-sha1" |
    :"ecdsa-with-sha224" | :"ecdsa-with-sha256" | :"ecdsa-with-sha384" |
    :"ecdsa-with-sha512"

  @type publickeyEncryption :: tuple | :"id-dsa" | :"rsaEncryption" |
                               :dhpublicnumber | :"id-keyExchangeAlgorithm" |
                               :"id-ecPublicKey"

  @enforce_keys [:info, :signature_algorithm, :signature]
  defstruct [:info, :signature_algorithm, :signature]

  alias __MODULE__, as: CSR

  @opaque t :: %CSR{
    info: Info.t,
    signature_algorithm: nil, #SignatureAlgorithm.t,
    signature: binary
  }

  alias Regent.Records, as: R
  alias Regent.Asn1
  require R

  defmodule Info do
    @enforce_keys [:subject, :subjectPKInfo]
    defstruct version: :v1,
              subject: {:rdnSequence, []},
              subjectPKInfo: nil,
              attributes: []

    def new(attr) do
      with subj <- Keyword.fetch!(attr, :subject),
           R.rsa_public_key()=public_key <- Keyword.fetch!(attr, :public_key),
           attributes = Keyword.get(attr, :attributes, []) do
        der_public_key = :public_key.der_encode(:RSAPublicKey, public_key)
        alg = R.cert_reqinfo_subject_pkinfo_algorithm(algorithm: Asn1.oid(:rsaEncryption), parameters: Asn1.null())
        pk_info = R.cert_reqinfo_subject_pkinfo(algorithm: alg, subjectPublicKey: der_public_key)
        struct(__MODULE__, subject: subj, subjectPKInfo: pk_info, attributes: attributes)
      end
    end

    def to_record(%Info{version: v, subject: subj, subjectPKInfo: pkinfo, attributes: attr}) do
      R.cert_reqinfo(version: v, subject: Regent.PKI.DN.sequence(subj), subjectPKInfo: pkinfo, attributes: attr)
    end
    
  end

  defmodule SignatureAlgorithm do
    defstruct [:algorithm, :parameters]

    @simple_algs [:sha1WithRSAEncryption]

    @signature_algorithms [
      sha: Asn1.oid(:sha1WithRSAEncryption)
    ]

    def new(:sha), do: new(:sha1WithRSAEncryption)
    def new(alg) when alg in @simple_algs, do: struct(__MODULE__, algorithm: Asn1.oid(alg), parameters: Asn1.null())

    for {simple, oid} <- @signature_algorithms do
      def name(%SignatureAlgorithm{algorithm: unquote(Macro.escape oid)}), do: unquote(Macro.escape simple)
    end

    def to_record(%SignatureAlgorithm{algorithm: alg, parameters: attr}) do
      R.cert_req_signatureAlgorithm(algorithm: alg, parameters: attr)
    end
  end

  alias CSR.{Info, SignatureAlgorithm}

  @doc """
  Create a new CSR
  """
  def new(fields) when is_list(fields) do
    with {:ok, raw_info} <- fetch(fields, :info),
         {:ok, raw_alg}  <- fetch(fields, :signature_algorithm),
         {:ok, key}      <- fetch(fields, :sign_with),
         info = %Info{} = Info.new(raw_info),
         alg  = %SignatureAlgorithm{} = SignatureAlgorithm.new(raw_alg),
         sig  = sign_info(key, info, alg) do
      struct(__MODULE__, info: info, signature_algorithm: alg, signature: sig)
    end
  end

  defp sign_info(private_key, info, alg) do
    alg_name = SignatureAlgorithm.name(alg)
    der_encoded_info = :public_key.der_encode(:CertificationRequestInfo, Info.to_record(info))
    :public_key.sign(der_encoded_info, alg_name, private_key)
  end

  def fetch(fields, field) do
    case Keyword.fetch(fields, field) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, field}
    end
  end

  # def update(struct, fields) do
  #   struct(struct, Enum.map(fields, &{elem(&1,0), clean(&1)}))
  # end

  @doc """
  Tests for basic invariants
  """
  def valid?() do
    :ok
  end

  @doc """
  """
  def to_pkix() do
    ""
  end

end
