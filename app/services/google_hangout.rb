require 'googleauth'
require 'google/apis/calendar_v3'

class GoogleHangout

  def initialize
    @APPLICATION_NAME = "CompassHangoutsMeet".freeze
    scope = 'https://www.googleapis.com/auth/calendar.events'

    @authorizer = ::Google::Auth::ServiceAccountCredentials.make_creds(
      scope: scope
    )
  end

  def create_hangout(assistor, assistee)
    begin
      google_org_domain = ENV["GOOGLE_SUB_EMAIL"].split('@').last
      @authorizer.sub = ENV["GOOGLE_SUB_EMAIL"] if assistee.email.split('@').last == google_org_domain || assistor.email.split('@').last == google_org_domain
      @authorizer.fetch_access_token!

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = @authorizer

      now = DateTime.now

      event = Google::Apis::CalendarV3::Event.new(
        summary:           "Assistance Request Between #{assistor.full_name} and #{assistee.full_name}",
        location:          (assistee.location&.name).to_s,
        description:       'This event was automatically created by the HangoutsCreator Service Account',
        guests_can_modify: true,
        start:             Google::Apis::CalendarV3::EventDateTime.new(
          date_time: now.to_s
        ),
        end:               Google::Apis::CalendarV3::EventDateTime.new(
          date_time: now.new_offset('+00:30').to_s
        ),
        # attendees: [
        #   Google::Apis::CalendarV3::EventAttendee.new(
        #     email: assistor.email
        #   ),
        #   Google::Apis::CalendarV3::EventAttendee.new(
        #     email: assistee.email
        #   )
        # ],
        conference_data:   {
          create_request: {
            request_id: SecureRandom.uuid
          }
        }
      )

      result = service.insert_event('primary', event, conference_data_version: 1)
    rescue StandardError => err
      puts "Error creating hangout"
      return nil
    end

    event_details(result)
  end

  private

  def event_details(event)
    entry_points = event&.conference_data&.entry_points
    uri = nil
    entry_points&.each do |point|
      return {uri: point.uri, type: event&.conference_data&.conference_solution&.key&.type} if point.entry_point_type == 'video'
    end
  end

end