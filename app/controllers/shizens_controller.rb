class ShizensController < ApplicationController
    before_action :authenticate_user!, only: [:new, :create]
    def index
        if params[:search] != nil && params[:search] != ''
            search = params[:search]
            @shizens = Shizen.joins(:user).where("ken LIKE ? OR spot_name LIKE ?", "%#{search}%", "%#{search}%")
        elsif params[:new].present?
            @shizens = Shizen.sort_new
        elsif params[:old].present?
            @shizens = Shizen.sort_old      
        elsif params[:good].present?
            @shizens = Shizen.includes(:liked_users).sort {|a,b| b.liked_users.size <=> a.liked_users.size}
        else
            @shizens = Shizen.all
        end
        @sunny_shizens = Shizen.where(hourly_weather_type: "sunny")
    end
    

    def new
        @shizen = Shizen.new
    end
    
    def create
        shizen = Shizen.new(shizen_params)
        shizen.user_id = current_user.id

        if shizen.save
        redirect_to action: "index"
        else
        redirect_to action: "new"       
        end
    end

    def edit
        @shizen = Shizen.find(params[:id])
    end

    def show
        @shizen = Shizen.find(params[:id])
        @comments = @shizen.comments
        @comment = Comment.new
        @weather_type = WeatherFetcher.fetch_current(@shizen.latitude, @shizen.longitude)
    end

    def destroy
        shizen = Shizen.find(params[:id])
        shizen.destroy
        redirect_to action: :index
    end
    
    def update
        shizen = Shizen.find(params[:id])
        update_params = shizen_params

        latitude, longitude = MapLinkParser.extract_coordinates(update_params[:maplink])
        update_params = update_params.merge(latitude: latitude, longitude: longitude)

        if shizen.update(update_params)
            shizen.refresh_hourly_weather! if shizen.latitude.present? && shizen.longitude.present?
            redirect_to action: "show", id: shizen.id
        else
            redirect_to action: "edit", id: shizen.id
        end
    end
    
    def matome
        @shizen = Shizen.find(params[:id])
        if params[:search] != nil && params[:search] != ''
            search = params[:search]
            @shizens = Shizen.joins(:user).where("ken LIKE ? OR spot_name LIKE ?", "%#{search}%", "%#{search}%")
        elsif params[:new].present?
            @shizens = Shizen.sort_new
        elsif params[:old].present?
            @shizens = Shizen.sort_old      
        elsif params[:good].present?
            @shizens = Shizen.includes(:liked_users).sort {|a,b| b.liked_users.size <=> a.liked_users.size}
        else
            @shizens = Shizen.all
        end
        @sunny_shizens = Shizen.where(hourly_weather_type: "sunny")

    end

    def refresh_weather
        return head :unauthorized unless params[:token] == ENV["CRON_SECRET"]

        RefreshHourlyWeatherJob.perform_later
        render plain: "OK"
    end
    private
    def shizen_params
        params.require(:shizen).permit(:tategazou, :tategazou2, :yokogazou, :yokogazou2, :spot_name, :ken, :maplink, :setumei, :latitude, :longitude, :hourly_weather_type, :hourly_weather_at, :hourly_weather_checked_at, images: [])
    end
end
