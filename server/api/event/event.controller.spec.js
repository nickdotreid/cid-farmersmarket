'use strict';

require ('../../../common/date');

var _ = require('lodash');
var should = require('should');
var app = require('../../app');
var request = require('supertest');
var Event = require('./event.model');
var EventSeed = require('./event.seed');

describe('GET /api/events', function() {

  var N_DAYS = 10;

  before(function(done) {
    Event.find().remove(function() {
      var date = (new Date()).addDays(-30);
      date.setHours(11);
      date.setMinutes(0);
      console.log(date);
      EventSeed.seedEvents(date, 4, 12, 7, function(err) {
        if (err) return done(err);
        done();
      });
    });
  });

  it('should respond with JSON array', function(done) {
    request(app)
      .get('/api/events')
      .expect(200)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        res.body.should.be.instanceof(Array);
        done();
      });
  });

  it('should filter out events that ended', function(done) {
    var yesterday = (new Date()).addDays(-1);
    var url = '/api/events?end=>' + yesterday;
    console.log('usl = ' + url);

    request(app)
      .get(url)
      .expect(200)
      .expect('Content-Type', /json/)
      .end(function(err, res) {
        if (err) return done(err);
        res.body.should.be.instanceof(Array);
        (res.body.length > 0).should.be.true;
        res.body.forEach(function(event) {
          //console.log(event.end);
          (new Date(event.end) > yesterday).should.be.true;
        });
        done();
      });
  });
});
