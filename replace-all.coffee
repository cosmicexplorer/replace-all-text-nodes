isInputBox = (node) ->
  # check whether node is null or node is not an html node
  node?.tagName?.toUpperCase() is 'input' or
  node?.getAttribute? 'contenteditable' or
  node?.getAttribute? 'role' is 'textbox'

isValidBaseNode = (node) ->
  node and ((node is document) or (not isInputBox node and
    isValidBaseNode node.parentNode))

isTextNode = (node) -> node?.nodeType is 3

replaceAllFromNode = (replaceFn, baseNode, opts) ->
  return [] if not isValidBaseNode baseNode
  # bfs for text leaves while trimming input boxes
  getLeafTextNodes = (node) -> switch
      when node.hasChildNodes() and (opts?.inputsToo or not isInputBox node)
        Array.prototype.slice.call(node.childNodes, 0).map(getLeafTextNodes)
          .reduce (a, b) -> a.concat b
      when isTextNode node then [node]
      else []
  getLeafTextNodes(baseNode).forEach (node) ->
    node.isReplaced = yes
    node.data = replaceFn node.data

# if futureNodesToo specified, returns mutationobserver which can be cancelled
replaceAllInPage = (replaceFn, opts) ->
  {inputsToo, notNow, repeat, timeouts, futureNodesToo} = opts if opts
  rplc = -> replaceAllFromNode replaceFn, document, inputsToo: inputsToo
  rplc() unless notNow
  timeouts?.forEach (timeout) -> setTimeout rplc, timeout
  setInterval rplc, repeat if repeat
  watchFutureNodes replaceFn if futureNodesToo

watchFutureNodes = (replaceFn) ->
  new MutationObserver (records) ->
    for rec in records
      node = rec.target
      switch rec.type
        when 'characterData'
          if node.isReplaced
            node.isReplaced = no
          else
            node.data = replaceFn node.data
            node.isReplaced = yes
        when 'childList'
          replaceAllFromNode replaceFn, extNode for extNode in rec.addedNodes
    null # don't cons up list comprehension

module.exports =
  replaceAllFromNode: replaceAllFromNode
  replaceAllInPage: replaceAllInPage
  watchFutureNodes: watchFutureNodes
