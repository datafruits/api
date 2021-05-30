require 'rails_helper'

describe ScheduleMonitor do
  before :each do
    Redis.current = MockRedis.new
  end
  let(:radio){ FactoryBot.create :radio }
  let(:playlist) { FactoryBot.create :playlist, radio: radio }
  let(:show){ FactoryBot.create :scheduled_show }
  let(:dj){ FactoryBot.create :user }
  # let(:liquidsoap_socket_class){ class_double("Liquidsoap::Socket") }
  # let(:liquidsoap_socket){ instance_double("Liquidsoap::Socket") }
  let(:liquidsoap_requests) { class_double("LiquidsoapRequests").as_stubbed_const }
  # xit "issues a skip if a show is scheduled and is not currently playing" do
  #   scheduled_show = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
  #     start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 2nd 2090 at 01:30 am")
  #   Timecop.travel Chronic.parse("January 1st 2090 at 11:30 pm") do
  #     allow(liquidsoap_socket_class).to receive(:new).with("/tmp/datafruits/liquidsoap.sock").and_return(liquidsoap_socket)
  #     expect(liquidsoap_socket).to receive(:write).with("icecast.1.skip")
  #     ScheduleMonitor.perform radio, Time.now, liquidsoap_socket_class
  #   end
  # end

  # xit "doesn't issue a skip if a show is scheduled and is already playing" do
  #   scheduled_show = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
  #     start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 2nd 2090 at 01:30 am")
  #   radio.set_current_show_playing scheduled_show.id
  #   Timecop.travel Chronic.parse("January 1st 2090 at 11:30 pm") do
  #     allow(liquidsoap_socket_class).to receive(:new).with("/tmp/datafruits/liquidsoap.sock").and_return(liquidsoap_socket)
  #     expect(liquidsoap_socket).not_to receive(:write).with("icecast.1.skip")
  #     ScheduleMonitor.perform radio, Time.now, liquidsoap_socket_class
  #   end
  # end

  # xit "doesn't skip if the current show is not over yet and no_cue_out is set on the current show" do
  #   playlist.update no_cue_out: true
  #   scheduled_show = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
  #     start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 2nd 2090 at 01:30 am")
  #   radio.set_current_show_playing scheduled_show.id
  #   Timecop.travel Chronic.parse("January 1st 2090 at 11:30 pm") do
  #     allow(liquidsoap_socket_class).to receive(:new).with("/tmp/datafruits/liquidsoap.sock").and_return(liquidsoap_socket)
  #     expect(liquidsoap_socket).not_to receive(:write).with("icecast.1.skip")
  #     ScheduleMonitor.perform radio, Time.now, liquidsoap_socket_class
  #   end
  # end
  it "sets current show playing in redis to nil if there is no scheduled show in the db" do
    ScheduleMonitor.perform radio, Time.now
    expect(radio.current_show_playing.blank?).to eq true
  end
  describe "when the next show is due to start playing" do
    it "issues a skip when there is no previous show" do
      scheduled_show = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
        start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 2nd 2090 at 01:30 am"),
        dj: dj
      Timecop.travel Chronic.parse("January 1st 2090 at 10:31 pm") do
        allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
        expect(liquidsoap_requests).to receive(:skip).with(radio)
        # why doesn't this work
        # expect(scheduled_show).to receive(:queue_playlist!)
        ScheduleMonitor.perform radio, Time.now
        expect(radio.current_show_playing.to_i).to eq scheduled_show.id.to_i
      end
    end
    describe "and when the current show is not finished playing" do
      it "adds the playlist from the next show to the queue if the previous show has no_cue_out set to true and doesn't skip" do
        playlist.update no_cue_out: true
        scheduled_show1 = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
          start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 1st 2090 at 11:00 pm"),
          dj: dj
        scheduled_show2 = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
          start_at: Chronic.parse("January 1st 2090 at 11:00 pm"), end_at: Chronic.parse("January 1st 2090 at 11:30 pm"),
          dj: dj
        Timecop.travel Chronic.parse("January 1st 2090 at 10:31 pm") do
          allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
          expect(liquidsoap_requests).to receive(:skip).with(radio)
          # why doesn't this work
          # expect(scheduled_show1).to receive(:queue_playlist!)
          ScheduleMonitor.perform radio, Time.now
        end
        Timecop.travel Chronic.parse("January 1st 2090 at 11:01 pm") do
          allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
          expect(liquidsoap_requests).not_to receive(:skip).with(radio)
          # why doesn't this work
          # expect(scheduled_show2).to receive(:queue_playlist!)
          ScheduleMonitor.perform radio, Time.now
        end
      end
      it "skips to the playlist from the next show if the previous show has no_cue_out set to false" do
        playlist.update no_cue_out: false
        scheduled_show1 = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
          start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 1st 2090 at 11:00 pm"),
          dj: dj
        scheduled_show2 = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
          start_at: Chronic.parse("January 1st 2090 at 11:00 pm"), end_at: Chronic.parse("January 1st 2090 at 11:30 pm"),
          dj: dj
        Timecop.travel Chronic.parse("January 1st 2090 at 10:31 pm") do
          allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
          expect(liquidsoap_requests).to receive(:skip).with(radio)
          # why doesn't this work
          # expect(scheduled_show1).to receive(:queue_playlist!)
          ScheduleMonitor.perform radio, Time.now
        end
        Timecop.travel Chronic.parse("January 1st 2090 at 11:01 pm") do
          allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
          expect(liquidsoap_requests).to receive(:skip).with(radio)
          # why doesn't this work
          # expect(scheduled_show2).to receive(:queue_playlist!)
          ScheduleMonitor.perform radio, Time.now
        end
      end
    end
  end
  describe "when the current show is already playing at its proper time" do
    # how do i test that it does nothing???
    it "does nothing" do
      scheduled_show1 = FactoryBot.create :scheduled_show, playlist: playlist, radio: radio,
        start_at: Chronic.parse("January 1st 2090 at 10:30 pm"), end_at: Chronic.parse("January 1st 2090 at 11:00 pm"),
        dj: dj
      Timecop.travel Chronic.parse("January 1st 2090 at 10:31 pm") do
        allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
        expect(liquidsoap_requests).to receive(:skip).with(radio)
        # why doesn't this work
        # expect(scheduled_show1).to receive(:queue_playlist!)
        ScheduleMonitor.perform radio, Time.now
      end
      Timecop.travel Chronic.parse("January 1st 2090 at 10:45 pm") do
        allow(liquidsoap_requests).to receive(:skip).with(radio).and_return(nil)
        expect(liquidsoap_requests).not_to receive(:skip).with(radio)
        # why doesn't this work
        expect(scheduled_show1).not_to receive(:queue_playlist!)
        ScheduleMonitor.perform radio, Time.now
      end
    end
  end
end
