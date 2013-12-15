AWS.config(:access_key_id => APP_CONFIG["aws"]["access_key_id"],
  :secret_access_key => APP_CONFIG["aws"]["secret_access_key"])

module Tantrum
  class StorageService
    @@s3 =  AWS::S3.new
    
    def self.save(client, content, filename)
      bucket = @@s3.buckets[client]
      
      extension = File.extname(filename)
      key = SecureRandom.uuid
      content_key = key + "#{extension}"
      info = create_info(filename)
      
      content_obj = bucket.objects[content_key]
      content_obj.write(content)
      
      info_key = key + ".info"
      info_obj = bucket.objects[info_key]
      info_obj.write(info.to_json)
      content_key
    end
    
    def self.get(client, content_key)
      bucket = @@s3.buckets[client]
      obj = bucket.objects[content_key]
      content_type = get_content_type(content_key)
      [obj.read, content_type]
    end
    
    private
    
    def self.create_info(filename)
      mime_type = MIME::Types.type_for(filename)
      info = {original_filename: filename, content_type: get_content_type(filename) }
    end
    
    def self.get_content_type(content_key)
      mime_type = MIME::Types.type_for(content_key)
      mime_type.first.content_type
    end
  end
end