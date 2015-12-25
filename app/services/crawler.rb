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

  def search(str)
    doc = Nokogiri::HTML(open(@@books_query_url + str))
    links = doc.css('li.item h3 a')
    result = {}
    links.each do |link|
      result[link['title']] = URI.decode(link['href'])
    end
    result
  end
end
