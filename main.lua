-- & 'c:\Program Files\LOVE\love.exe' ./ --console 
-- /Applications/love.app/Contents/MacOS/love ./
require('lovetest')
require('classes.suite')
require('classes.test')
require('tests.audio')
require('tests.data')
require('tests.event')
require('tests.filesystem')
require('tests.font')
require('tests.graphics')
require('tests.image')
require('tests.math')
require('tests.physics')
require('tests.sound')
require('tests.system')
require('tests.thread')
require('tests.timer')
require('tests.video')
require('tests.window')

love.load = function(args)

  local testcmd = '--runAllTests'
  local module = ''
  local method = ''
  local modules = {
    'audio', 'data', 'event', 'filesystem', 'font', 'graphics',
    'image', 'math', 'objects', 'physics', 'sound', 'system',
    'thread', 'timer', 'video', 'window'
  }
  local disable = false
  local disabled = {}
  for a=1,#args do
    if testcmd == '--runSpecificMethod' then
      if module == '' and love[args[a]] ~= nil then 
        module = args[a] 
        table.insert(modules, module)
      end
      if module ~= '' and love[module][args[a]] ~= nil and method == '' then method = args[a] end
      if module ~= '' and method ~= '' and disable == true then
        table.insert(disabled, args[a])
      end
    end
    if testcmd == '--runSpecificModule' then
      if module == '' and love[args[a]] ~= nil then 
        module = args[a]
        table.insert(modules, module)
      end
      if module ~= '' and disable == true then
        table.insert(disabled, args[a])
      end
    end
    if testcmd == '--runSpecificModules' then
      if love[args[a]] ~= nil and disable == false then table.insert(modules, args[a]) end
      if disable == true then
        table.insert(disabled, args[a])
      end
    end
    if args[a] == '--runSpecificMethod' then
      testcmd = args[a]
      modules = {}
    end
    if args[a] == '--runSpecificModule' then
      testcmd = args[a]
      modules = {}
    end
    if args[a] == '--runSpecificModules' then
      testcmd = args[a]
      modules = {}
    end
    if args[a] == '--disableModules' then
      disable = true
    end
  end

  local actualdisabled = {}
  for d=1,#disabled do
    local inlist = false
    for m=1,#modules do
      if modules[m] == disabled[d] then inlist = true break end
    end
    if disabled[d] ~= module and inlist == false then
      love[disabled[d]] = nil
      table.insert(actualdisabled, disabled[d])
    end
  end

  -- runSpecificMethod [module] [method]
  if testcmd == '--runSpecificMethod' then
    local testsuite = love.test.Suite:new()
    table.insert(love.test.testsuites, testsuite)
    love.test.testsuite = testsuite
    love.test.testsuite:log('grey', '--runSpecificMethod "' .. module .. '" "' .. method .. '"')
    love.test.output = 'lovetest_runSpecificMethod_' .. module .. '_' .. method
    if #actualdisabled > 0 then love.test.testsuite:log('grey', '--disableModules "' .. table.concat(actualdisabled, '" "') .. '"') end
    love.test.testsuite:runTests(module, method)
  end

  ---- runSpecificModule [module]
  if testcmd == '--runSpecificModule' then
    local testsuite = love.test.Suite:new()
    table.insert(love.test.testsuites, testsuite)
    love.test.testsuite = testsuite
    love.test.testsuite:log('grey', '--runSpecificModule "' .. module .. '"')
    love.test.output = 'lovetest_runSpecificModule_' .. module
    if #actualdisabled > 0 then love.test.testsuite:log('grey', '--disableModules "' .. table.concat(actualdisabled, '" "') .. '"') end
    love.test.testsuite:runTests(module)
  end

  ---- runSpecificModules [module1] [module2] [module3]
  if testcmd == '--runSpecificModules' then
    local modulelist = {}
    for m=1,#modules do
      local testsuite = love.test.Suite:new(modules[m])
      table.insert(love.test.testsuites, testsuite)
      table.insert(modulelist, modules[m])
    end
    love.test.testsuite = love.test.testsuites[1]
    love.test.testsuite:log('grey', '--runSpecificModules "' .. table.concat(modulelist, '" "') .. '"')
    love.test.output = 'lovetest_runSpecificModules_' .. table.concat(modulelist, '_')
    if #actualdisabled > 0 then love.test.testsuite:log('grey', '--disableModules "' .. table.concat(actualdisabled, '" "') .. '"') end
    love.test.testsuite:runTests(love.test.testsuite.module)
  end

  ---- runAllTests
  if args[1] == nil or args[1] == '' or args[1] == '--runAllTests' then
    for m=1,#modules do
      local testsuite = love.test.Suite:new(modules[m])
      table.insert(love.test.testsuites, testsuite)
    end
    love.test.testsuite = love.test.testsuites[1]
    love.test.testsuite:log('grey', '--runAllTests')
    love.test.output = 'lovetest_runAllTests'
    if #actualdisabled > 0 then love.test.testsuite:log('grey', '--disableModules "' .. table.concat(actualdisabled, '" "') .. '"') end
    love.test.testsuite:runTests(love.test.testsuite.module)
  end

end

love.update = function(delta)

  -- stagger to between tests
  if love.test.testsuite ~= nil then
    love.test.testsuite.time = love.test.testsuite.time + delta
    if love.test.testsuite.time >= love.test.testsuite.delay then
      love.test.testsuite.time = love.test.testsuite.time - love.test.testsuite.delay
      if love.test.testsuite.start == true then
        -- work through each test method 1 by 1
        if love.test.testsuite.index <= #love.test.testsuite.running then
          -- run method once
          if love.test.testsuite.called[love.test.testsuite.index] == nil then
            love.test.testsuite.called[love.test.testsuite.index] = true
            local method = love.test.testsuite.running[love.test.testsuite.index]
            local test = love.test.Test:new(method, love.test.testsuite)
            -- check method exists in love first
            if love[love.test.testsuite.module] == nil or love[love.test.testsuite.module][method] == nil then
              local tested = 'love.' .. love.test.testsuite.module .. '.' .. method .. '()' 
              local matching = string.sub(love.test.testsuite.spacer, string.len(tested), 40)
              love.test.testsuite:log(love.test.testsuite.colors['FAIL'],
                tested .. matching,
                ' ==> FAIL (0/0) - call failed - method does not exist'
              )
            -- otherwise run the test method then eval the asserts
            else
              love.test[love.test.testsuite.module][method](test)
              test:evaluateTest()
            end
            -- move onto the next test
            love.test.testsuite.index = love.test.testsuite.index + 1
          end
        else
          -- all tests done, print totals
          love.test.testsuite:log('yellow', 'love.' .. love.test.testsuite.module .. '.testsuite.end')
          local failedcol = '\27[31m'
          if love.test.testsuite.failed == 0 then failedcol = '\27[30m' end
          love.test.testsuite:log('green', tostring(love.test.testsuite.passed) .. ' PASSED' .. ' || ' .. 
            failedcol .. tostring(love.test.testsuite.failed) .. ' FAILED || \27[30m' .. 
            tostring(love.test.testsuite.skipped) .. ' SKIPPED')
          love.test.testsuite.start = false
          love.test.testsuite.fakequit = false

          
          love.test.xml = love.test.xml .. '\t<testsuite name="love.' .. love.test.testsuite.module .. 
            '" tests="' .. tostring(love.test.testsuite.passed) .. 
            '" failures="' .. tostring(love.test.testsuite.failed) .. 
            '" skipped="' .. tostring(love.test.testsuite.skipped) ..
            '" time="' .. tostring(love.test.testsuite.time*1000) .. '">\n' .. love.test.testsuite.xml .. '\t</testsuite>\n'

          local status = '🔴'
          if love.test.testsuite.failed == 0 then status = '🟢' end
          love.test.html = love.test.html .. '<h2>' .. status .. '&nbsp;love.' .. love.test.testsuite.module .. '</h2><ul class="summary">' ..
            '<li>🟢&nbsp;' .. tostring(love.test.testsuite.passed) .. ' Tests</li>' ..
            '<li>🔴&nbsp;' .. tostring(love.test.testsuite.failed) .. ' Failures</li>' ..
            '<li>🟡&nbsp;' .. tostring(love.test.testsuite.skipped) .. ' Skipped</li>' ..
            '<li>' .. tostring(love.test.testsuite.time*1000) .. 'ms</li>' .. '<ul><br/><br/>' ..
            '<table><thead><tr><td width="20px"></td><td width="100px">Method</td><td width="100px">Time</td><td>Details</td></tr></thead><tbody>' ..
            love.test.testsuite.html .. '</tbody></table>'

          love.test.current = love.test.current + 1
          if #love.test.testsuites >= love.test.current then
            love.test.testsuite = love.test.testsuites[love.test.current]
            love.test.testsuite:runTests(love.test.testsuite.module)
          else 
            local finaltime = tostring(math.floor(love.test.time*1000))
            if string.len(finaltime) == 1 then finaltime = '   ' .. finaltime end
            if string.len(finaltime) == 2 then finaltime = '  ' .. finaltime end
            if string.len(finaltime) == 3 then finaltime = ' ' .. finaltime end

            local header = '<testsuites name="love.test" tests="' .. tostring(love.test.totals[1]) .. 
              '" failures="' .. tostring(love.test.totals[2]) .. 
              '" skipped="' .. tostring(love.test.totals[3]) .. 
              '" time="' .. tostring(love.test.time*1000) .. '">\n'
            love.filesystem.write(love.test.output .. '.xml', header .. love.test.xml .. '</testsuites>')

            local status = '🔴'
            if love.test.totals[2] == 0 then status = '🟢' end
            local html = '<html><head><style>* { font-family: monospace; margin: 0; font-size: 11px; padding: 0; } body { margin: 50px; } h1 { padding-bottom: 10px; font-size: 13px; } h2 { padding: 20px 0 10px 0; font-size: 12px; } .summary { list-style: none; margin: 0; padding: 0; } .summary li { float: left; background: #eee; padding: 5px; margin-right: 10px; } table { background: #eee; margin-top: 10px; width: 100%; max-width: 800px; border-collapse: collapse } table thead { background: #ddd; } table th, table td { padding: 2px; } tr.red { color: red } .wrap { max-width: 800px; margin: auto; } .preview { width: 64px; height: 80px; float: left; margin-right: 10px; } .preview img { width: 100% } .preview p { text-align: center; }</style></head><body><div class="wrap"><h1>' .. status .. '&nbsp;love.test</h1><ul class="summary">'
            html = html .. 
              '<li>🟢&nbsp;' .. tostring(love.test.totals[1]) .. ' Tests</li>' ..
              '<li>🔴&nbsp;' .. tostring(love.test.totals[2]) .. ' Failures</li>' ..
              '<li>🟡&nbsp;' .. tostring(love.test.totals[3]) .. ' Skipped</li>' ..
              '<li>' .. tostring(love.test.time*1000) .. 'ms</li></ul><br/><br/>'
            love.filesystem.write(love.test.output .. '.html', html .. love.test.html .. '</div></body></html>')

            love.test.testsuite:log('grey', '\nFINISHED - ' .. finaltime .. 'ms\n')
            local failedcol = '\27[31m'
            if love.test.totals[2] == 0 then failedcol = '\27[30m' end
            love.test.testsuite:log('green', tostring(love.test.totals[1]) .. ' PASSED' .. ' || ' .. failedcol .. tostring(love.test.totals[2]) .. ' FAILED || \27[30m' .. tostring(love.test.totals[3]) .. ' SKIPPED')
            love.event.quit(0)
          end

        end
      end
    end
  end

end


love.draw = function()
  if love.test.testcanvas ~= nil then
    love.graphics.draw(love.test.testcanvas, 0, 0)
  else
    love.graphics.draw(logo_texture, logo_image, 64, 64, 0, 2, 2)
  end
end


love.quit = function()
  if love.test.testsuite ~= nil and love.test.testsuite.fakequit == true then
    return true
  else
    return false
  end
end