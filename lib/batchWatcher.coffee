chokidar = require 'chokidar'
path = require 'path'

sendBatch = undefined

exports.watch = (accountName, sendBatchFunc) ->
  sendBatch = sendBatchFunc || (batch) -> console.log batch
  root = path.resolve accountName
  watcher = chokidar.watch root, persistent: true, ignoreInitial: true,
    ignored: (filePath) -> /(^[.#]|(?:__|~)$)/.test path.basename(filePath)

  watcher
    .on('add', onAdded)
    .on('addDir', onDirAdded)
    .on('change', onChanged)
    .on('unlink', onUnlinked)
    .on('unlinkDir', onDirUnlinked)
    .on('error', (error) -> )

lastBatch = 0

changes = {}

trySendBatch = (thisBatch) ->
  return unless thisBatch is lastBatch

  batch = for filePath, action of changes when action
    action: action
    path: filePath
    
  changes = {}
  lastBatch = 0

  sendBatch batch

debounce = () ->
  thisBatch = ++lastBatch
  setTimeout((() -> trySendBatch(thisBatch)), 200)

onAdded = (filePath) ->
  changes[filePath] = 'update'
  debounce()

onDirAdded = (dirPath) ->

onChanged = (filePath) ->
  changes[filePath] = 'update'
  debounce()

onUnlinked = (filePath) ->
  changes[filePath] = 'delete'
  debounce()

onDirUnlinked = (filePath) ->
  changes[filePath] = 'delete-folder'
  debounce()
