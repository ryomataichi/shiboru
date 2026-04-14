require "net/http"
require "json"
require "uri"
require "openssl"
require "time"

class WeatherFetcher
  FORECAST_URL = "https://api.open-meteo.com/v1/forecast".freeze
  def self.fetch_current(latitude, longitude)
    return nil if latitude.blank? || longitude.blank?

    uri = URI(
      "#{FORECAST_URL}?latitude=#{latitude}" \
      "&longitude=#{longitude}" \
      "&current=weather_code" \
      "&timezone=Asia%2FTokyo"
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    code = data.dig("current", "weather_code")
    return nil if code.nil?

    classify_weather(code)
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.error("WeatherFetcher SSL error: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("WeatherFetcher current error: #{e.message}")
    nil
  end

  def self.fetch_next_hour(latitude, longitude)
    return nil if latitude.blank? || longitude.blank?

    uri = URI(
      "#{FORECAST_URL}?latitude=#{latitude}" \
      "&longitude=#{longitude}" \
      "&hourly=weather_code" \
      "&forecast_hours=24" \
      "&timezone=Asia%2FTokyo"
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    times = data.dig("hourly", "time")
    codes = data.dig("hourly", "weather_code")
    return nil if times.blank? || codes.blank?

    now = Time.current.beginning_of_hour

    pair = times.zip(codes).find do |time_str, _code|
      Time.zone.parse(time_str) >= now
    end
    return nil if pair.nil?

    {
      weather_type: classify_weather(pair[1]),
      weather_at: Time.zone.parse(pair[0])
    }
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.error("WeatherFetcher SSL error: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("WeatherFetcher hourly error: #{e.message}")
    nil
  end

  def self.classify_weather(code)
    case code
    when 0
      "sunny"
    when 1, 2, 3, 45, 48
      "cloudy"
    when 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99
      "rainy"
    else
      "cloudy"
    end
  end
end