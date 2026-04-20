class SitemapsController < ApplicationController
  def refresh
    return head :unauthorized unless params[:key] == ENV["SITEMAP_SECRET"]

    system("bundle exec rake sitemap:refresh RAILS_ENV=#{Rails.env}")
    
    render plain: "ok"
  end
end