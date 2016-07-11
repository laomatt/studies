class Slide < ActiveRecord::Base
  belongs_to :slideshow
  belongs_to :user
  has_many :likes
  has_many :list_slides
  has_many :taggings

  def public?
    slideshow.public?
  end

  module Uploader
    class FileUploader < CarrierWave::Uploader::Base
      include CarrierWave::MiniMagick
      # storage :s3
      process :convert => 'jpeg'

      # def store_dir
        # "#{self.user.email}/#{self.slideshow.id.to_s}/#{self.id}"
      # end

      def store_dir
        "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end

      def file_name
        'filename.jpeg'
      end

      version :thumb do
        process :resize_to_fill => [400, 400]
        process :convert => 'jpeg'
      end

    end
  end

  mount_uploader :file, Uploader::FileUploader
end
