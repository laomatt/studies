class Slide < ActiveRecord::Base
  belongs_to :slideshow
  belongs_to :user
  has_many :likes
  has_many :list_slides
  has_many :taggings

  def public?
    slideshow.public?
  end

  def thumb_url
    if first_thumb_url.present?
      first_thumb_url
    else
      file.thumb.url
    end
  end

  def ext_url
    if first_ext_url.present?
      first_ext_url
    else
      file.url
    end
  end

  module Uploader
    class FileUploader < CarrierWave::Uploader::Base
      include CarrierWave::Backgrounder::Delay
      include CarrierWave::MiniMagick

      process :convert => 'jpeg'
      storage :fog

      def store_dir
        "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end

      def file_name
        'filename.jpeg'
      end

      def self.fog_public
        true
      end

      version :thumb do
        process :resize_to_fill => [400, 400]
        process :convert => 'jpeg'
      end

    end
  end

  mount_uploader :file, Uploader::FileUploader
  # process_in_background :file
  store_in_background :file
end
