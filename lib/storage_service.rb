AWS.config(:access_key_id => APP_CONFIG["aws"]["access_key_id"],
  :secret_access_key => APP_CONFIG["aws"]["secret_access_key"])
require 'time'

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
    
    def self.get(client, resource_key, extension)
      bucket = @@s3.buckets[client]
      content_key = resource_key + "." + extension
      content = bucket.objects[content_key]
      info = bucket.objects[resource_key + ".info"]
      content_type = get_content_type(content_key)
      mod_at = get_modified_at(info)
      e_tag = resource_key + mod_at.to_i.to_s
      [content.read, content_type, e_tag, mod_at]
    end
    
    private
    
    def self.create_info(filename)
      mime_type = MIME::Types.type_for(filename)
      info = {original_filename: filename, content_type: get_content_type(filename), created_at: Time.now.utc, modified_at: Time.now.utc }
    end
    
    def self.get_content_type(content_key)
      mime_type = MIME::Types.type_for(content_key)
      mime_type.first.content_type
    end
    
    def self.get_modified_at(info)
      mod_at = JSON.parse(info.read)["modified_at"]
      Time.parse(mod_at)
    end
  end
end