module MiniMagick
  class Image
    def resize_and_pad(width, height, background = :transparent, gravity='Center')
      combine_options do |cmd|
        cmd.thumbnail "#{width}x#{height}>"
        if background == :transparent
          cmd.background "rgba(255, 255, 255, 0.0)"
        else
          cmd.background background
        end
        cmd.gravity gravity
        cmd.extent "#{width}x#{height}"
      end
    end
  end
end