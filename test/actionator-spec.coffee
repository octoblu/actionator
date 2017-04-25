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
      @sut.add 'supertask', (next) =>
        @actionOne()
        _.delay next, 100
      @sut.add 'supertask', (next) =>
        @actionTwo()
        _.delay next, 100
      @sut.add 'supertask', (next) =>
        @waitFor()
        _.delay next, 100
      @sut.add 'othertask', (next) =>
        @otherAction()
        _.delay next, 100
      @sut.add 'othertask', (next) =>
        @otherWaitFor()
        _.delay next, 100
      @sut.run done

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

    it 'should return the stats', ->
      expect(@sut.stats().length).to.equal 2
