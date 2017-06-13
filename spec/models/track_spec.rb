require 'rails_helper'
require 'sidekiq/testing'

describe Track do
  before do
    Sidekiq::Testing.fake!
  end

  it 'gets the local path' do
    track = Track.new audio_file_name: 'http://s3.amazonaws.com/streampusher/doo.mp3'
    allow(track).to receive(:local_directory) { ::Rails.root.join('tmp/datafruits').to_s }
    expect(track.local_path).to eq ::Rails.root.join('tmp/datafruits/doo.mp3').to_s
  end

  describe "labels" do
    it "adds a label" do
      params = {
                 audio_file_name: 'http://s3.amazonaws.com/streampusher/doo.mp3',
                 labels_attributes: [{ name: "Vaporwave", radio_id: 1 }, { name: "Garage", radio_id: 1 }],
                 radio_id: 1
               }

      track = Track.create params
      expect(track.labels.first.name).to eq "Vaporwave"
    end
  end

  describe "s3_filepath" do
    it "works with both kinds of s3 urls" do
      track = Track.new audio_file_name: "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/datafruits/datafruits-mcfiredrill-09-12-2015-silence-removed.mp3"
      expect(track.s3_filepath).to eq "datafruits/datafruits-mcfiredrill-09-12-2015-silence-removed.mp3"
      track = Track.new audio_file_name: "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/datafruits/datafruits-mcfiredrill-09-12-2015-silence-removed.mp3"
      expect(track.s3_filepath).to eq "datafruits/datafruits-mcfiredrill-09-12-2015-silence-removed.mp3"
    end
  end
end
