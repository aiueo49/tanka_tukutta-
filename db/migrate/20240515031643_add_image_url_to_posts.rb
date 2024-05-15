class AddImageUrlToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :image_url, :text
  end
end
