class Crawler
  require 'nokogiri'
  require 'mechanize'
  require 'watir-webdriver'
  require 'open-uri'
  require 'redis'
  
  @@QUEUE_NAME = :url_queue
  @@BOOK_URL_QUEUE = :book_url_queue
  @@CSS = '#item > tbody > tr > td:nth-child(4) > a,.pagelinks > a:nth-last-of-type(2)'
  @@REDIS = Redis.new
  @@books_query_url = "http://search.books.com.tw/exep/prod_search.php?key="
  @@trail_id = 6

  def initialize
  end

  def crawl_tags
    url = 'http://www.books.com.tw/web/books'
    anchor = 'h3:contains("中文書書籍分類")+ul '
    general_class_selector = anchor + 'li a'
    current_selector = anchor + 'li.open > span a'
    children_selector = anchor + 'ul.sub li a'
    count = 0
    duration = 0
    threshold = 250
    buffer = 60
    previous_periods = []
    factor = 3

    p 'Crawler initiated.'

    if @@REDIS.llen(@@QUEUE_NAME) == 0
      doc = Nokogiri::HTML(open(url))
      general_classes = doc.css(general_class_selector).map do |a|
                          @@REDIS.rpush @@QUEUE_NAME, a['href']
                          a.children.text
                        end
      root_tag = Tag.create(:name => '中文書')
  
      general_classes.each do |class_name|
        tag = Tag.create(:name => class_name)
        tag.move_to_child_of(root_tag)
      end
    end

    Signal.trap('INT') { $exit = true }; Signal.trap('TERM'){ $exit = true }
  
    while @@REDIS.llen(@@QUEUE_NAME) > 0
      count += 1
      sleep 1 until url = @@REDIS.lpop(@@QUEUE_NAME) || $exit
      exit if $exit
      p "#{'='*20}Trail ##{@@trail_id} Iteration ##{count}#{'='*20}"
      p "POP: #{url}"
      begin
        p 'Fetching page...'
        from = Time.now
        doc = Nokogiri::HTML(open(url))
        period = Time.now - from
        duration += period
        previous_periods.push(period)
        previous_periods.shift if previous_periods.size > factor
  
        p 'Fetching page...done'
        p "Cost #{period} seconds."
  
        current_tag_name = doc.css(current_selector).children.text
        current_tag = Tag.where(:name => current_tag_name)
        p "#{current_tag_name} is the current processing tag."
        children_tags = doc.css(children_selector)
    
        if children_tags.any?
          children_tag_names = children_tags.map do |a|
                                 p 'Push into queue...'
                                 @@REDIS.rpush @@QUEUE_NAME, a['href']
                                 p 'Push into queue...done'
                                 a.children.text
                               end
          children_tag_names.each do |name|
            tag = Tag.create(:name => name)
            tag.move_to_child_of(current_tag)
          end
        end
  
        p "Total duration: #{duration} seconds."
        p "#{@@REDIS.llen(@@QUEUE_NAME)} urls are not visited yet."
  
        CrawlerLog.create(
                :trail_id => @@trail_id,
                :url => url, 
                :tag => current_tag_name,
                :iteration => count,
                :period => period)
      rescue
        puts $!.inspect, $@
        @@REDIS.rpush @@QUEUE_NAME, url
      end

      if previous_periods.all?{|period|period > 6}
        p 'Crawler terminated.'
        t = 0
        while t < buffer
          p "Crawler will restart in #{buffer - t} second(s)."
          t += 1
          sleep 1
        end
      end
    end
    p 'Crawler terminated.'
  end
  
  def book_url_fetch
    results = []
    duration = 0
    previous_periods = []
    factor = 3
    count = 0
    buffer = 60

    leaves_url = Tag.select {|t|t.leaf?}.
                 map! {|l|CrawlerLog.where('trail_id=6').where(tag:l.name).first.url}

    p 'Crawler started to fetch book urls.'

    while leaves_url.any?
      count += 1
      leaf_url = leaves_url.shift
      begin
        p "#{'='*20}Iteration ##{count}#{'='*20}"
        p 'Fetching page...'
      
        from = Time.now
        doc = Nokogiri::HTML(open(leaf_url))
        period = Time.now - from
        duration += period
        previous_periods.push(period)
        previous_periods.shift if previous_periods.size > factor
        
        p 'Fetching page...done'
        p "Cost #{period} seconds."

        urls = doc.css('.item > a').map{|e|e['href']}.first(10)
        results.push(urls)
        urls.each {|u|@@REDIS.rpush(@@BOOK_URL_QUEUE, u)}
      rescue
        puts $!.inspect, $@
        leaves_url.pop(leaf_url)
      end

      p "Total duration: #{duration} seconds."
      p "#{leaves_url.size} urls are not visited yet."

      if previous_periods.all?{|period|period > 6}
        p 'Crawler terminated.'
        t = 0
        while t < buffer
          p "Crawler will restart in #{buffer - t} second(s)."
          t += 1
          sleep 1
        end
      end
    end
    p 'Crawler terminated.'
    results.flatten!
  end

  def fetch_book_data
    results = []
    duration = 0
    previous_periods = []
    factor = 3
    count = 0
    buffer = 60

    urls = @@REDIS.lrange(@@BOOK_URL_QUEUE, 0, -1).uniq

    p 'Crawler started to fetch book data.'

    while urls.any?
      count += 1
      url = urls.shift
      begin
        p "#{'='*20}Iteration ##{count}#{'='*20}"
        p 'Fetching page...'
      
        from = Time.now
        data = get_book_info(url)
        ap data
        Book.add_book_to_db(data)
        period = Time.now - from
        duration += period
        previous_periods.push(period)
        previous_periods.shift if previous_periods.size > factor
        
        p 'Fetching page...done'
        p "Cost #{period} seconds."
      rescue
        puts $!.inspect, $@
        urls.push(url)
      end

      p "Total duration: #{duration} seconds."
      p "#{urls.size} urls are not visited yet."

      if previous_periods.all?{|period|period > 6}
        p 'Crawler terminated.'
        t = 0
        while t < buffer
          p "Crawler will restart in #{buffer - t} second(s)."
          t += 1
          sleep 1
        end
      end
    end
    p 'Crawler terminated.'
    true
  end

  def export_data
    save_path = Rails.root.join('public','crawler_logs',"trail_#{@@trail_id}.tsv")
    output = File.open(save_path, 'w')
    output << "iteration\tperiod\n"

    CrawlerLog.where(:trail_id => @@trail_id).all.each do |log|
      output << "#{log.iteration}\t#{log.period}\n"
    end

    output.close
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
    begin
      doc = Nokogiri::HTML(open(url))
    rescue
      puts $!.inspect, $@
    end

    name         = doc.css('h1').children.text.strip
    tag          = doc.css('ul.type04_breadcrumb li:nth-last-child(2) a span').children.text
    author       = doc.css('li:contains("作者") a').children[3].text.strip if doc.css('li:contains("作者") a').children[3]
    publisher    = doc.css('li:contains("出版社") a span').children.text.strip
    publish_date = doc.css('li:contains("出版日期")').children.text.strip.scan(/\d/).join.to_time
    language     = doc.css('div.grid_10 li:contains("語言")').children.text.strip.scan(/\：(.+)/)[0][0]
    description  = doc.css('div.mod_b h3:contains("內容簡介") +div div.content')[0].to_s
    isbn         = doc.css('.bd ul li:contains("ISBN")').children.text.strip.scan(/[0-9]{10,13}/)[0]
    page         = doc.css('.bd ul li')[2].children.text.strip.scan(/[0-9]{3}/)[0] if doc.css('.bd ul li')[2]
    name_en      = doc.css('h2 a').last.children.text.strip if doc.css('h2 a').last
    author_en    = doc.css('li:contains("原文作者") a').children.text.strip
    author_intro = doc.css('div.mod_b h3:contains("作者介紹") +div div.content')[0].to_s
    outline      = doc.css('div.mod_b h3:contains("目錄") +div div.content')[0].to_s
    review       = doc.css('div.mod_b h3:contains("序") +div div.content')[0].to_s 
    cover_url    = doc.css('img.cover')[0]['src'] if doc.css('img.cover').any?

    result = {
      :name         => name,
      :tag          => tag,
      :author       => author,
      :publisher    => publisher,
      :publish_date => publish_date,
      :language     => language,
      :description  => description,
      :isbn         => isbn,
      :page         => page,
      :name_en      => name_en,
      :author_en    => author_en,
      :author_intro => author_intro,
      :outline      => outline,
      :review       => review,
      :cover_url    => cover_url
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
