Aws.config.update({
  region: 'eu-west-1',
  credentials: Aws::Credentials.new(APP_CONFIG["aws"]["access_key_id"], APP_CONFIG["aws"]["secret_access_key"])
})

require 'time'
require 'digest/sha1'

module Tantrum
  class StorageService
    @@s3 = Aws::S3::Resource.new

    def self.save(client, content, filename)
      bucket = get_bucket(client)

      extension = File.extname(filename)
      key = SecureRandom.uuid
      info = create_info(filename)

      content_path = create_resource_path(client, key, extension)

      content_obj = bucket.object(content_path)
      content_obj.put(body:content)

      info_path = create_resource_path(client, key, ".info")
      info_obj = bucket.object(info_path)
      info_obj.put(body: info.to_json)

      create_key(key, extension)
    end

    def self.get_metadata(client, resource_key, template)
      bucket = get_bucket(client)

      info_path = create_resource_path(client, resource_key, ".info")
      info_obj = bucket.object(info_path)
      mod_at = get_modified_at(info_obj)
      e_tag = get_entity_tag(resource_key, mod_at, client, template)

      [e_tag, mod_at]
    end

    def self.get(client, resource_key, extension)
      bucket = get_bucket(client)

      content_path = create_resource_path(client, resource_key, extension)
      content_obj = bucket.object(content_path)
      content_type = get_content_type(content_path)

      [content_obj.get.body.read, content_type]
    end

    def self.delete(client, resource_key, extension)
      bucket = get_bucket(client)

      delete_obj(bucket, create_resource_path(client, resource_key, extension))

      delete_obj(bucket, create_resource_path(client, resource_key, ".info"))
    end

    private

    def self.create_resource_path(client, resource_key, extension)
      client_config = ClientService.get_config(client)
      key = nil
      if extension.start_with?(".")
        key = resource_key + extension
      else
        key = resource_key + "." + extension
      end
      key = client_config["path"] + "/" + key unless client_config["path"] == nil
      key
    end

    def self.create_key(resource_key, extension)
      key = nil
      if extension.start_with?(".")
        key = resource_key + extension
      else
        key = resource_key + "." + extension
      end
      key
    end

    def self.get_bucket(client)
      client_config = ClientService.get_config(client)
      @@s3.bucket(client_config["bucket"])
    end

    def self.delete_obj(bucket, key)
      content = bucket.object(key)
      content.delete
    end

    def self.create_info(filename)
      info = {original_filename: filename, content_type: get_content_type(filename), created_at: Time.now.utc, modified_at: Time.now.utc }
    end

    def self.get_content_type(content_key)
      mime_type = MIME::Types.type_for(content_key)
      mime_type.first.content_type
    end

    def self.get_modified_at(info)
      mod_at = JSON.parse(info.get.body.read)["modified_at"]

      Time.parse(mod_at)
    end

    def self.get_entity_tag(resource_key, mod_at, client, template)
      identity = resource_key + mod_at.to_s
      unless template == nil
        template_config = ClientService.get_config(client)["templates"][template]
        identity += template_config["width"].to_s + template_config["height"].to_s + template_config["manipulation"]
      end

      Digest::SHA1.hexdigest identity
    end
  end
end
