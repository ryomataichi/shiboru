module ShizensHelper
  def weather_label(weather_type)
    case weather_type
    when "sunny"
      "晴れ"
    when "cloudy"
      "曇り"
    when "rainy"
      "雨"
    else
      "不明"
    end
  end

  def weather_image_name(weather_type)
    case weather_type
    when "sunny"
      "sunny.png"
    when "cloudy"
      "cloudy.png"
    when "rainy"
      "rainy.png"
    else
      "cloudy.png"
    end
  end

  def smart_truncate(spot_name, limit = 10)
    return '' if spot_name.blank?
    stripped = strip_tags(spot_name)
    stripped.length > limit ? stripped[0, limit] + '...' : stripped
  end

  def image_orientation(image)
    width = image.blob.metadata["width"]
    height = image.blob.metadata["height"]

    return "unknown" if width.blank? || height.blank?

    if width > height
      :landscape
    elsif height > width
      :portrait
    else
      :square
    end
  end

end