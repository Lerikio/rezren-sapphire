# -*- encoding : utf-8 -*-
require 'test_helper'

class GenericDnsEntriesControllerTest < ActionController::TestCase
  setup do
    @generic_dns_entry = generic_dns_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:generic_dns_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create generic_dns_entry" do
    assert_difference('GenericDnsEntry.count') do
      post :create, generic_dns_entry: { archived: @generic_dns_entry.archived, external: @generic_dns_entry.external, name: @generic_dns_entry.name, return: @generic_dns_entry.return, type: @generic_dns_entry.type }
    end

    assert_redirected_to generic_dns_entry_path(assigns(:generic_dns_entry))
  end

  test "should show generic_dns_entry" do
    get :show, id: @generic_dns_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @generic_dns_entry
    assert_response :success
  end

  test "should update generic_dns_entry" do
    put :update, id: @generic_dns_entry, generic_dns_entry: { archived: @generic_dns_entry.archived, external: @generic_dns_entry.external, name: @generic_dns_entry.name, return: @generic_dns_entry.return, type: @generic_dns_entry.type }
    assert_redirected_to generic_dns_entry_path(assigns(:generic_dns_entry))
  end

  test "should destroy generic_dns_entry" do
    assert_difference('GenericDnsEntry.count', -1) do
      delete :destroy, id: @generic_dns_entry
    end

    assert_redirected_to generic_dns_entries_path
  end
end
