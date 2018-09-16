# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@expense_all_change = ->
  to_val = $('#selectbox_for_expense_all_change').val()
  expense = $('select[id^="receipt_receipt_details_attributes_"][id*="expense_id"]')
  expense.val(to_val)

