xml.instruct!
xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url do
    xml.loc root_url
    xml.changefreq 'weekly'
  end
  
  xml.url do
    xml.loc about_url
    xml.changefreq 'weekly'
  end
end
