class Shizen < ApplicationRecord
    belongs_to :user
    has_many :likes, dependent: :destroy
    has_many :liked_users, through: :likes, source: :user
    has_many :comments, dependent: :destroy
    scope :sort_good, ->{order(like: :desc)}
    scope :sort_new, ->{order(created_at: :desc)}
    scope :sort_old, ->{order(created_at: :asc)}
    has_one_attached :tategazou
    has_one_attached :tategazou2
    has_one_attached :yokogazou
    has_one_attached :yokogazou2
    before_create :refresh_hourly_weather!
    validate :maplink_must_not_be_short_google_url
  
private

  def refresh_hourly_weather!
    result = WeatherFetcher.fetch_next_hour(latitude, longitude)
    return false if result.nil?

    update!(
    hourly_weather_type: result[:weather_type],
    hourly_weather_at: result[:weather_at],
    hourly_weather_checked_at: Time.current
    )
  end

  def maplink_must_not_be_short_google_url
    return if maplink.blank?

    if maplink.include?("maps.app.goo.gl")
      errors.add(:maplink, "短縮URLではなく、Google Mapsの通常URLを貼ってください")
    end
  end
end