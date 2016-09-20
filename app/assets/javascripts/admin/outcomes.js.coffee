$ ->
  $(document).on 'click', '.edit_outcome .remove_fields', (event) ->
    event.preventDefault()

    $(this).parent().prev().find('input[type=hidden]').val('true')
    $(this).closest('.row').hide()

  $(document).on 'click', '.add_fields', (event) ->
    event.preventDefault()
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')

    $elements = $($(this).data('fields').replace(regexp, time))
    $autoCompleteElements = $elements.find('.autocomplete')

    if $autoCompleteElements.length > 0
      window.setupActivityAutoComplete($autoCompleteElements)

    $(this).before($elements)

