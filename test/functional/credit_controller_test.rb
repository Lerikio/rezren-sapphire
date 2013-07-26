# -*- encoding : utf-8 -*-
require 'test_helper'

class CreditControllerTest < ActionController::TestCase
  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
