# -*- encoding : utf-8 -*-
require 'test_helper'

class AliasDnsEntriesControllerTest < ActionController::TestCase
  setup do
    @alias_dns_entry = alias_dns_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alias_dns_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alias_dns_entry" do
    assert_difference('AliasDnsEntry.count') do
      post :create, alias_dns_entry: { archived: @alias_dns_entry.archived, computer_dns_entry_id: @alias_dns_entry.computer_dns_entry_id, name: @alias_dns_entry.name }
    end

    assert_redirected_to alias_dns_entry_path(assigns(:alias_dns_entry))
  end

  test "should show alias_dns_entry" do
    get :show, id: @alias_dns_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @alias_dns_entry
    assert_response :success
  end

  test "should update alias_dns_entry" do
    put :update, id: @alias_dns_entry, alias_dns_entry: { archived: @alias_dns_entry.archived, computer_dns_entry_id: @alias_dns_entry.computer_dns_entry_id, name: @alias_dns_entry.name }
    assert_redirected_to alias_dns_entry_path(assigns(:alias_dns_entry))
  end

  test "should destroy alias_dns_entry" do
    assert_difference('AliasDnsEntry.count', -1) do
      delete :destroy, id: @alias_dns_entry
    end

    assert_redirected_to alias_dns_entries_path
  end
end
