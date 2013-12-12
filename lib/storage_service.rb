AWS.config(:access_key_id => APP_CONFIG["aws"]["access_key_id"],
  :secret_access_key => APP_CONFIG["aws"]["secret_access_key"])
  
module Tantrum
  class StorageService
    def self.save(client, content, extension)
      s3 =  AWS::S3.new
    
      bucket = s3.buckets[client]
      unless(bucket.exists?)
        bucket = s3.buckets.create(client)
      end
    
      key = SecureRandom.uuid + "#{extension}"
      obj = bucket.objects[key]
      obj.write(content)
      key
    end
  
    def self.get(client, content_key)
      s3 = AWS::S3.new
      bucket = s3.buckets[client]
      obj = bucket.objects[content_key]
      obj.read
    end
  end
end