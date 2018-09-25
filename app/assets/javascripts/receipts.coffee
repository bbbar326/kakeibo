# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@expense_all_change = ->
  to_val = $('#selectbox_for_expense_all_change').val()
  expense = $('select[id^="receipt_receipt_details_attributes_"][id*="expense_id"]')
  expense.val(to_val)

@file_upload = (url, f_tag) ->
  file_name = f_tag[0].files[0].name
  msg = ""
  msg += file_name
  msg += '\nアップロードします。'
  result = confirm(msg);
  if result
    f = $('#f_upload')
    f.attr('action', url);
    f.submit()
    f_tag.val('')
  else
    f_tag.val('')

