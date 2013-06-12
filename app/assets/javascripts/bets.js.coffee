toggle_choices = ->
  if $('#bet_bet_type :selected').val() == 'winner'
    $('.choices').show()
  else
    $('.choices').hide()
$ ->
  toggle_choices()
  $('#bet_bet_type').change (e) ->
    toggle_choices()