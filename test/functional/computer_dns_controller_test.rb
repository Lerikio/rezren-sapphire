# -*- encoding : utf-8 -*-
require 'test_helper'

class ComputerDnsControllerTest < ActionController::TestCase
  setup do
    @computer_dn = computer_dns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:computer_dns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create computer_dn" do
    assert_difference('ComputerDn.count') do
      post :create, computer_dn: { archived: @computer_dn.archived, name: @computer_dn.name }
    end

    assert_redirected_to computer_dn_path(assigns(:computer_dn))
  end

  test "should show computer_dn" do
    get :show, id: @computer_dn
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @computer_dn
    assert_response :success
  end

  test "should update computer_dn" do
    put :update, id: @computer_dn, computer_dn: { archived: @computer_dn.archived, name: @computer_dn.name }
    assert_redirected_to computer_dn_path(assigns(:computer_dn))
  end

  test "should destroy computer_dn" do
    assert_difference('ComputerDn.count', -1) do
      delete :destroy, id: @computer_dn
    end

    assert_redirected_to computer_dns_path
  end
end
