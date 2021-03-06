React = require 'react'
_ = require 'lodash'
invariant = require 'invariant'
mousetrap = require 'mousetrap'

shortcuts = React.createFactory 'shortcuts'

module.exports = React.createClass

  displayName: 'Shortcuts'

  contextTypes:
    shortcuts: React.PropTypes.object.isRequired

  propTypes:
    handler: React.PropTypes.func.isRequired
    name: React.PropTypes.string.isRequired
    element: React.PropTypes.func
    tabIndex: React.PropTypes.number
    className: React.PropTypes.string
    eventType: React.PropTypes.string
    stopPropagation: React.PropTypes.bool
    preventDefault: React.PropTypes.bool
    targetNode: React.PropTypes.object
    nativeKeyBindingsClassName: React.PropTypes.string

  getDefaultProps: ->
    element: null
    tabIndex: null
    className: null
    eventType: null
    stopPropagation: null
    preventDefault: true
    targetNode: null
    nativeKeyBindingsClassName: 'native-key-bindings'

  _bindShortcuts: (shortcutsArr) ->
    if @props.targetNode
      element = @props.targetNode
      invariant(element, 'TargetNode was not found.')
      element.setAttribute('tabindex', @props.tabIndex or -1)
    else
      element = React.findDOMNode(@refs.shortcuts)

    @_monkeyPatchMousetrap()
    mousetrap(element).bind(shortcutsArr, @_handleShortcuts, @props.eventType)

  # TODO: create a pull request on mousetrap's github page
  _monkeyPatchMousetrap: ->
    mousetrap::stopCallback = (e, element) =>
      result = _.includes(element.className, @props.nativeKeyBindingsClassName)
      return result

  _unbindShortcuts: (shortcutsArr) ->
    if @props.targetNode
      @props.targetNode.removeAttribute('tabindex')
    else
      element = React.findDOMNode(@refs.shortcuts)
    mousetrap(element).unbind(shortcutsArr)

  _onUpdate: ->
    shortcutsArr = @context.shortcuts.getShortcuts(@props.name)
    @_unbindShortcuts(shortcutsArr)
    @_bindShortcuts(shortcutsArr)

  componentDidMount: ->
    shortcutsArr = @context.shortcuts.getShortcuts(@props.name)
    @_bindShortcuts(shortcutsArr)
    @context.shortcuts.addUpdateListener(@_onUpdate)

  componentWillUnmount: ->
    shortcutsArr = @context.shortcuts.getShortcuts(@props.name)
    @_unbindShortcuts(shortcutsArr)
    @context.shortcuts.removeUpdateListener(@_onUpdate)

  _handleShortcuts: (e, keyName) ->
    e.preventDefault() if @props.preventDefault
    e.stopPropagation() if @props.stopPropagation
    shortcutName = @context.shortcuts.findShortcutName(keyName, @props.name)
    @props.handler(shortcutName)

  render: ->
    element = shortcuts
    element = @props.element if _.isFunction(@props.element)

    element
      tabIndex: @props.tabIndex or -1
      className: @props.className
      ref: 'shortcuts',

      @props.children
