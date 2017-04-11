# defmodule Regent.OpenSSL.Port do
#
#   @port_opts ~w"stream use_stdio eof exit_status hide stderr_to_stdout binary"a
#
#   def run(bin, args) do
#     Port.open({:spawn_executable, bin}, [args: args] ++ @port_opts)
#   end
#
#
#
# end
#
# defmodule Regent.OpenSSL do
#   require Logger
#
#   @commands ~w"gensa x509"a
#
#   def openssl_binary() do
#     with {:ok, opts} <- Application.fetch(:regent_pki, Regent),
#          {:ok, path} <- Keyword.fetch(opts, :openssl_path), do
#       path
#     else
#       :error -> System.get_env("OPENSSL") || System.find_executable("openssl") || :error
#     end
#   end
#
# end
#
# defmodule Regent.OpenSSL.Config do
#
#   defmodule CASection do
#     defstruct default_days: 365,
#               default_crl_days: 30,
#               default_md: :sha1,
#               policy: :policy_any,
#               email_in_dn: false,
#               name_opt: :ca_default,
#               cert_opt: :ca_default,
#               copy_extensions: nil
#   end
#
#   defmodule CertificateExtension do
#     @type extension_value(value) :: {:critical, value} | value | String.t | nil
#
#     @type t :: %__MODULE__{
#       basicConstraints: extension([ca: boolean, path: integer]),
#       keyUsage: extension([ :digitalSignature | :nonRepudiation |
#                   :keyEncipherment | :dataEncipherment | :keyAgreement |
#                   :keyCertSign | :cRLSign | :encipherOnly | :decipherOnly ])
#       extendedKeyUsage: extension([ :serverAut | :clientAuth | :codeSigning |
#                           :emailProtection | :timeStamping | :OCSPSigning |
#                           :ipsecIKE | :msCodeInd | :msCodeCom | :msCTLSign |
#                           :msEFS ])
#       authorityKeyIdentifier: extension([keyid: :always, issuer: :always]),
#       subkeyKeyIdentifier: extension(:hash, string),
#       subjectAltName: String.t,
#       issuerAltName: String.t,
#       crlDistributionPoints: [term],
#       issuingDistributionPoint: nil,
#       certificatePolicies: nil
#     }
#
#     defstruct basicConstraints: nil,
#               keyUsage: nil,
#               extendedKeyUsage: nil
#               authorityKeyIdentifier: nil,
#               subkeyKeyIdentifier: nil,
#               subjectAltName: nil,
#               issuerAltName: nil,
#               crlDistributionPoints: nil,
#               issuingDistributionPoint: nil,
#               certificatePolicies: nil,
#               policyConstraints: nil,
#               inhibitAnyPolicy: nil,
#               nameConstraints: nil,
#               noCheck: nil,
#               tlsfeature: nil
#
#
#
#   end
#
#   defmodule Policy do
#     @type policy_opt :: :supplied | :optional
#     @type t :: %Policy{
#       countryName: policy_opt,
#       stateOrProvinceName: policy_opt,
#       organizationName: policy_opt,
#       organizationalUnitName: policy_opt,
#       commonName: policy_opt,
#       emailAddress: policy_opt
#     }
#     defstruct countryName: :supplied,
#               stateOrProvinceName: :optional,
#               :organizationName: :optional,
#               organizationalUnitName: :optional,
#               commonName: :supplied,
#               emailAddress: :optional
#   end
#
#   alias __MODULE__.{CASection, CertificateExtension, Policy}
#
#   def gen_config() do
#
#   end
#
# end
