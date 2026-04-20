class SitemapsController < ApplicationController
  def refresh
    return head :unauthorized unless params[:key] == ENV["SITEMAP_SECRET"]

    SitemapGenerator::Sitemap.refresh
    render plain: "ok"
  end
end