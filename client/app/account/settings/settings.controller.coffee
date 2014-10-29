'use strict'

angular.module 'farmersmarketApp'
.controller 'SettingsCtrl', ['$scope', '$http', 'User', 'Auth', 'flash', ($scope, $http, User, Auth, flash) ->
  $scope.errors = {}

  # ng-pattern won't work together with ui-mask and isn't needed.
  #$scope.phonePat = /^\(\d{3}\) \d{3}-\d{4}$/

  #$http.get('/api/users/me').success (user) ->
  User.get (user) ->
    $scope.uid = user._id
    $scope.contactInfo = {
      name: user.name
      email: user.email
      phone: user.phone
    }
    $scope.masterContactInfo = angular.copy($scope.contactInfo)

  $scope.isChanged = (contactInfo) ->
    !angular.equals(contactInfo, $scope.masterContactInfo)

  $scope.reset = ->
    $scope.contactInfo = angular.copy($scope.masterContactInfo)
  
  $scope.changeContactInfo = (form) ->
    $scope.submitted = true

    if form.$valid
      User.changeContactInfo { id: $scope.uid}, $scope.contactInfo, (data, header) ->
        $scope.message = 'Content info successfully changed.'
      , (res) ->
        $scope.message = 'Cannot update your contact info now.'

  $scope.changePassword = (form) ->
    $scope.submitted = true

    if form.$valid
      Auth.changePassword $scope.user.oldPassword, $scope.user.newPassword
      .then ->
        $scope.message = 'Password successfully changed.'

      .catch ->
        form.password.$setValidity 'mongoose', false
        $scope.errors.other = 'Incorrect password'
        $scope.message = ''

  $scope.capitalize = (s) ->
    s[0].toUpperCase() + s.slice(1)
  ]
