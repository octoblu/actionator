_               = require 'lodash'
async           = require 'async'
moment          = require 'moment'
SimpleBenchmark = require 'simple-benchmark'
debug           = require('debug')

class Actionator
  constructor: ->
    @steps = {}
    @benchmarks = {}
    @_beforeEach = (next) => next()

  add: =>
    if _.isFunction arguments[0]
      taskName  = _.size(_.keys(@steps)) + 1
      actionName = _.size(@steps[taskName]) + 1
      fn         = arguments[0]
    else if _.isFunction arguments[1]
      taskName  = arguments[0]
      actionName = _.size(@steps[taskName]) + 1
      fn         = arguments[1]
    else if _.isFunction arguments[2]
      taskName  = arguments[0]
      actionName = arguments[1]
      fn         = arguments[2]

    @steps[taskName] ?= []
    @steps[taskName].push {
      taskName
      actionName
      fn
    }

  beforeEach: (@_beforeEach) =>

  run: (callback) =>
    debug('actionator') 'running...'
    async.eachOfSeries @steps, @_doStep, (error) =>
      debug('actionator') 'done running', { error }
      callback error, @stats()

  stats: =>
    return _.compact _.map(_.keys(@benchmarks), @stat)

  stat: (taskName) =>
    stat = @benchmarks[taskName]
    return unless stat?
    return {
      id: stat.id
      operation: stat.taskName
      elapsed: stat.elapsed
      startTime: stat.startTime?.utc().toISOString()
      endTime: stat.endTime?.utc().toISOString()
    }

  _doStep: (actions, taskName, callback) =>
    @_beforeEach (error) =>
      return callback error if error?
      @_startTimer taskName
      async.each actions, @_doAction, (error) =>
        @_endTimer taskName
        callback error

  _doAction: ({ fn, actionName, taskName }, callback) =>
    @_startTimer taskName, actionName
    fn (error) =>
      @_endTimer taskName, actionName
      callback error

  _endTimer: (taskName, actionName) =>
    id = "#{taskName}:#{actionName}" if actionName?
    id ?= taskName
    return unless @benchmarks[id]?
    { benchmark } = @benchmarks[id]
    @benchmarks[id].endTime = moment()
    @benchmarks[id].elapsed = benchmark.elapsed()
    debug("actionator:#{id}") 'ended', @stat id

  _startTimer: (taskName, actionName) =>
    id = "#{taskName}:#{actionName}" if actionName?
    id ?= taskName
    return if @benchmarks[id]?
    @benchmarks[id] ?= {}
    @benchmarks[id].id = id
    @benchmarks[id].taskName = taskName
    @benchmarks[id].benchmark = new SimpleBenchmark { label: id }
    @benchmarks[id].startTime = moment()
    debug("actionator:#{id}") 'started'

module.exports = Actionator
