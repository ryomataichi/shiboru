class CreateShizens < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:shizens)
      create_table :shizens do |t|
        t.string :spot_name
        t.text :setumei
        t.string :ken
        t.string :maplink
        t.float :latitude, precision: 10, scale: 6
        t.float :longitude, precision: 10, scale: 6
        t.string :hourly_weather_type
        t.datetime :hourly_weather_at
        t.datetime :hourly_weather_checked_at
        t.timestamps
      end
    end
  end
end
