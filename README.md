# actionator

Some crazy parallelized / serialized async library - blame @peterdemartini

## Explanation

For every instance of Actionator, you can `add` action to a task (grouped by the task name). All tasks will be ran in series, all actions will be ran in parallel. All tasks added must be added in order of execution.

## Usage

### `->add(string, fn)`

Add a step to a task name (specificed as a string in the first argument). Calling `fn` will break end all actions.

### `->run(fn)`

Run all actions. `fn` will be called with an `error` and `stats`

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
actions.run (error) =>
  return console.error error if error?
  console.log 'All steps are done'
```
