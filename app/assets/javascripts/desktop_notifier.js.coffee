class DesktopNotifier
  constructor: ->
    @supportsNotifications = ("Notification" of window)
    @permissionGranted = false
    @canNotifyGenerally = @checkIfNeedsNotifications()
    @checkNotificationSituation()

  checkNotificationSituation: ->
    return unless @supportsNotifications
    return unless @canNotifyGenerally
    switch Notification.permission
      when "granted"
        @permissionGranted = true
      else
        @requestNotificationPermission()

  requestNotificationPermission: ->
    if @supportsNotifications
      Notification.requestPermission().then (res) =>
        @permissionGranted = true if res is "granted"

  checkIfNeedsNotifications: ->
    window.current_user?.type is 'Teacher'

  onDuty: ->
    window.current_user.onDuty is on

  shouldNotifyNow: ->
    @supportsNotifications && @permissionGranted && @onDuty()

  notificationBody: (request) ->
    week = request.requestor.cohort.week;
    "[Week #{week}] #{request.reason}\r\n(Notified b/c you're marked as on duty)"

  handleNewAssistanceRequest: (assistanceRequest) ->
    if @shouldNotifyNow()
      new Notification "Assistance Requested by #{assistanceRequest.requestor.firstName} #{assistanceRequest.requestor.lastName}",
        body: @notificationBody(assistanceRequest),
        icon: assistanceRequest.requestor.avatarUrl

if window.current_user
  window.App ||= {}
  notifier = window.App.desktopNotifier = new DesktopNotifier
  window.App.queue.registerNotifier(notifier) if window.App.queue
