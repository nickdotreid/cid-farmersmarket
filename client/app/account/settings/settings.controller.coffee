'use strict'

angular.module 'farmersmarketApp'
.controller 'SettingsCtrl', ($scope, $http, User, Auth) ->
  $scope.errors = {}

  $http.get('/api/users/me').success (user) ->
    $scope.user = {
      name: user.name
      email: user.email
      phone: user.phone
      role: user.role
    }
  
  $scope.changeContactInfo = (form) ->

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

  $scope.fields = ['name', 'email', 'phone']

  $scope.capitalize = (s) ->
    s[0].toUpperCase() + s.slice(1)

