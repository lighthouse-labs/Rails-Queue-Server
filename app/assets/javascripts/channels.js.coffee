window.App = {};

# This is a hack because the asset pipeline doesn't respect the ENV['HOST'] when doing a precompile for production
host = window.location.hostname;
if window.location.port isnt ""
  host += ":#{window.location.port}"

proto = if window.location.protocol == 'https:' then 'wss://' else 'ws://'
App.cable = Cable.createConsumer(proto + host + '/websocket');

window.connectToTeachersSocket = ->
  App.teacherChannel = App.cable.subscriptions.create("TeacherChannel",
    onDuty: ->
      @perform 'on_duty'

    offDuty: ->
      @perform 'off_duty'

    received: (data) ->
      handler = new TeacherChannelHandler data
      handler.processResponse()
  )

$ ->
  App.userChannel = App.cable.subscriptions.create("UserChannel",

    connected: ->
      if $('.reconnect-holder').is(':visible')
        $('.reconnect-holder').hide()

    requestAssistance: (reason, activityId) ->
      @perform 'request_assistance', reason: reason, activity_id: activityId

    cancelAssistanceRequest: ->
      @perform 'cancel_assistance'

    received: (data) ->
      handler = new UserChannelHandler data
      handler.processResponse()

    disconnected: ->
      $('.reconnect-holder').delay(500).show(0)
  )
