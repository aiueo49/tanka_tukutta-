require 'rails_helper'

RSpec.describe User, type: :model do
  it "新規会員登録ができること" do
    user = User.new(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password")
    expect(user).to be_valid
  end
end
