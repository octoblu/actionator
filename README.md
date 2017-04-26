# actionator

Some crazy combination of parallelized / serialized async library - blame @peterdemartini

## Explanation

For every instance of Actionator, you can `add` action to a task (grouped by the task name). All tasks will be ran in series, all actions will be ran in parallel. All tasks added must be added in order of execution.

## Usage

### `->add([<taskName>, <actionName>], callback)`

Add a step to be performed in parallel grouped by the optional taskName. Additionally calling it with an optional actionName (second argument) as a label. Calling the callback with an error will short circuit the entire flow.

### `->beforeEach(callback)`

Run this function before each task.

### `->run(callback)`

Run all actions. `fn` will be called with an `error` and `stats`

### `->stats()`

Returns benchmarks for each task.

### `->stat(string)`

Returns benchmarks for a task.

## Example

```coffee
Actionator = require 'actionator'
actions = new Actionator
actions.add 'foo', (next) =>
  setTimeout =>
    console.log 'this will output after step 2'
    next()
  , 100
actions.add 'foo', (next) =>
  setTimeout =>
    console.log 'this will output before step 1'
    next()
  , 10
actions.add 'bar', (next) =>
  console.log 'this will output after foo step 1 and 2'
  next()
actions.add 'bar', (next) =>
  setTimeout =>
    console.log 'this will be the last step ran'
    next()
  , 100
actions.run (error, stats) =>
  return console.error error if error?
  console.log 'All steps are done'
  console.log stats
```
