class Post < ApplicationRecord
  belongs_to :user

  # ransackの検索対象カラムを指定
  def self.ransackable_attributes(auth_object = nil)
    %w(title content)
  end 

  def self.ransackable_associations(auth_object = nil)
    %w(user)
  end
end
