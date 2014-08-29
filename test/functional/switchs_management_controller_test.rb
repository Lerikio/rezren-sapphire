require 'test_helper'

class SwitchsManagementControllerTest < ActionController::TestCase
  test "should get synchronisation" do
    get :synchronisation
    assert_response :success
  end

end
