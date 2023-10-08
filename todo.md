`/Applications/love_12.app/Contents/MacOS/love ./testing`

## TESTSUITE
- [ ] setStencilMode to replace setStencilTest
- [ ] start graphics drawing methods
- [ ] move object methods to respective modules
- [ ] start object methods

## GRAPHICS
Methods that need a better actual graphics check if possible:
- [ ] setDepthMode
- [ ] setFrontFaceWinding
- [ ] setMeshCullMode

## FUTURE
- [ ] need a platform: format table somewhere for compressed formats (i.e. DXT not supported)
      could add platform as global to command and then use in tests?
- [ ] use coroutines for the delay action? i.e. wrap each test call in coroutine 
      and then every test can use coroutine.yield() if needed
- [ ] could nil check some joystick and keyboard methods?

## GITHUB ACTION CI
- [ ] linux needs to run xvfb-run with the appimage
- [ ] try vulkan on windows/linux
- [ ] ios test run?

## NOTES
Can't run --renderers metal on github action images:
Run love-macos/love.app/Contents/MacOS/love testing --renderers metal
Cannot create Metal renderer: Metal is not supported on this system.
Cannot create graphics: no supported renderer on this system.
Error: Cannot create graphics: no supported renderer on this system.
