keymap = require './keymap'
ShortcutManager = require '../src'

describe 'Shortcut manager: ', ->

  it 'should return empty object when calling empty constructor', ->
    manager = new ShortcutManager()
    expect(manager._keymap).toExist(_.isEqual(manager._keymap, {}))

  it 'should return _keymap obj that is not empty', ->
    manager = new ShortcutManager(keymap)
    expect(manager._keymap).toExist(not _.isEmpty(manager._keymap))

  it 'should expose the change event type as a static constant', ->
    expect(ShortcutManager.CHANGE_EVENT).toExist()

  it 'CHANGE_EVENT: should have static CHANGE_EVENT with defined value', ->
    expect(ShortcutManager.CHANGE_EVENT).toBe('shortcuts:update')

  it 'emitUpdate: should call onUpdate when update called', ->
    manager = new ShortcutManager()
    spy = expect.createSpy()
    manager.addUpdateListener(spy)
    manager.setKeymap(true)
    expect(spy).toHaveBeenCalled()

  it 'setKeymap: should throw an error when setKeymap called without arg', ->
    manager = new ShortcutManager(keymap)
    error = /Error: Invariant Violation: setKeymap: keymap argument is not defined or falsy./
    expect(manager.setKeymap).toThrow(error)

  it 'add: should throw an error when `add` is called with no arguments', ->
    manager = new ShortcutManager(keymap)
    error = /Error: Invariant Violation: setKeymap: keymap argument is not defined or falsy/
    expect(manager.setKeymap).toThrow(error)

  it 'add: should return _keymap obj that is not empty', ->
    manager = new ShortcutManager()
    manager.setKeymap(keymap)
    expect(manager._keymap).toExist(not _.isEmpty(manager._keymap))

  it 'getAllShortcuts: should return _keymap that is not empty', ->
    manager = new ShortcutManager(keymap)
    expect(manager.getAllShortcuts()).toExist(not _.isEmpty(manager._keymap))

  it 'getShortcuts: should return array of shortcuts', ->
    manager = new ShortcutManager(keymap)
    arr = manager.getShortcuts('Test')
    expect(_.isArray(arr)).toBe(true)
    shouldContainStrings = _.every(arr, _.isString)
    expect(shouldContainStrings).toBe(true)
    expect(arr.length).toBe(5)

    arr = manager.getShortcuts('Next')
    expect(_.isArray(arr)).toBe(true)
    shouldContainStrings = _.every(arr, _.isString)
    expect(shouldContainStrings).toBe(true)
    expect(arr.length).toBe(5)

  it 'getShortcuts: should throw an error', ->
    manager = new ShortcutManager(keymap)
    notExist = ->
      manager.getShortcuts('NotExist')
    expect(notExist).toThrow(/Error: Invariant Violation: getShortcuts: There are no shortcuts with name NotExist./)

  it 'findShortcutName: should return correct key label', ->
    manager = new ShortcutManager()
    manager.setKeymap(keymap)

    # Test
    expect(manager.findShortcutName('alt+backspace', 'Test')).toBe('DELETE')
    expect(manager.findShortcutName('w', 'Test')).toBe('MOVE_UP')
    expect(manager.findShortcutName('up', 'Test')).toBe('MOVE_UP')
    expect(manager.findShortcutName('left', 'Test')).toBe('MOVE_LEFT')
    expect(manager.findShortcutName('right', 'Test')).toBe('MOVE_RIGHT')

    # Next
    expect(manager.findShortcutName('alt+o', 'Next')).toBe('OPEN')
    expect(manager.findShortcutName('d', 'Next')).toBe('ABORT')
    expect(manager.findShortcutName('c', 'Next')).toBe('ABORT')
    expect(manager.findShortcutName('esc', 'Next')).toBe('CLOSE')
    expect(manager.findShortcutName('enter', 'Next')).toBe('CLOSE')


  it 'findShortcutName: should throw an error', ->
    manager = new ShortcutManager()
    fn = ->
      manager.findShortcutName('left')
    expect(manager.findShortcutName).toThrow(/Error: Invariant Violation: findShortcutName: keyName argument is not defined or falsy./)
    expect(fn).toThrow(/Error: Invariant Violation: findShortcutName: componentName argument is not defined or falsy./)
