`/Applications/love_12.app/Contents/MacOS/love ./testing`

# v0.2

## Todo
- finish graphics state methods
- start graphics drawing methods
- start object methods
- some joystick/input stuff could be at least nil checked maybe?
- add test run for linux, windows, + ios builds
- pass in err string returns to the test output
  maybe even assertNotNil could use the second value automatically
  test:assertNotNil(love.filesystem.openFile('file2', 'r')) wouldn't have to change


- need a platform: format table somewhere for compressed formats (i.e. DXT not supported)
  could add platform as global to command and then use in tests?
