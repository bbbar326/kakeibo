require 'test_helper'

class PayAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pay_account = pay_accounts(:one)
  end

  test "should get index" do
    get pay_accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_pay_account_url
    assert_response :success
  end

  test "should create pay_account" do
    assert_difference('PayAccount.count') do
      post pay_accounts_url, params: { pay_account: { name: @pay_account.name } }
    end

    assert_redirected_to pay_account_url(PayAccount.last)
  end

  test "should show pay_account" do
    get pay_account_url(@pay_account)
    assert_response :success
  end

  test "should get edit" do
    get edit_pay_account_url(@pay_account)
    assert_response :success
  end

  test "should update pay_account" do
    patch pay_account_url(@pay_account), params: { pay_account: { name: @pay_account.name } }
    assert_redirected_to pay_account_url(@pay_account)
  end

  test "should destroy pay_account" do
    assert_difference('PayAccount.count', -1) do
      delete pay_account_url(@pay_account)
    end

    assert_redirected_to pay_accounts_url
  end
end
