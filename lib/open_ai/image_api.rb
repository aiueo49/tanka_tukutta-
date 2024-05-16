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
