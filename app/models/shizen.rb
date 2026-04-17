class Shizen < ApplicationRecord
    belongs_to :user
    has_many :likes, dependent: :destroy
    has_many :liked_users, through: :likes, source: :user
    has_many :comments, dependent: :destroy
    scope :sort_good, ->{order(like: :desc)}
    scope :sort_new, ->{order(created_at: :desc)}
    scope :sort_old, ->{order(created_at: :asc)}
    has_many_attached :images
    before_create :refresh_hourly_weather!
    validates :spot_name, presence: true
  def refresh_hourly_weather!
    result = WeatherFetcher.fetch_next_hour(latitude, longitude)
    return false if result.nil?

    update!(
    hourly_weather_type: result[:weather_type],
    hourly_weather_at: result[:weather_at],
    hourly_weather_checked_at: Time.current
    )
  end

end