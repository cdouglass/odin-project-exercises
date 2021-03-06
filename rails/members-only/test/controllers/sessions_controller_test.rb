require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @user = User.new(name:  "M. plicatulus",
                     email: "User@example.com",
                     password: "password",
                     password_confirmation: "password")
    @user.save
  end

  def test_get_new
    get :new
    assert_response :success
  end

end
