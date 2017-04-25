_               = require 'lodash'
async           = require 'async'
moment          = require 'moment'
SimpleBenchmark = require 'simple-benchmark'
debug           = require('debug')('smartspaces-verifier-instant-meeting:actionator')

class Actionator
  constructor: ->
    @steps = {}
    @benchmarks = {}
    @_beforeEach = (next) => next()

  beforeEach: (@_beforeEach) =>

  add: (operation, fn) =>
    @steps[operation] ?= []
    @steps[operation].push fn

  run: (callback) =>
    debug 'running...'
    async.eachOfSeries @steps, @_doStep, (error) =>
      debug 'done running', { error }
      callback error, @stats()

  stats: =>
    return _.compact _.map(_.keys(@benchmarks), @stat)

  stat: (operation) =>
    stat = @benchmarks[operation]
    return unless stat?
    return {
      operation,
      elapsed: stat.elapsed
      startTime: stat.startTime?.utc().toISOString()
      endTime: stat.endTime?.utc().toISOString()
    }

  _doStep: (actions, operation, callback) =>
    @_beforeEach (error) =>
      return callback error if error?
      @_startTimer operation
      async.parallel actions, (error) =>
        @_endTimer operation
        callback error

  _endTimer: (operation) =>
    return unless @benchmarks[operation]?
    { benchmark } = @benchmarks[operation]
    @benchmarks[operation].endTime = moment()
    @benchmarks[operation].elapsed = benchmark.elapsed()
    debug operation, 'ended', @stat operation

  _startTimer: (operation) =>
    return if @benchmarks[operation]?
    @benchmarks[operation] ?= {}
    @benchmarks[operation].benchmark = new SimpleBenchmark { label: operation }
    @benchmarks[operation].startTime = moment()
    debug operation, 'started'

module.exports = Actionator
