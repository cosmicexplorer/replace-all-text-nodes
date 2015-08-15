isInputBox = (node) ->
  # check whether node is null or node is not an html node
  node?.tagName?.toUpperCase() is 'input' or
  node.getAttribute 'contenteditable' or
  node.getAttribute 'role' is 'textbox'

isValidBaseNode = (node) ->
  node and node isnt document and not isInputBox node and
    isValidBaseNode node.parentNode

isTextNode = (node) -> node?.nodeType is 3

replaceAllFromNode = (replaceFn, baseNode, opts) ->
  return [] if not isValidBaseNode baseNode
  # bfs for text leaves while trimming input boxes
  getLeafTextNodes = (node) -> switch
      when node.hasChildNodes() and (not opts.noInputs or not isInputBox node)
        node.childNodes.map(getLeafTextNodes).reduce (a, b) -> a.concat b
      when isTextNode node then [node]
      else []
  getLeafTextNodes(baseNode).forEach (node) -> node.data = replaceFn node.data

# if futureNodesToo specified, returns mutationobserver which can be cancelled
replaceAllInPage = (replaceFn, opts) ->
  {noInputs, notNow, repeat, timeouts, futureNodesToo} = opts if opts
  rplc = -> replaceAll replaceFn, document, noInputs: noInputs
  rplc() unless notNow
  timeouts?.forEach (timeout) -> setTimeout rplc, timeout
  setInterval rplc, repeat if repeat
  watchFutureNodes replaceFn if futureNodesToo

watchFutureNodes = (replaceFn) ->
  obsv = new MutationObserver (records) ->
    for rec in records
      switch rec.type
        when 'characterData'
          rec.target.data = replaceFn rec.target.data
        when 'childList'
          replaceAll replaceFn, rec.target if rec.addedNodes.length > 0
    null

module.exports =
  replaceAllFromNode: replaceAllFromNode
  replaceAllInPage: replaceAllInPage
  watchFutureNodes: watchFutureNodes
