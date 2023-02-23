local second = require("second")
print(second)
require("second")
local third = require("third")
print(third)
require("third")
package.loaded["third"] = nil
require("third")
local inner = require("nested.inner")
print(inner)
for key, value in pairs(package.loaded) do
  print(key, value)
end
