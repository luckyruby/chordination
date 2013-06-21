toggle_consolation_points = ->
  if $('#scoresheet_consolation').is(':checked')
    $('.consolation-points').show()
  else
    $('#scoresheet_consolation_points').val('')
    $('.consolation-points').hide()
        
# Return a helper with preserved width of cells
fixHelper = (e, ui) ->
  ui.children().each ->
    $(this).width $(this).width()
  ui
    
$ ->
  $('#bets tbody').sortable
    helper: fixHelper
    axis: 'y'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  $('#participants tbody').sortable
    helper: fixHelper
    axis: 'y'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
  toggle_consolation_points()
  $('#scoresheet_consolation').change ->
    toggle_consolation_points()