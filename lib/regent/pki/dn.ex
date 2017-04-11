defmodule Regent.PKI.DN do
  @moduledoc false

  alias Regent.Records, as: R
  import Regent.Asn1
  require R

  @short_names %{
    name:                   oid(:"id-at-name"),
    surname:                oid(:"id-at-surname"),
    givenName:              oid(:"id-at-givenName"),
    initials:               oid(:"id-at-initials"),
    generationQualifier:    oid(:"id-at-generationQualifier"),

    commonName:             oid(:"id-at-commonName"),

    localityName:           oid(:"id-at-localityName"),
    stateOrProvinceName:    oid(:"id-at-stateOrProvinceName"),
    organizationName:       oid(:"id-at-organizationName"),
    organizationalUnitName: oid(:"id-at-organizationalUnitName"),
    countryName:            oid(:"id-at-countryName"),

    title:                  oid(:"id-at-title"),

    dnQualifier:            oid(:"id-at-dnQualifier"),
    serialNumber:           oid(:"id-at-serialNumber"),
    pseudonym:              oid(:"id-at-pseudonym"),
    domainComponent:        oid(:"id-domainComponent"),

    emailAddress:           oid(:"id-emailAddress"),

    CN:                     oid(:"id-at-commonName"),
    L:                      oid(:"id-at-localityName"),
    ST:                     oid(:"id-at-stateOrProvinceName"),
    O:                      oid(:"id-at-organizationName"),
    OU:                     oid(:"id-at-organizationalUnitName"),
    C:                      oid(:"id-at-countryName"),
    DC:                     oid(:"id-domainComponent")
  }
  # Convenience function for DN types...

  # :"OTP-PUB-KEY".encode(:Name, {:rdnSequence, [
  #   [{:AttributeTypeAndValue, {2, 5, 4, 3},
  #     :public_key.der_encode(:X520CommonName, {:utf8String, 'Common Name'})}],
  #   [{:AttributeTypeAndValue, {2, 5, 4, 6},
  # .   :public_key.der_encode(:X520name, {:utf8String, 'US'})}]
  # ]})

  def attr(attr, value) do
    attr_oid = attr_to_oid(attr)
    attr_value = validate(attr, value)
    {:ok, new_value} = encode(attr_oid, attr_value)
    attr_rec = R.attr(type: attr_oid, value: new_value)
    [attr_rec]
  end

  defp attr_to_oid(attr) when is_tuple(attr), do: attr
  defp attr_to_oid(attr) when is_atom(attr) do
    case Map.fetch(@short_names, attr) do
      {:ok, oid} -> oid
      :error -> oid(attr)
    end
  end

  defp validate(_, bin) when is_binary(bin) do
    {:utf8String, bin}
  end

  def sequence(attrs) do
    attr_records = for {type, value} <- attrs, do: attr(type, value)
    {:rdnSequence, attr_records}
  end

  def get_supported_attributes, do: unquote(Map.keys(@short_names))

  def encode(id, attr), do: :"OTP-PUB-KEY".encode(enc_name(id), attr)

  defp enc_name(tuple) when is_tuple(tuple) do
    [name] = name(tuple)
    enc_name(name)
  end
  defp enc_name(:"id-at-name"), do: :X520name
  defp enc_name(:"id-at-surname"), do: :X520name
  defp enc_name(:"id-at-givenName"), do: :X520name
  defp enc_name(:"id-at-initials"), do: :X520name
  defp enc_name(:"id-at-generationQualifier"), do: :X520name
  defp enc_name(:"id-at-commonName"), do: :X520CommonName
  defp enc_name(:"id-at-localityName"), do: :X520LocalityName
  defp enc_name(:"id-at-stateOrProvinceName"), do: :X520StateOrProvinceName
  defp enc_name(:"id-at-organizationName"), do: :X520OrganizationName
  defp enc_name(:"id-at-organizationalUnitName"), do: :X520OrganizationalUnitName
  defp enc_name(:"id-at-title"), do: :X520Title
  defp enc_name(:"id-at-dnQualifier"), do: :X520dnQualifier
  defp enc_name(:"id-at-countryName"), do: :"OTP-X520countryname"
  defp enc_name(:"id-at-serialNumber"), do: :X520SerialNumber
  defp enc_name(:"id-at-pseudonym"), do: :X520Pseudonym
  defp enc_name(:"id-domainComponent"), do: :DomainComponent
  defp enc_name(:"id-emailAddress"), do: :EmailAddress

end
