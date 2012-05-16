require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get oauth" do
    get :oauth
    assert_response :success
  end

  test "should get oauth_callback" do
    get :oauth_callback
    assert_response :success
  end

  test "should get regist" do
    get :regist
    assert_response :success
  end

  test "should get post" do
    get :post
    assert_response :success
  end

  test "should get tweet" do
    get :tweet
    assert_response :success
  end

end
