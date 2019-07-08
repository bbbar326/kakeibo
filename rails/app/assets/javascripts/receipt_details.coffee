# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@file_upload = (form, f_tag) ->
  file_name = f_tag[0].files[0].name
  msg = ""
  msg += file_name
  msg += '\nアップロードします。'
  result = confirm(msg);
  if result
    form.submit()
    f_tag.val('')
  else
    f_tag.val('')
