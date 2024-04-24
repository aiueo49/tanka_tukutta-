class ChatApi
  def initialize(prompt)
    @api_key = Settings.open_ai.api_key
    @base_url = "https://api.openai.com/v1/chat/completions"
    @histories = []

    if prompt
      @histories.push({ role: "system", content: prompt })
    end
  end

  def get_api_headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-type" => "application/json",
    }
  end

  def chat(content)
    @histories.push({ role: "user", content: content })

    conn = Faraday.new(url: @base_url) do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    payload = {
      model: "gpt-3.5-turbo",
      max_tokens: 512,
      temperature: 0.9,
      messages: @histories,
    }

    response = conn.post do |req|
      req.headers = get_api_headers
      req.body = payload.to_json
    end

    message = response.body["choices"][0]["message"]
    @histories.push(message)
    message["content"]
  end
end
