namespace :tantrum do
  desc 'Tantrum tasks'
  
  task :test_task do |t, args|
      s3 = AWS::S3.new
      bucket = s3.buckets['sparvagenfriidrott']
      keys = []
      bucket.objects.each do |obj|
        unless(obj.key.end_with?(".info") || obj.key.downcase.end_with?(".jpg") || obj.key.downcase.end_with?(".gif") || obj.key.downcase.end_with?(".png") || obj.key.downcase.end_with?(".jpeg") || obj.key.downcase.end_with?(".bmp"))
          keys << obj.key.split('.')[0]
        end
      end
      puts "Length => #{keys.count}"
      json = "{";

      keys.each do |key|
        begin
          obj = bucket.objects[key + ".info"]
          json += '"' + key + '":' + obj.read
        rescue Exception => e
          puts "Error for file => #{key}"
          puts e.message
          puts e.backtrace.inspect
        end
      end
      json += "}"
      puts json
  end
end