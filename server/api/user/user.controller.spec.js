'use strict';

var _ = require('lodash');
var should = require('should');
var app = require('../../app');
var request = require('supertest');
//var request = require('superagent'); // http://stackoverflow.com/a/14001892/270511
var User = require('./user.model');

describe('PUT /api/users/:id/contactInfo', function() {

  var token = null;

  beforeEach(function(done) {
    var userParams = {
      provider: 'local',
      name: 'Larry',
      email: 'larry@email.com',
      password: 'password'
    };
    User.find({}).remove(function() {
      User.create(userParams, function(err, user) {
        if (err) console.log(err);
        //console.log(user);
        request(app)
        .post('/auth/local')
        .send({ email: userParams.email, provider:'local', password: userParams.password })
        .end(function(err,res) {
          token = res.body.token; // defined in closure
          //console.log(token);
          done();
        });
      });
    });
  });

  it('should return success if new password fields match', function(done) {
    User.findOne({email: 'larry@email.com'}, function(err, user) {
      if (err) console.log(err);
      should.exist(user);
      var url = '/api/users/:id/contactInfo'.replace(':id', user._id);

      // (request.agent()) // will not require authentication
      request(app)
      .put(url, {
        oldPassword: 'password',
        newPassword: 'chickens',
        retypeNewPassword: 'chickens'
      })
      .set('authorization', 'Bearer ' + token)
      .expect(200)
      .end(done);
    });
  });

  it('should return error if new password fields do not match', function(done) {
    User.findOne({email: 'larry@email.com'}, function(err, user) {
      if (err) console.log(err);
      should.exist(user);
      var url = '/api/users/:id/contactInfo'.replace(':id', user._id);

      // (request.agent()) // will not require authentication
      request(app)
      .put(url, {
        oldPassword: 'password',
        newPassword: 'chickens',
        retypeNewPassword: 'roosters'
      })
      .set('authorization', 'Bearer ' + token)
      .expect(200)
      .end(done);
    });
  });

});
