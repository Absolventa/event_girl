$(document).ready ->
  $('#expected_event_started_at').datepicker({ dateFormat: "yy-mm-dd" })
  $('#expected_event_ended_at').datepicker({ dateFormat: "yy-mm-dd" })

  $('#toggle_weekday_selection').click (e) ->
    e.preventDefault()
    selector = '.weekday-selection input[type=checkbox]'
    $(selector).each ->
      $(this).prop('checked', !$(this).prop('checked'))

  $('#available_incoming_event_titles').change ->
    $('#expected_event_title').val($(this).val())
    $('#expected_event_title').focus()
