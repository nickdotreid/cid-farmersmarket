'use strict'

angular.module 'farmersmarketApp'
.controller 'VolunteerCtrl', ($scope, $state, $location, flash, Event, Volunteer, VolunteerEvent) ->
  $scope.errors = {}
  $scope.message = ''

  # attributes come from DOM
  $scope.volunteer =
    email: ''
    name: ''
    phone: ''
  
  # attributes come from DB
  $scope.event =
    href: ''
    name: ''
    sponsor: ''
    date: ''
    hours: ''

  eventId = $location.path().split('/').pop()

  Event.get { id: eventId }, (event) ->
    start = new Date(event.start)
    end = new Date(event.end)

    $scope.event = 
      href: $state.href('admin-event', { id: event._id })
      name: event.name
      sponsor: event.sponsor
      date: start.toDateString()
      hours: start.shortTime() + ' - ' + end.shortTime()
  , (headers) ->
    flash.error = headers.data.message

  $scope.register = ->
    # Create volunteer_event record if none existed.
    saveVolunteerEvent = (volunteer_id, event_id) ->
      params = { volunteer: volunteer_id, event: eventId }
      VolunteerEvent.query params, (ar) ->
        if ar.length == 0
          VolunteerEvent.save params, (data, header) ->
            # TODO send confirmation mail to admin and to volunteer
            $state.go('volunteer.confirm', { id: volunteer_id, event_id: eventId })
          , (headers) ->
            flash.error = headers.data.message

    # Look up volunteer by e-mail and create record if none existed.
    Volunteer.query { email: $scope.volunteer.email }, (volunteers) ->
      if volunteers.length == 0
        # Create new record for volunteer.
        data =
          email: $scope.volunteer.email
          name: $scope.volunteer.name
          phone: $scope.volunteer.phone

        Volunteer.save data, (volunteer) ->
          saveVolunteerEvent volunteer._id, eventId
        , (headers) ->
          flash.error = headers.data.message

      else
        volunteer = volunteers[0]
        saveVolunteerEvent volunteer._id, eventId
        
        # Update name and phone for volunteer
        volunteer.name = $scope.volunteer.name
        volunteer.phone = $scope.volunteer.phone
        volunteer.$update (data, header) ->
          console.log(header)
        , (headers) ->
          flash.error = headers.data.message
    , (headers) ->
      flash.error = headers.data.message
