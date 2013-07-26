# -*- encoding : utf-8 -*-
require 'test_helper'

class GenericDnsControllerTest < ActionController::TestCase
  setup do
    @generic_dn = generic_dns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:generic_dns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create generic_dn" do
    assert_difference('GenericDn.count') do
      post :create, generic_dn: { archived: @generic_dn.archived, external: @generic_dn.external, name: @generic_dn.name, return: @generic_dn.return, type: @generic_dn.type }
    end

    assert_redirected_to generic_dn_path(assigns(:generic_dn))
  end

  test "should show generic_dn" do
    get :show, id: @generic_dn
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @generic_dn
    assert_response :success
  end

  test "should update generic_dn" do
    put :update, id: @generic_dn, generic_dn: { archived: @generic_dn.archived, external: @generic_dn.external, name: @generic_dn.name, return: @generic_dn.return, type: @generic_dn.type }
    assert_redirected_to generic_dn_path(assigns(:generic_dn))
  end

  test "should destroy generic_dn" do
    assert_difference('GenericDn.count', -1) do
      delete :destroy, id: @generic_dn
    end

    assert_redirected_to generic_dns_path
  end
end
