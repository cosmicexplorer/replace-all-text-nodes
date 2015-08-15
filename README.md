replace-all-text-nodes
======================

Does what the name says.

# API

```
replaceAllFromNode = (replaceFn, baseNode, opts) ->
```
- `replaceFn`: a function which replaces text. This can be done in any way desired. This works recursively downwards.
- `baseNode`: the node to begin the tree search at.
- `opts`: an object with any of the following keys:
  - `noInputs`: if truthy, disregards any input boxes. This allows the user to type into input areas without having their text replaced.

```
replaceAllInPage = (replaceFn, opts) ->
```
Applies replaceAll to the document at hand, subject to some options.
- `opts`: an object with any of the following keys:
  - `noInputs`: forwards `noInputs` to `replaceAll`
  - `notNow`: doesn't immediately call `replaceAll`
  - `timeouts`: array of milliseconds, at which replaceAll will run over the document again. These milliseconds are all relative to the point when this function was called, not to each other.
  - `repeat`: milliseconds to repeat running replaceAll (this is not suggested; a `MutationObserver` used by `futureNodesToo` is preferable for performance reasons unless used in older browsers which do not support `MutationObserver`)
  - `futureNodesToo`: adds a [MutationObserver](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver) to the page, mutating all elements added to the page. If this is specified, the function returns the `MutationObserver` used so that it can be cancelled as desired.

```
watchFutureNodes = (replaceFn) ->
```
Implementation of `futureNodesToo` in `replaceAllInPage`. Creates and returns a `MutationObserver` which applies `replaceFn` to any added or modified text nodes.
