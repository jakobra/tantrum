module Tantrum
  class ImageService    
    def self.manipulate(client, image_content, template)
      client_config = ClientService.get_config(client)
      
      raise ArgumentError, 'Invalid template' unless client_config["templates"].include?(template)
      
      template_settings = client_config["templates"][template]
      width = template_settings["width"].to_i
      height = template_settings["height"].to_i
      
      case template_settings["manipulation"]
      when "resize_and_pad"
        return resize_and_pad(width, height, image_content)
      when "resize_and_crop"
        return resize_and_crop(width, height, image_content)
      when "resize"
        return resize(width, height, image_content)
      else
        raise "An error has occured, invalid manipulation '#{template_settings["manipulation"]}'"
      end
    end
    
    private
    
    def self.resize_and_pad(width, height, image_content)
      image = MiniMagick::Image.read(image_content)
      image.resize_and_pad(width, height, background = :transparent, gravity = 'Center')
      image.to_blob
    end
    
    def self.resize_and_crop(width, height, image_content)
      image = MiniMagick::Image.read(image_content)
      image.resize "#{width}x#{height}^"
      if image[:width] > width
        x_start = (image[:width] - width) / 2
        image.crop("#{width}x#{height}+#{x_start}+0")
      else
        y_start = (image[:height] - height) / 2
        image.crop("#{width}x#{height}+0+#{y_start}")
      end
      image.to_blob
    end
    
    def self.resize(width, height, image_content)
      image = MiniMagick::Image.read(image_content)
      image.resize "#{width}x#{height}>"
      image.to_blob
    end
  end
end