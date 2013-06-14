toggle_consolation_points = ->
  if $('#scoresheet_consolation').is(':checked')
    $('.consolation-points').show()
  else
    $('#scoresheet_consolation_points').val('')
    $('.consolation-points').hide()
$ ->
  toggle_consolation_points()
  $('#scoresheet_consolation').change ->
    toggle_consolation_points()