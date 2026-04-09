require "net/http"
require "uri"
require "cgi"

class MapLinkParser
  def self.extract_coordinates(url)
    return [nil, nil] if url.blank?

    final_url = expand_url(url)
    return [nil, nil] if final_url.blank?

    patterns = [
      /@(-?\d+\.\d+),(-?\d+\.\d+)/,      # .../@35.658034,139.701636,17z
      /!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)/   # ...!3d35.658034!4d139.701636
    ]

    patterns.each do |pattern|
      match = final_url.match(pattern)
      return [match[1].to_f, match[2].to_f] if match
    end

    extract_from_query(final_url)
  rescue StandardError => e
    Rails.logger.error("MapLinkParser error: #{e.message}")
    [nil, nil]
  end

  def self.extract_from_query(url)
    uri = URI.parse(url)
    params = CGI.parse(uri.query.to_s)

    %w[q ll query].each do |key|
      value = params[key]&.first
      next if value.blank?

      if value.match?(/\A-?\d+(\.\d+)?,-?\d+(\.\d+)?\z/)
        lat, lng = value.split(",")
        return [lat.to_f, lng.to_f]
      end
    end

    [nil, nil]
  rescue StandardError => e
    Rails.logger.error("MapLinkParser query parse error: #{e.message}")
    [nil, nil]
  end

  def self.expand_url(url, limit = 5)
    return nil if limit <= 0

    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    case response
    when Net::HTTPRedirection
      location = response["location"]
      return nil if location.blank?
      expand_url(location, limit - 1)
    else
      uri.to_s
    end
  rescue StandardError => e
    Rails.logger.error("MapLinkParser expand_url error: #{e.message}")
    nil
  end
end