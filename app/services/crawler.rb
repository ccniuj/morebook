class Crawler
  require 'nokogiri'
  require 'mechanize'
  require 'watir-webdriver'
  require 'open-uri'
  require 'redis'
  
  @@QUEUE_NAME = :url_queue
  @@CSS = '#item > tbody > tr > td:nth-child(4) > a,.pagelinks > a:nth-last-of-type(2)'
  @@REDIS = Redis.new
  @@fresh_key = '7XRD78FQ18Y8MNERSVXUIAMJ21CBIJ9V6P1NRHC7US85XIT959-04415'
  @@nthu_lib_query_url = "http://webpac.lib.nthu.edu.tw/F/#{@@fresh_key}?func=find-b&find_code=WAN&request="
  @@books_query_url = "http://search.books.com.tw/exep/prod_search.php?key="

  def initialize
  end

  def crawl_example
    Signal.trap('INT') { $exit = true }; Signal.trap('TERM'){ $exit = true }
    loop do
      sleep 1 until url = @@REDIS.lpop(@@QUEUE_NAME) || $exit
      exit if $exit
      uri = URI(url).tap(&:normalize!)
      puts "POP:  #{uri}"
      begin
        doc = Nokogiri::HTML(open(uri))
        @@REDIS.set "page:#{uri}", doc
        links = doc.css(@@CSS).map{|anchor| uri.merge(anchor['href']) }
        links.each{|link| @@REDIS.rpush @@QUEUE_NAME, link; puts "PUSH: #{link}" }
      rescue
        puts $!.inspect, $@
        @@REDIS.rpush @@QUEUE_NAME, url
      end
    end
  end

  def watir_webdriver(str)
    w = Watir::Browser.new :firefox 
    w.goto "#{@@nthu_lib_query_url}#{str}"
    text = w.html 
    w.close

    doc = Nokogiri::HTML.parse(text)
    result = doc.css('.brieftit').children.to_s
  end

  def books_search(str)
    pages = 2
    count = 0
    urls = []
    urls.push(@@books_query_url + str)
    results = []

    while urls.any?
      break if pages == count
      doc = Nokogiri::HTML(open(urls.shift))
      next_page_url = doc.css('a.nxt')[0]['href'] if doc.css('a.nxt')[0]
      urls.push(next_page_url)
  
      entries = doc.css('li.item > a[rel="mid_image"]')
      entries.each do |entry|
        e = { :product_id => entry['href'].scan(/[0-9]{10}/),
              :title => entry['title'],
              :href => entry['href'],
              :cover_url => image_url_resize(entry.css('img.itemcov').first['data-original'], 500, 500)
              }
        (results << e) if e[:product_id].any?
      end
      count += 1
    end
    results
  end

  def get_book_info(url)
    doc = Nokogiri::HTML(open(url))
    
    name = doc.css('h1').children.text.strip
    author = doc.css('li:contains("作者") a').children[3].text.strip if doc.css('li:contains("作者") a').children[3]
    publisher = doc.css('li:contains("出版社") a span').children.text.strip
    publish_date = doc.css('li:contains("出版日期")').children.text.strip.scan(/\d/).join.to_time
    language = doc.css('li:contains("語言")').children.text.strip
    description = doc.css('div.mod_b h3:contains("內容簡介") +div div.content')[0].to_s
    isbn = doc.css('.bd ul li meta')[0]['content'].scan(/[0-9]{13}/)[0] if doc.css('.bd ul li meta')[0]
    page = doc.css('.bd ul li')[2].children.text.strip.scan(/[0-9]{3}/)[0] if doc.css('.bd ul li')[2]
    name_en = doc.css('h2 a').last.children.text.strip if doc.css('h2 a').last
    author_en = doc.css('li:contains("原文作者") a').children.text.strip
    author_intro = doc.css('div.mod_b h3:contains("作者介紹") +div div.content')[0].to_s
    outline = doc.css('div.mod_b h3:contains("目錄") +div div.content')[0].to_s
    review = doc.css('div.mod_b h3:contains("序") +div div.content')[0].to_s 
    cover_url = doc.css('img.cover')[0]['src'] if doc.css('img.cover').any?

    result = {
      :name => name,
      :author => author,
      :publisher => publisher,
      :publish_date => publish_date,
      :language => language,
      :description => description,
      :isbn => isbn,
      :page => page,
      :name_en => name_en,
      :author_en => author_en,
      :author_intro => author_intro,
      :outline => outline,
      :review => review,
      :cover_url => cover_url
    }
  end

  private
  def image_url_resize(url, width, height)
    unless url.empty?
      url = url.scan(/.+\.[a-z]{3}/).first
      url = url + "&w=#{width}&h=#{height}"
    end
  end
end
