'use strict'

angular.module 'farmersmarketApp'
.controller 'ContactInfoCtrl', ($scope, $http, User) ->
  $scope.submitted = false
  $scope.errors = {}
  $scope.contactInfo = {}
  $scope.masterContactInfo = {}

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
  , (headers) ->
    flash.error = headers.message

  $scope.isContactInfoChanged = (contactInfo) ->
    !angular.equals(contactInfo, $scope.masterContactInfo)

  $scope.resetContactInfo = ->
    $scope.contactInfo = angular.copy($scope.masterContactInfo)
  
  $scope.changeContactInfo = (form) ->
    $scope.submitted = true
    return unless form.$valid

    User.changeContactInfo { id: $scope.uid}, $scope.contactInfo, (data, header) ->
      $scope.message = 'Content info successfully changed.'
    , (res) ->
      $scope.message = 'Cannot update your contact info now.'

###
# unique-email relies on asynchronous validation which is not yet implemented in Angular 1.2.x
.directive 'uniqueEmail', ($q, $http, $timeout) ->
  # console.log('uniqueEmail directive')
    require: 'ngModel'
    controller: 'ContactInfoCtrl'
    link: (scope, el, attrs, model) ->
      model.$asyncValidators.uniqueEmail = (modelValue, viewValue) ->
        if modelValue.length == 0 || modelValue == scope.masterContactInfo.email
          return $q.when() # resolve immediately

        def = $q.defer()
        User.get { email: modelValue }, data, (err, data) ->
          if data.length == 0
            def.resolve()
          else
            def.reject()

        , (headers) ->
          flash.error = headers.message

        return def.promise
###

angular.module 'farmersmarketApp'
.controller 'ChangePasswordCtrl', ['$scope', '$http', 'Auth', ($scope, $http, Auth) ->
  $scope.errors = {}
  $scope.pw = {}

  $scope.changePassword = (form) ->
    $scope.submitted = true
    return unless form.$valid

    Auth.changePassword $scope.pw.oldPassword, $scope.pw.newPassword
    .then ->
      $scope.message = 'Password successfully changed.'

    .catch ->
      form.password.$setValidity 'mongoose', false
      $scope.errors.other = 'Incorrect password'
      $scope.message = ''

  $scope.clearPassword = (form) ->
    $scope.pw.oldPassword = ''
    $scope.pw.newPassword = ''
    $scope.pw.retypePassword = ''
    form.$setPristine()
    form.$setValid()
  ]

.directive 'matchPassword', ->
  {
    require: 'ngModel'
    restrict: 'A'
    controller: 'ChangePasswordCtrl'
    link: (scope, el, attrs, model) ->
      if model.$validators
        model.$validators.matchPassword = (modelValue, viewValue) ->
          modelValue == scope.pw.newPassword
  }
