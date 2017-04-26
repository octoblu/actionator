{describe,beforeEach,it,expect} = global
sinon      = require 'sinon'
_          = require 'lodash'
Actionator = require '../'

describe 'Actionator', ->
  beforeEach ->
    @sut = new Actionator

  describe '->run', ->
    beforeEach (done) ->
      @actionOne = sinon.spy()
      @actionTwo = sinon.spy()
      @waitFor = sinon.spy()
      @otherAction = sinon.spy()
      @otherWaitFor = sinon.spy()
      @beforeHook = sinon.spy()
      @sut.beforeEach (next) =>
        @beforeHook()
        next()
      @sut.add 'supertask', 'step1', (next) =>
        @actionOne()
        _.delay next, 100
      @sut.add 'supertask', 'step2', (next) =>
        @actionTwo()
        _.delay next, 100
      @sut.add 'supertask', (next) =>
        @waitFor()
        _.delay next, 100
      @sut.add 'othertask', 'foo', (next) =>
        @otherAction()
        _.delay next, 100
      @sut.add 'othertask', 'foo', (next) =>
        @otherWaitFor()
        _.delay next, 100
      @sut.run (error, @stats) =>
        done error

    it 'should call beforeEach twice', ->
      expect(@beforeHook).to.have.been.calledTwice

    it 'should call waitFor', ->
      expect(@waitFor).to.have.been.called

    it 'should call actionOne', ->
      expect(@actionOne).to.have.been.called

    it 'should call actionTwo', ->
      expect(@actionTwo).to.have.been.called

    it 'should call otherAction', ->
      expect(@otherAction).to.have.been.called

    it 'should call otherWaitFor', ->
      expect(@otherWaitFor).to.have.been.called

    it 'should return the correct stats length', ->
      expect(@sut.stats().length).to.equal 6

    it 'should return the same stats', ->
      expect(@sut.stats()).to.deep.equal @stats

    it 'should have the correct stats for supertask', ->
      stat = @sut.stat('supertask')
      expect(stat.operation).to.equal 'supertask'
      expect(stat.id).to.equal 'supertask'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist

    it 'should have the correct stats for supertask:step1', ->
      stat = @sut.stat('supertask:step1')
      expect(stat.operation).to.equal 'supertask'
      expect(stat.id).to.equal 'supertask:step1'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist

    it 'should have the correct stats for supertask:step2', ->
      stat = @sut.stat('supertask:step2')
      expect(stat.operation).to.equal 'supertask'
      expect(stat.id).to.equal 'supertask:step2'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist

    it 'should have the correct stats for supertask:3', ->
      stat = @sut.stat('supertask:3')
      expect(stat.operation).to.equal 'supertask'
      expect(stat.id).to.equal 'supertask:3'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist

    it 'should have the correct stats for othertask', ->
      stat = @sut.stat('othertask')
      expect(stat.operation).to.equal 'othertask'
      expect(stat.id).to.equal 'othertask'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist

    it 'should have the correct stats for othertask:foo', ->
      stat = @sut.stat('othertask:foo')
      expect(stat.operation).to.equal 'othertask'
      expect(stat.id).to.equal 'othertask:foo'
      expect(stat.elapsed).to.be.above(0)
      expect(stat.startTime).to.exist
      expect(stat.endTime).to.exist
