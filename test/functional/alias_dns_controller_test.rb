# -*- encoding : utf-8 -*-
require 'test_helper'

class AliasDnsControllerTest < ActionController::TestCase
  setup do
    @alias_dn = alias_dns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alias_dns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alias_dn" do
    assert_difference('AliasDn.count') do
      post :create, alias_dn: { archived: @alias_dn.archived, computer_dns_id: @alias_dn.computer_dns_id, name: @alias_dn.name }
    end

    assert_redirected_to alias_dn_path(assigns(:alias_dn))
  end

  test "should show alias_dn" do
    get :show, id: @alias_dn
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @alias_dn
    assert_response :success
  end

  test "should update alias_dn" do
    put :update, id: @alias_dn, alias_dn: { archived: @alias_dn.archived, computer_dns_id: @alias_dn.computer_dns_id, name: @alias_dn.name }
    assert_redirected_to alias_dn_path(assigns(:alias_dn))
  end

  test "should destroy alias_dn" do
    assert_difference('AliasDn.count', -1) do
      delete :destroy, id: @alias_dn
    end

    assert_redirected_to alias_dns_path
  end
end
