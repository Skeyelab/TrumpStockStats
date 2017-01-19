class TrumpTweet
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  #include Mongoid::Timestamps

  after_create :scan_tweet_body

  def self.fetch_recent
    twitter.user_timeline("realDonaldTrump", :count => 200, :include_rts => true).each do |tweet|
      tweet_h = tweet.to_hash
      tweet_h[:created_at] = Time.parse(tweet_h[:created_at])
      begin
        TrumpTweet.create(tweet_h)
      rescue Exception => e

      end
    end
  end



  def scan_tweet_body

    filter = Stopwords::Snowball::Filter.new "en"
    filter.stopwords << "u.s."
    filter.stopwords << "great"
    filter.stopwords << "-"
    filter.stopwords << "america"

    intersections = []
    Company.each do |c|
      #binding.pry
      words = filter.filter c.name.downcase.split(" ")
      text_a = text.downcase.split(" ")
      intersection = words & text_a
      if !intersection.empty?
        intersection.each do |int|
          intersections << int
        end
      end

    end
    if !intersections.empty?

      puts intersections.uniq
      puts text
    end
  end
  private

  def self.twitter
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end
    return twitter
  end
end
