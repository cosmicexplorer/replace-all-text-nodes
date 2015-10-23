isInputBox = (node) ->
  if not node? then no
  else if node.tagName?.toUpperCase() is 'input' then yes
  else if not node.getAttribute? then no
  else if node.getAttribute 'contenteditable' then yes
  else if node.getAttribute('role') is 'textbox' then yes
  else if node.getAttribute 'spellcheck' then yes
  else no

isValidBaseNode = (node) ->
  if not node? then no
  else if node is document then yes
  else if (not isInputBox node) and (isValidBaseNode node.parentNode) then yes
  else no

isTextNode = (node) -> node?.nodeType is 3

htmlColl2Arr = (coll) -> Array.prototype.slice.call coll, 0

curryLast = (args..., fn) -> (origArgs...) -> fn origArgs..., args...

# bfs for text leaves while pruning input boxes
getLeafTextNodes = (node, opts) ->
  inp = (opts?.inputsToo) or not (isInputBox node)
  if node.hasChildNodes() and inp
    htmlColl2Arr(node.childNodes).map(curryLast opts, getLeafTextNodes)
      .reduce (a, b) -> a.concat b
  else if (isTextNode node) and inp then [node]
  else []

replaceRecurFromNode = (replaceFn, baseNode, opts) ->
  return [] if not isValidBaseNode baseNode
  getLeafTextNodes(baseNode, opts).forEach (node) ->
    node.isReplaced = yes
    node.data = replaceFn node.data

# if futureNodesToo specified, returns mutationobserver which can be cancelled
replaceAllFromNode = (node, replaceFn, opts) ->
  {inputsToo, notNow, repeat, timeouts, futureNodesToo} = opts if opts
  rplc = -> replaceRecurFromNode replaceFn, node, inputsToo: inputsToo
  rplc() unless notNow
  timeouts?.forEach (timeout) -> setTimeout rplc, timeout
  setInterval rplc, repeat if repeat
  watchFutureNodes replaceFn, opts if futureNodesToo

replaceAllInPage = (args...) -> replaceAllFromNode document, args...

watchFutureNodes = (replaceFn, opts) ->
  new MutationObserver (records) ->
    for rec in records
      node = rec.target
      switch rec.type
        when 'characterData'
          if node.isReplaced
            node.isReplaced = no
          else
            if isValidBaseNode node
              node.data = replaceFn node.data
              node.isReplaced = yes
        when 'childList'
          for extNode in rec.addedNodes
            replaceRecurFromNode replaceFn, extNode, opts
    null # don't cons up list comprehension

module.exports =
  replaceAllFromNode: replaceAllFromNode
  replaceAllInPage: replaceAllInPage
  watchFutureNodes: watchFutureNodes
