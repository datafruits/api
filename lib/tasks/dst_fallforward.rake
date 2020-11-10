desc 'fall forward scheduled show times for DST'
task :dst_fallforward => :environment do
  radio = Radio.find_by name: ENV['RADIO']
  DstFallForwardWorker.perform_now radio
end
