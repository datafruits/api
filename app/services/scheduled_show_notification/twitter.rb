class ScheduledShowNotification::Twitter
  def self.perform scheduled_show
    twitter_identity = scheduled_show.radio.social_identities.find_by(provider: 'twitter')
    token = twitter_identity.token
    token_secret = twitter_identity.token_secret
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = token
      config.access_token_secret = token_secret
    end

    client.update scheduled_show.tweet_text
  end
end
