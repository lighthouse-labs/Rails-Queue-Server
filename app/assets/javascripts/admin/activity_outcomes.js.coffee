window.setupActivityAutoComplete = (input) ->
  new AutoComplete(
    selector: input
    url: '/activities'
    render: (item) ->
      if (item.day)
        markup = [
          '<span class="activity-display activity-display-name">' + item.name + '</span>',
          '<span class="activity-display activity-display-type">' + item.type + '</span>',
          '<span class="activity-display activity-display-day">' + item.day + '</span>'
        ];
      else
        markup = ['<span class="activity-display activity-display-name">' + item.text + '</span>']

      markup.join('')

    select: (e, ui) ->
      $(@).val(ui.item.name)
      $(@).siblings('.hidden-item-type-field').first().val("Activity")
      $(@).siblings('.hidden-item-id-field').first().val(ui.item.id)
      false
  )

$(document).on 'turbolinks:load', ->
  window.setupActivityAutoComplete('.activity-outcomes-autocomplete-field')

  new AutoComplete(
    selector: '.outcomes-autocomplete-field'
    url: '/admin/outcomes',
    render: (item) ->
      markup = [
        '<span>',
        item.text,
        '</span>'
      ]

      markup.join('')

    select: (e, ui) ->
      $(@).val(ui.item.text)
      $(@).next('.outcome-id-hidden-field').val(ui.item.id)
      false
  )