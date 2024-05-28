class UpdateImageUrlToWebp < ActiveRecord::Migration[7.1]
  def up
    Post.where("image_url LIKE ?", "%.png").find_each do |post|
      post.update(image_url: post.image_url.gsub(".png", ".webp"))
    end
  end

  def down
    Post.where("image_url LIKE ?", "%.webp").find_each do |post|
      post.update(image_url: post.image_url.gsub(".webp", ".png"))
    end
  end
end
