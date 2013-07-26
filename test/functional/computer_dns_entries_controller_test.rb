# -*- encoding : utf-8 -*-
require 'test_helper'

class ComputerDnsEntriesControllerTest < ActionController::TestCase
  setup do
    @computer_dns_entry = computer_dns_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:computer_dns_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create computer_dns_entry" do
    assert_difference('ComputerDnsEntry.count') do
      post :create, computer_dns_entry: { archived: @computer_dns_entry.archived, computer_id: @computer_dns_entry.computer_id, name: @computer_dns_entry.name }
    end

    assert_redirected_to computer_dns_entry_path(assigns(:computer_dns_entry))
  end

  test "should show computer_dns_entry" do
    get :show, id: @computer_dns_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @computer_dns_entry
    assert_response :success
  end

  test "should update computer_dns_entry" do
    put :update, id: @computer_dns_entry, computer_dns_entry: { archived: @computer_dns_entry.archived, computer_id: @computer_dns_entry.computer_id, name: @computer_dns_entry.name }
    assert_redirected_to computer_dns_entry_path(assigns(:computer_dns_entry))
  end

  test "should destroy computer_dns_entry" do
    assert_difference('ComputerDnsEntry.count', -1) do
      delete :destroy, id: @computer_dns_entry
    end

    assert_redirected_to computer_dns_entries_path
  end
end
