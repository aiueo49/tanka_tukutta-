require 'aws-sdk-s3'
require 'mini_magick'

class ImageConverter
  def initialize
    @s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
    @bucket = ENV['S3_BUCKET_NAME']
  end

  def convert_all_png_to_webp
    png_objects = list_png_objects
    png_objects.each do |object|
      convert_and_upload_image(object)
    end
  end

  private

  def list_png_objects
    objects = []
    continuation_token = nil

    loop do
      response = @s3.list_objects_v2(
        bucket: @bucket,
        prefix: 'uploads/',
        continuation_token: continuation_token
      )

      objects += response.contents.select { |obj| obj.key.end_with?('.png') }
      break unless response.is_truncated

      continuation_token = response.next_continuation_token
    end

    objects
  end

  def convert_and_upload_image(object)
    temp_file = download_image(object.key)
    webp_file = convert_to_webp(temp_file)
    upload_image_to_s3(webp_file, object.key)
    cleanup_temp_files(temp_file, webp_file)
  end

  def download_image(key)
    temp_file = Tempfile.new(['image', '.png'])
    @s3.get_object({ bucket: @bucket, key: key }, target: temp_file.path)
    temp_file
  end

  def convert_to_webp(temp_file)
    image = MiniMagick::Image.open(temp_file.path)
    webp_file = Tempfile.new(['image', 'webp'])
    image.format 'webp' 
    image.write(webp_file.path)
    webp_file
  end

  def upload_image_to_s3(webp_file, original_key)
    webp_key = original_key.gsub('.png', '.webp')
    @s3.put_object(
      bucket: @bucket,
      key: webp_key,
      body: File.open(webp_file.path),
      # acl: 'public-read',
    )
  end

  def cleanup_temp_files(*files)
    files.each { |file| file.close! }
  end
end

if __FILE__ == $0
  converter = ImageConverter.new
  converter.convert_all_png_to_webp
end

