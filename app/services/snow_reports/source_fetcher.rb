require "digest"
require "http"
require "ipaddr"
require "resolv"
require "uri"

module SnowReports
  class SourceFetcher
    MAX_RAW_TEXT_BYTES = 1.megabyte
    USER_AGENT = "SnowwiseConditionsBot/1.0 (+https://github.com/hast-zing-psec-rhon/snowwise)"

    PRIVATE_NETWORKS = [
      IPAddr.new("0.0.0.0/8"),
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("127.0.0.0/8"),
      IPAddr.new("169.254.0.0/16"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
      IPAddr.new("::1/128"),
      IPAddr.new("fc00::/7"),
      IPAddr.new("fe80::/10")
    ].freeze

    def call(snow_report_source:)
      fetched_at = Time.current
      source_uri = validated_source_uri!(snow_report_source.source_url)

      response = HTTP
        .headers("User-Agent" => USER_AGENT)
        .timeout(connect: 5, read: 20)
        .follow(max_hops: 3)
        .get(source_uri.to_s)

      response_body = response.body.to_s
      raw_text = response_body.byteslice(0, MAX_RAW_TEXT_BYTES)

      SnowSourceFetch.create!(
        snow_report_source: snow_report_source,
        fetched_at: fetched_at,
        http_status: response.status.to_i,
        content_type: response.content_type.to_s,
        response_sha256: Digest::SHA256.hexdigest(response_body),
        raw_text: raw_text
      )
    rescue HTTP::Error, SocketError, Timeout::Error, URI::InvalidURIError, SecurityError, Resolv::ResolvError => error
      SnowSourceFetch.create!(
        snow_report_source: snow_report_source,
        fetched_at: fetched_at,
        error_message: error.message
      )
    end

    private

    def validated_source_uri!(url)
      uri = URI.parse(url.to_s)
      raise SecurityError, "Unsupported snow report URL scheme" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise SecurityError, "Snow report URL must include a host" if uri.host.blank?
      raise SecurityError, "Snow report URL must not include credentials" if uri.userinfo.present?

      addresses = Resolv.getaddresses(uri.host)
      raise SecurityError, "Snow report URL host did not resolve" if addresses.empty?

      addresses.each do |address|
        ip_address = IPAddr.new(address)
        if PRIVATE_NETWORKS.any? { |network| network.include?(ip_address) }
          raise SecurityError, "Snow report URL resolves to a private network"
        end
      end

      uri
    end
  end
end
