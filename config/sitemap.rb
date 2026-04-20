SitemapGenerator::Sitemap.default_host = "https://shiboru-test.onrender.com" # 自分のドメインに変更

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: "daily", priority: 1.0
  add shizens_path, changefreq: "daily", priority: 0.9

  Shizen.find_each do |shizen|
    add shizen_path(shizen),
      lastmod: shizen.updated_at,
      changefreq: "weekly",
      priority: 0.8
  end

  User.find_each do |user|
    add user_path(user),
      lastmod: user.updated_at,
      changefreq: "weekly",
      priority: 0.5
  end
end