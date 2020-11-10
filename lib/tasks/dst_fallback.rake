desc 'fall back scheduled show times for DST'
task :dst_fallback => :environment do
  radio = Radio.find_by name: ENV['RADIO']
  DstFallBackWorker.perform_now radio
end
