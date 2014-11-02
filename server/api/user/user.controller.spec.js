'use strict';

var _ = require('lodash');
var should = require('should');
var app = require('../../app');
var request = require('supertest');
//var request = require('superagent'); // http://stackoverflow.com/a/14001892/270511
var User = require('./user.model');

describe('PUT /api/users/:id/contactInfo', function() {

  var cookie = null;

  before(function(done) {
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
        .post('/login')
        .send({ email: userParams.email, provider:'local', password: userParams.password })
        .end(function(err,res) {
          //res.should.have.status(200);
          cookie = res.headers['set-cookie'];
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

      console.log(cookie);
      // (request.agent()) // will not require authentication
      request(app)
      .put(url, {
        oldPassword: 'password',
        newPassword: 'chickens',
        retypeNewPassword: 'chickens'
      })
      .set('cookie', cookie)
      .expect(200)
      .end(function(err, res) {
        if (err) return done(err);
/*        for (var key in res) {
          console.log(key);
        }
*/
        console.log(res.error);
        //res.status.should.be.exactly(200);
        done();
      });
    });
  });
/*
  it('should return 400 if new password fields do not match', function(done) {
    User.findOne({email: 'larry@email.com'}, function(err, user) {
      if (err) console.log(err);
      should.exist(user);
      var url = 'localhost:9000/api/:id/contactInfo'.replace(':id', user._id);

      (request.agent()) // will not require authentication
      .put(url, {
        oldPassword: 'password',
        newPassword: 'chickens',
        retypeNewPassword: 'roosters'
      })
      //.expect(400)
      .end(function(err, res) {
        res.status.should.be.exactly(400);
        if (err) return done(err);
        done();
      });
    });
  });
*/
});
