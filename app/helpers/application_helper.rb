module ApplicationHelper
  # フラッシュメッセージの背景色を動的に変更する
  def flash_background_color(type)
    case type.to_sym
    when :notice then "bg-green-300"
    when :alert then "bg-red-300"
    when :error then "bg-yellow-300"
    else "bg-gray-300"
    end
  end

  # OGPを設定する
  def default_meta_tags
    {
      site: '短歌つくったー。',
      title: '短歌生成サービス',
      reverse: true,
      charset: 'utf-8',
      description: 'ユーザーが入力した文章をもとに、AIが短歌を生成するサービスです。',
      keywords: '短歌, 生成, AI, テキスト, ユーザー, 入力, サービス',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: '短歌つくったー。',
        title: '短歌生成サービス',
        description: 'ユーザーが入力した文章をもとに、AIが短歌を生成するサービスです。',
        type: 'website',
        url: request.original_url,
        image: image_url('sample.webp'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary_large_image',
        site: '@',
        site_name: '短歌つくったー。',
        title: '短歌生成サービス',
        description: 'ユーザーが入力した文章をもとに、AIが短歌を生成するサービスです。',
        image: image_url('sample.webp')
      }
    }
  end
end

