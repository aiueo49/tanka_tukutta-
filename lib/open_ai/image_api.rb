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
end

# APIキーを設定
# api_key = ENV["OPEN_AI_API_KEY"]

# インスタンス作成
# image_api = OpenAi::ImageApi.new(api_key)

# ユーザー入力を受け取り、画像を生成
# puts "Please enter a description for the image you want to generate:"
# user_input = gets.chomp

# 画像生成
# image_url = image_api.generate_image(user_input)

# 画像URLを表示
# puts "Image generated! You can view it at: #{image_url}"
