'use strict'

m = angular.module 'farmersmarketApp'

m.controller 'EventsCtrl', ['$scope', 'Event', ($scope, Event) ->
  $scope.errors = {}
  $scope.events = []

  # For Angular ui.calendar widget
  calEvents = []
  $scope.calEventSources = [events: calEvents]

  makeEventItem = (event) ->
    name: event.name
    date: (new Date(event.start)).toDateString()
    starts: (new Date(event.start)).shortTime()
    ends: (new Date(event.end)).shortTime()
    volunteers: event.volunteers
    volunteerSlots: event.volunteerSlots
    sponsor: event.sponsor

  makeCalendarEventItem = (event) ->
    title: event.name
    start: event.start

  # Request all events that haven't ended
  # TODO - show only active events for visitors.
  query = 
    end: '>' + (new Date()).addDays(-1)
    active: true
  # console.log(query);

  Event.query query, (events) ->
    $scope.events = (makeEventItem event for event in events)
    calEvents.length = 0

    for event in events
      calEvents.push makeCalendarEventItem(event)
  ]

m.directive 'eventSummary', ->
  restrict: 'E'
  scope:
    event: '='
  templateUrl: 'app/events/eventSummary.html'

m.filter 'decorateNumVolunteers', ->
  (num) ->
    if (num == 0)
      return 'None'
    num