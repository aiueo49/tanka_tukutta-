class OpenAi::ImageApi
  def initialize
    @api_key = ENV["OPEN_AI_API_KEY"]
    @base_url = 'https://api.openai.com/v1/images/generations'
  end

  def get_api_headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end

  # 画像生成APIを利用して画像を生成する
  def generate_image(prompt)
    conn = Faraday.new(url: @base_url) do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    payload = {
      prompt: prompt,
      model: "dall-e-3",
      n: 1,
      size: "1024x1024"
    }

    response = conn.post do |req|
      req.headers = get_api_headers
      req.body = payload.to_json
    end

    response_body = response.body
    image_url = response_body['data'][0]['url']

    image_url
  end

  # 生成した画像をS3に保存する
  def upload_image_to_s3(image_url)
    s3 = Aws::S3::Resource.new
    bucket_name = ENV["S3_BUCKET_NAME"]
    file_name = "generated_image_#{Time.now.to_i}.png"
    obj = s3.bucket(bucket_name).object("uploads/#{file_name}")

    # S3へ画像をアップロード
    obj.put(body: URI.open(image_url), acl: 'public-read')

    # アップロードした画像のURLを返す
    obj.public_url
  end

  # 画像生成APIを利用して画像を生成し、S3にアップロードする
  def generate_and_upload_image_to_s3(prompt)
    image_url = generate_image(prompt)
    s3_image_url = upload_image_to_s3(image_url)
    
    s3_image_url
  end
end
