AWS.config(:access_key_id => APP_CONFIG["aws"]["access_key_id"],
  :secret_access_key => APP_CONFIG["aws"]["secret_access_key"])

require 'json'

module Tantrum
  class StorageService
    def self.save(client, content, extension)
      s3 =  AWS::S3.new
    
      bucket = s3.buckets[client]
      unless(bucket.exists?)
        bucket = s3.buckets.create(client)
      end
      key = SecureRandom.uuid
      content_key = key + "#{extension}"
      info = create_info(content, content_key, extension)
      
      content_obj = bucket.objects[content_key]
      content_obj.write(content)
      
      info_key = key + ".info"
      info_obj = bucket.objects[info_key]
      info_obj.write(info.to_json)
      content_key
    end
    
    def self.get(client, content_key)
      s3 = AWS::S3.new
      bucket = s3.buckets[client]
      obj = bucket.objects[content_key]
      content_type = get_content_type(content_key)
      { content: obj.read, content_type: content_type }
    end
    
    def self.create_info(content, content_key, extension)
      mime_type = MIME::Types.type_for(content_key)
      info = {extension: extension, content_type: get_content_type(content_key) }
    end
    
    def self.get_content_type(content_key)
      mime_type = MIME::Types.type_for(content_key)
      mime_type.first.content_type
    end
  end
end