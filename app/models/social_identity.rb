class SocialIdentity < ActiveRecord::Base
  belongs_to :user
  belongs_to :radio

  def self.find_with_omniauth(auth)
    self.find_by(uid: auth['uid'], provider: auth['provider'])
  end

  def self.create_with_omniauth(auth, user_id)
    provider = auth['provider']
    case provider
    when 'facebook'
      name = "#{auth['extra']['raw_info']['first_name']} #{auth['extra']['raw_info']['last_name']}"
    when 'twitter'
      # check auth.extra.raw_info.errors.any?
      name = "@#{auth['info']['nickname']}"
    when 'soundcloud', 'mixcloud', 'tumblr'
      name = auth.info.nickname
    end
    token = auth['credentials']['token']
    token_secret = auth['credentials']['secret']

    self.create(uid: auth['uid'].to_s, provider: auth['provider'].to_s,
           name: name.to_s, token: token, token_secret: token_secret,
           user_id: user_id)
  end
end
