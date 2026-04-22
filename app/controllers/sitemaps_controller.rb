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

  def show
    path = Rails.root.join("public", "sitemap.xml.gz")

    unless File.exist?(path)
      system("bundle exec rake sitemap:refresh RAILS_ENV=#{Rails.env} > /dev/null 2>&1")
    end

    if File.exist?(path)
      send_file path, type: "application/gzip", disposition: "inline"
    else
      render plain: "sitemap not found", status: :not_found
    end
  end
end