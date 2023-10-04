-- @class - TestMethod
-- @desc - used to run a specific method from a module's /test/ suite
--         each assertion is tracked and then printed to output
TestMethod = {


  -- @method - TestMethod:new()
  -- @desc - create a new TestMethod object
  -- @param {string} method - string of method name to run
  -- @param {TestMethod} testmethod - parent testmethod this test belongs to
  -- @return {table} - returns the new Test object
  new = function(self, method, testmodule)
    local test = {
      testmodule = testmodule,
      method = method,
      asserts = {},
      start = love.timer.getTime(),
      finish = 0,
      count = 0,
      passed = false,
      skipped = false,
      skipreason = '',
      fatal = '',
      message = nil,
      result = {},
      colors = {
        red = {1, 0, 0, 1},
        green = {0, 1, 0, 1},
        blue = {0, 0, 1, 1},
        black = {0, 0, 0, 1},
        white = {1, 1, 1, 1}
      }
    }
    setmetatable(test, self)
    self.__index = self
    return test
  end,


  -- @method - TestMethod:assertEquals()
  -- @desc - used to assert two values are equals
  -- @param {any} expected - expected value of the test
  -- @param {any} actual - actual value of the test
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertEquals = function(self, expected, actual, label)
    self.count = self.count + 1
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = expected == actual,
      message = 'expected \'' .. tostring(expected) .. '\' got \'' .. 
        tostring(actual) .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertPixels()
  -- @desc - checks a list of coloured pixels agaisnt given imgdata
  -- @param {ImageData} imgdata - image data to check
  -- @param {table} pixels - map of colors to list of pixel coords, i.e.
  --                         { blue = { {1, 1}, {2, 2}, {3, 4} } }
  -- @return {nil}
  assertPixels = function(self, imgdata, pixels, label)
    for i, v in pairs(pixels) do
      local col = self.colors[i]
      local pixels = v
      for p=1,#pixels do
        local coord = pixels[p]
        local tr, tg, tb, ta = imgdata:getPixel(coord[1], coord[2])
        local compare_id = tostring(coord[1]) .. ',' .. tostring(coord[2])
        -- @TODO add some sort pixel tolerance to the coords
        self:assertEquals(col[1], tr, 'check pixel r for ' .. i .. ' at ' .. compare_id .. '(' .. label .. ')')
        self:assertEquals(col[2], tg, 'check pixel g for ' .. i .. ' at ' .. compare_id .. '(' .. label .. ')')
        self:assertEquals(col[3], tb, 'check pixel b for ' .. i .. ' at ' .. compare_id .. '(' .. label .. ')')
        self:assertEquals(col[4], ta, 'check pixel a for ' .. i .. ' at ' .. compare_id .. '(' .. label .. ')')
      end
    end
  end,


  -- @method - TestMethod:assertNotEquals()
  -- @desc - used to assert two values are not equal
  -- @param {any} expected - expected value of the test
  -- @param {any} actual - actual value of the test
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertNotEquals = function(self, expected, actual, label)
    self.count = self.count + 1
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = expected ~= actual,
      message = 'avoiding \'' .. tostring(expected) .. '\' got \'' ..
        tostring(actual) .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertRange()
  -- @desc - used to check a value is within an expected range
  -- @param {number} actual - actual value of the test
  -- @param {number} min - minimum value the actual should be >= to
  -- @param {number} max - maximum value the actual should be <= to
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertRange = function(self, actual, min, max, label)
    self.count = self.count + 1
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = actual >= min and actual <= max,
      message = 'value \'' .. tostring(actual) .. '\' out of range \'' ..
        tostring(min) .. '-' .. tostring(max) .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertMatch()
  -- @desc - used to check a value is within a list of values
  -- @param {number} list - list of valid values for the test
  -- @param {number} actual - actual value of the test to check is in the list
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertMatch = function(self, list, actual, label)
    self.count = self.count + 1
    local found = false
    for l=1,#list do
      if list[l] == actual then found = true end;
    end
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = found == true,
      message = 'value \'' .. tostring(actual) .. '\' not found in \'' ..
        table.concat(list, ',') .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertGreaterEqual()
  -- @desc - used to check a value is >= than a certain target value 
  -- @param {any} target - value to check the test agaisnt
  -- @param {any} actual - actual value of the test
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertGreaterEqual = function(self, target, actual, label)
    self.count = self.count + 1
    local passing = false
    if target ~= nil and actual ~= nil then
      passing = actual >= target
    end
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = passing,
      message = 'value \'' .. tostring(actual) .. '\' not >= \'' ..
        tostring(target) .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertLessEqual()
  -- @desc - used to check a value is <= than a certain target value 
  -- @param {any} target - value to check the test agaisnt
  -- @param {any} actual - actual value of the test
  -- @param {string} label - label for this test to use in exports
  -- @return {nil}
  assertLessEqual = function(self, target, actual, label)
    self.count = self.count + 1
    local passing = false
    if target ~= nil and actual ~= nil then
      passing = actual <= target
    end
    table.insert(self.asserts, {
      key = 'assert #' .. tostring(self.count),
      passed = passing,
      message = 'value \'' .. tostring(actual) .. '\' not <= \'' ..
        tostring(target) .. '\'',
      test = label
    })
  end,


  -- @method - TestMethod:assertObject()
  -- @desc - used to check a table is a love object, this runs 3 seperate 
  --         tests to check table has the basic properties of an object
  -- @note - actual object functionality tests are done in the objects module
  -- @param {table} obj - table to check is a valid love object
  -- @return {nil}
  assertObject = function(self, obj)
    self:assertNotEquals(nil, obj, 'check not nill')
    self:assertEquals('userdata', type(obj), 'check is userdata')
    if obj ~= nil then 
      self:assertNotEquals(nil, obj:type(), 'check has :type()')
    end
  end,



  -- @method - TestMethod:skipTest()
  -- @desc - used to mark this test as skipped for a specific reason
  -- @param {string} reason - reason why method is being skipped
  -- @return {nil}
  skipTest = function(self, reason)
    self.skipped = true
    self.skipreason = reason
  end,


  -- @method - TestMethod:evaluateTest()
  -- @desc - evaluates the results of all assertions for a final restult
  -- @return {nil}
  evaluateTest = function(self)
    local failure = ''
    local failures = 0
    for a=1,#self.asserts do
      -- @TODO just return first failed assertion msg? or all?
      -- currently just shows the first assert that failed
      if self.asserts[a].passed == false and self.skipped == false then
        if failure == '' then failure = self.asserts[a] end
        failures = failures + 1
      end
    end
    if self.fatal ~= '' then failure = self.fatal end
    local passed = tostring(#self.asserts - failures)
    local total = '(' .. passed .. '/' .. tostring(#self.asserts) .. ')'
    if self.skipped == true then
      self.testmodule.skipped = self.testmodule.skipped + 1
      love.test.totals[3] = love.test.totals[3] + 1
      self.result = { 
        total = '', 
        result = "SKIP", 
        passed = false, 
        message = '(0/0) - method skipped [' .. self.skipreason .. ']'
      }
    else
      if failure == '' and #self.asserts > 0 then
        self.passed = true
        self.testmodule.passed = self.testmodule.passed + 1
        love.test.totals[1] = love.test.totals[1] + 1
        self.result = { 
          total = total, 
          result = 'PASS', 
          passed = true, 
          message = nil
        }
      else
        self.passed = false
        self.testmodule.failed = self.testmodule.failed + 1
        love.test.totals[2] = love.test.totals[2] + 1
        if #self.asserts == 0 then
          local msg = 'no asserts defined'
          if self.fatal ~= '' then msg = self.fatal end
          self.result = { 
            total = total, 
            result = 'FAIL', 
            passed = false, 
            key = 'test', 
            message = msg 
          }
        else
          local key = failure['key']
          if failure['test'] ~= nil then
            key = key .. ' [' .. failure['test'] .. ']'
          end
          self.result = { 
            total = total, 
            result = 'FAIL', 
            passed = false, 
            key = key,
            message = failure['message']
          }
        end
      end
    end
    self:printResult()
  end,


  -- @method - TestMethod:printResult()
  -- @desc - prints the result of the test to the console as well as appends
  --         the XML + HTML for the test to the testsuite output
  -- @return {nil}
  printResult = function(self)

    -- get total timestamp
    -- @TODO make nicer, just need a 3DP ms value 
    self.finish = love.timer.getTime() - self.start
    love.test.time = love.test.time + self.finish
    self.testmodule.time = self.testmodule.time + self.finish
    local endtime = tostring(math.floor((love.timer.getTime() - self.start)*1000))
    if string.len(endtime) == 1 then endtime = '   ' .. endtime end
    if string.len(endtime) == 2 then endtime = '  ' .. endtime end
    if string.len(endtime) == 3 then endtime = ' ' .. endtime end

    -- get failure/skip message for output (if any)
    local failure = ''
    local output = ''
    if self.passed == false and self.skipped == false then
      failure = '\t\t\t<failure message="' .. self.result.key .. ' ' ..
        self.result.message .. '"></failure>\n'
        output = self.result.key .. ' ' ..  self.result.message
    end
    if output == '' and self.skipped == true then
      output = self.skipreason
    end

    -- append XML for the test class result
    self.testmodule.xml = self.testmodule.xml .. '\t\t<testclass classname="' ..
      self.method .. '" name="' .. self.method ..
      '" time="' .. tostring(self.finish*1000) .. '">\n' ..
      failure .. '\t\t</testclass>\n'

    -- unused currently, adds a preview image for certain graphics methods to the output
    local preview = ''
    -- if self.testmodule.module == 'graphics' then
    --   local filename = 'love_test_graphics_rectangle'
    --   preview = '<div class="preview">' .. '<img src="' .. filename .. '_expected.png"/><p>Expected</p></div>' ..
    --     '<div class="preview"><img src="' .. filename .. '_actual.png"/><p>Actual</p></div>'
    -- end

    -- append HTML for the test class result 
    local status = '🔴'
    local cls = 'red'
    if self.passed == true then status = '🟢'; cls = '' end
    if self.skipped == true then status = '🟡'; cls = '' end
    self.testmodule.html = self.testmodule.html ..
      '<tr class=" ' .. cls .. '">' ..
        '<td>' .. status .. '</td>' ..
        '<td>' .. self.method .. '</td>' ..
        '<td>' .. tostring(self.finish*1000) .. 'ms</td>' ..
        '<td>' .. output .. preview .. '</td>' ..
      '</tr>'

    -- add message if assert failed
    local msg = ''
    if self.result.message ~= nil and self.skipped == false then
      msg = ' - ' .. self.result.key ..
        ' failed - (' .. self.result.message .. ')'
    end
    if self.skipped == true then
      msg = self.result.message
    end

    -- log final test result to console
    -- i know its hacky but its neat soz
    local tested = 'love.' .. self.testmodule.module .. '.' .. self.method .. '()'
    local matching = string.sub(self.testmodule.spacer, string.len(tested), 40)
    self.testmodule:log(
      self.testmodule.colors[self.result.result],
      '  ' .. tested .. matching,
      ' ==> ' .. self.result.result .. ' - ' .. endtime .. 'ms ' ..
      self.result.total .. msg
    )
  end


}