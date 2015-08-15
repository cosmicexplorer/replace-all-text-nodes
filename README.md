replace-all-text-nodes
======================

Does what the name says.

# API

```javascript
function replaceAllFromNode(replaceFn, baseNode, opts) {
```
- `replaceFn`: a function which replaces text. This can be done in any way desired. This works recursively downwards.
- `baseNode`: the node to begin the tree search at.
- `opts`: an object with any of the following keys:
  - `inputsToo`: if truthy, also modifies any input boxes. Note that this may cause performance issues or unexpected UI behavior as the user will have their text replaced while typing.

```javascript
function replaceAllInPage(replaceFn, opts) {
```
Applies `replaceAllFromNode` to `document`, subject to some options.
- `opts`: an object with any of the following keys:
  - `inputsToo`: forwards `inputsToo` to `replaceAll`
  - `notNow`: doesn't immediately call `replaceAll`
  - `timeouts`: array of milliseconds, at which replaceAll will run over the document again. These milliseconds are all relative to the point when this function was called, not to each other.
  - `repeat`: milliseconds to repeat running `replaceAllFromNode` (this is not encouraged; a `MutationObserver` used by `futureNodesToo` is preferable for performance reasons unless supporting older browsers which do not support `MutationObserver`)
  - `futureNodesToo`: adds a [MutationObserver](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver) to the page, mutating all elements added to the page. If this is specified, the function returns the `MutationObserver` used so that it can be cancelled as desired.

```javascript
function watchFutureNodes(replaceFn) {
```
Implementation of `futureNodesToo` in `replaceAllInPage`. Creates and returns a `MutationObserver` which applies `replaceFn` to any added or modified text nodes.
