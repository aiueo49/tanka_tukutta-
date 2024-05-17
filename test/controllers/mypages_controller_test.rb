require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mypages_index_url
    assert_response :success
  end
end
