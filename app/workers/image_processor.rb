class ImageProcessor
  include Sidekiq::Worker
  # include SidekiqStatus::Worker
  sidekiq_options retry: false

  def perform(slideshow_id, user_id, io_array, tags_string)
    tags = tags_string
    # byebug
    io_array.each do |uploaded_io|
      temp_file = Tempfile.new(['RackMultipart','.jpg'])
      uploaded_io[:tempfile] = temp_file
      ad = ActionDispatch::Http::UploadedFile.new(uploaded_io)
      ad.original_filename = uploaded_io['filename']
      ad.content_type = uploaded_io['type']
      ad.headers = uploaded_io['head']

      original_filename = uploaded_io[:filename]

      slide = Slide.new(:slideshow_id => slideshow_id, :title =>original_filename, :on_s3 => true, :user_id => user_id)
      slide.file = ad
      slide.save!

      if tags_string.present?
        tags = tags_string
        tag_array = tags.split(',')

        tag_array.each do |tg|
          if Tag.exists?(:name => tg)
            t = Tag.find(:name => tg)
            Tagging.create(:tag_id => t.id, :slide_id => slide.id)
          else
            t = Tag.create(:name => tg)
            Tagging.create(:tag_id => t.id, :slide_id => slide.id)
          end
        end

      end
      # render :json => {:error=> 'none', :slide => slide}

    end

  end

end