require 'rails_helper'
require 'sidekiq/testing'

describe UploadTrackToMixcloud do
  let(:token){ ENV['MIXCLOUD_TOKEN'] }
  xit "uploads a track to mixcloud account" do
    VCR.use_cassette(RSpec.current_example.metadata[:full_description].to_s) do
      track = FactoryBot.create :track, audio_file_name: "https://s3.amazonaws.com/streampushertest/datafruits-ovenrake-12-01-2015.mp3", artwork: File.new("spec/fixtures/images/pineapple.png")
      expect(track.mixcloud_not_uploaded?).to eq true

      expected_response = {"result"=>{"message"=>"Uploaded pineapple rules", "key"=>"/seacuke/pineapple-rules/", "success"=>true}}
      actual_response = UploadTrackToMixcloud.new.perform track, token
      expect(actual_response).to eq expected_response
      expect(track.mixcloud_upload_complete?).to eq true
      expect(track.mixcloud_key).to eq "/seacuke/pineapple-rules/"
    end
  end

  xit "errors if credentials are invalid"
  xit "errors if upload fails"
end
