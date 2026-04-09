class RefreshHourlyWeatherJob < ApplicationJob
  queue_as :default

  def perform
    Shizen.find_each do |shizen|
      next if shizen.latitude.blank? || shizen.longitude.blank?

      result = WeatherFetcher.fetch_next_hour(shizen.latitude, shizen.longitude)
      next if result.nil?

      shizen.update(
        hourly_weather_type: result[:weather_type],
        hourly_weather_at: result[:weather_at],
        hourly_weather_checked_at: Time.current
      )
    end
  end
end
