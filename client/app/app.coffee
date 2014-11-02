'use strict'

angular.module 'farmersmarketApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'angular-flash.service',
  'angular-flash.flash-alert-directive',
  'ui.calendar',
  'ngGrid',
  'ui.router',
  'ui.bootstrap',
  'ui.mask'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider, flashProvider) ->
  $urlRouterProvider
  .otherwise '/'

  $locationProvider.html5Mode true
  $httpProvider.interceptors.push 'authInterceptor'

  # http://getbootstrap.com/components/#alerts 
  flashProvider.errorClassnames.push 'alert-danger'
  flashProvider.errorClassnames.push 'alert-warning'
  flashProvider.errorClassnames.push 'alert-success'
  flashProvider.errorClassnames.push 'alert-info'

.factory 'authInterceptor', ($rootScope, $q, $cookieStore, $location) ->
  # Add authorization token to headers
  request: (config) ->
    config.headers = config.headers or {}
    config.headers.Authorization = 'Bearer ' + $cookieStore.get 'token' if $cookieStore.get 'token'
    config

  # Intercept 401s and redirect you to login
  responseError: (response) ->
    if response.status is 401
      $location.path '/login'
      # remove any stale tokens
      $cookieStore.remove 'token'

    $q.reject response

.run ($rootScope, $location, Auth) ->
  # Redirect to login if route requires auth and you're not logged in
  $rootScope.$on '$stateChangeStart', (event, next) ->
    Auth.isLoggedInAsync (loggedIn) ->
      $location.path "/login" if next.authenticate and not loggedIn
