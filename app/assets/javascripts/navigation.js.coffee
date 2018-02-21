$ ->

  $(document).on 'click', '.request-assistance-button', (e) ->
    e.preventDefault()
    reasonTextField = $(@).closest('form').find('textarea')
    reason = reasonTextField.val()
    activityId = $(@).closest('form').find('select').val()
    window.App.userChannel.requestAssistance(reason, activityId)
    reasonTextField.val('')

  $(document).on 'click', '.cancel-request-assistance-button', (e) ->
    e.preventDefault()
    e.stopPropagation()

    if confirm("Are you sure you want to withdraw this assistance request?")
      window.App.userChannel.cancelAssistanceRequest()

  $(document).on 'click', '.on-duty-link', (e) ->
    e.preventDefault()
    window.App.teacherChannel.onDuty()

    $('.on-duty-link').attr('hidden', true)
    $('.off-duty-link').removeAttr('hidden')

  $(document).on 'click', '.off-duty-link', (e) ->
    e.preventDefault()
    window.App.teacherChannel.offDuty()

    $('.off-duty-link').attr('hidden', true)
    $('.on-duty-link').removeAttr('hidden')

  $(document).on 'click', '.sign-out-link', (e) ->
    window.App.teacherChannel.offDuty()
