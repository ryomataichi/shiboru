class SitemapsController < ApplicationController
  def refresh
    return head :unauthorized unless params[:key] == ENV["SITEMAP_SECRET"]

    success = system("bundle exec rake sitemap:refresh RAILS_ENV=#{Rails.env} > /dev/null 2>&1")

    if success
      head :ok
    else
      head :internal_server_error
    end
  end
end