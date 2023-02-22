# learn-lua

LUA 语言的简单入门指南

## 前言

LUA 是一门脚本语言，对于习惯编写 javascript 等脚本语言代码的同学来说，上手 LUA 应该会非常快。
LUA 也是一门非常精简的语言，以至于了解整个语言的概貌可能真的只需要半天时间，这里我以一个前端开发者的角度出发，来对 LUA 语言做一个简单的概括。

### 1. 类型

一门语言都有其支持的数据类型，LUA 支持的基础数据类型包括：

1. `number` 数字类型，双精度浮点数，也可以让 lua 编译器很方便地支持单精度浮点数、长整数等数字数据类型
2. `boolean` 布尔类型，`true` 或者 `false`
3. `string` 字符串类型，内部实现就是一个由字符组成的数组表
4. `table` 表类型，lua 的表类型与 js 里的 Map 类型类似，实现了关联数组的功能。除了 `nil` 类型不能当成表的 key，其它类型都可以
5. `nil` 空类型，只有一个值 `nil`，与 js 里的 null 有点类似
6. `function` 函数类型，在 lua 里函数也是一等公民，可以当成函数参数、返回值、也可以在表达式中直接使用
7. `thread` lua 协程返回类型
8. `userdata`

lua 使用全局的 `type` 方法来获取数据的类型，类型的值为上述 8 种值之一。

```lua
-- nil
type(undef_var) == "nil"; -- 未定义变量默认值为nil
type(nil) == "nil"; -- nil值
-- 布尔
type(true) == "boolean";
type(false) == "boolean";
-- 数字
type(1) == "number"
type(1.2) == "number"
type(-5) == "number"
type(2e5) == "number"
type(tonumber("075", 8)) == "number"
-- 字符串
type("abc") == "string"
type(tostring(true)) == "string"
-- 函数
type(type) == "function"
type(function() end) == "function"
-- table类型
type({ 0, 1, 2, 3 }) == "table"
type({
  "abc",
  monday = 1,
  ["2day"] = 2
}) == "table"
-- thread类型
type(coroutine.create(function() end)) == "thread"
--[[
@userdata
--]]
```

lua 中的注释：从上面的示例代码中可以看到，lua 语言支持两种注释方式：

- 单行注释：以两个短横杠 `--` 开头的
- 多行注释：以 `--[[` 开头，`--]]`（或者直接`]]`亦可）结尾

### 2. 变量定义

从最上面的示例 `type(undef_var) == "nil"` 中可以看到，在 lua 中，一个变量未经定义就可以使用，变量的默认值就是 `nil`（js 中变量未定义只有 `typeof` 操作符可以使用）。lua 中与变量声明有关的关键字只有 `local`，当一个变量使用了 `local` 关键字声明，它的作用域范围便被限制在了声明位置对应的代码块内，不使用 `local` 关键字声明的变量将成为全局变量（lua 的全局变量实现通过全局环境表变量表 `_G` 及 `_ENV` 组合实现）。

```lua
-- 不使用local关键字
-- 变量 A 为全局变量
A = 1
-- 变量 IncreaseA 为全局方法
function IncreaseA()
  A = A + 1
end

print(_G["A"]) -- 1
print(type(_G["IncreaseA"])) -- function

-- local定义的变量(包括函数)具有词法作用域
print(type(getGlobalD)) -- nil
local function getGlobalD()
  if type(D) == "nil" then
    D = "globalB"
  end
  return D
end

print(_G["D"]) -- nil

-- 函数体内定义的D没有使用local关键字
local d = getGlobalD()
print(_G["D"] == d) -- true

-- 代码块作用域
do
  local f = "local f"
  print(f) -- local f
end
print(f) -- nil
```

在理解了变量的作用域后，我们再来看看各种类型的变量是如何定义的（`thread`类型和`userdata`类型在后面的部分再介绍）。

1.  `nil`

    ```lua
    ---------nil---------
    local a
    local b = nil
    print(a)  -- nil, 未初始化的变量默认值为nil
    print(b)  -- nil, 显示声明变量值为nil
    print(not a, not b) -- true true
    ```

2.  `boolean`

    ```lua
    ---------boolean---------
    local flagT = true
    local flagF = false
    print(not flagF) -- true, 值nil和false是lua里唯二的两个条件判断假值
    ```

3.  `string`

    ```lua
    ---------string---------
    -- 字面量字符串
    local str = "字面量字符串"
    -- 多行字符串
    local multiStr = [[
      第一行
      第二行
      ...
    ]]
    -- 字符串连接
    local concatStr = str .. multiStr
    ```

4.  `number`

        ```lua
        ---------number---------
        local m = 100
        local n = 1e3
        if 0 then
          print("0 -> true") -- "0 -> true"
        else
          print("0 -> false")
        end
        ```

5.  `table`

    ```lua
    ---------table---------
    local t = { 1, 2, 3, 4 }
    print(t[1] == 1) -- true，Lua 的 table 表的数字索引从 1 开始
    -- 数字/以数字开头的字符串键/变量等，都需要使用中括号[]包裹
    -- []内支持表达式
    local ct = {
      "默认数字键", -- 默认索引从 1 开始
      t = "字符串键", -- 这里的 t 是字符串"t"
      [3] = "表达式数字键", -- 表达式键，值为数字 3
      [1+2] = "计算表达式作为键", -- 表达式键，先对表达式求值，值为 3，会覆盖上面的表达式键
      [t] = "使用表作为键", -- 此处的 t 是上面定义的 table 表变量 t
      "只按数字键递增，表达式不影响键值", -- 此处索引为 2
      "数字键的优先级高于表达式键", -- 这里的数字键高于表达式键，哪怕相同的值的表达式键出现在后面
      "当前键值优先级高于表达式键",
      [4] = "后出现的表达式键",
      ["t"] = "上述规则只适应数字键，字符串键仍按顺序确定优先级"
    }
    print(ct[t]) -- "使用表作为键"
    print(ct[3]) -- "数字键的优先级高于表达式键"
    print(ct[4]) -- "当前键值优先级高于表达式键"
    print(ct["t"]) -- "上述规则只适应数字键，字符串键仍按顺序确定优先级"
    ```

6.  `function`

    ```lua
    ---------function---------
    -- 常规方式定义
    local function namedFn()
      print("函数名称 namedFn")
    end

    -- 匿名函数
    local aFn = function()
    print("匿名函数")
    end

    -- 表方法
    local _M = {}
    function _M.test()
      print("表_M 的 test 方法")
    end
    -- 函数参数
    -- 这里使用 ... 来替代函数的剩余参数，实现了可变参数，类似 js 里的扩展运算符
    -- 注意在形参里 ... 符号只能出现在末尾
    local function testParams(a1, a2, ...)
      print("参数 a1=>", a1)
      print("参数 a2=>", a2)
      -- 可以将剩余参数 ... 直接传递给其它函数参数
      print("其它参数", ...)
      -- 可以提取某些参数
      local a3, a4 = ...
      print("参数 a3=>", a3)
      print("参数 a4=>", a4)
      -- 也可以将剩余参数传递给表
      local restArgs = { ... } -- 等价于 table.pack(...)，将剩余参数保存在表中
      for k, v in ipairs(restArgs) do
        print(k, v)
      end
      -- ... 也可以出现在非末尾的位置
      -- 这里 ... 只能获取到返回的第一个值
      local a3, a4 = ..., "new a4"
      print("*参数 a3=>", a3)
      print("*参数 a4=>", a4)
      -- 同样，在表中 ... 也只能获取到第一个返回值
      local restArgs = { ..., "new a4" }
      print(restArgs[1], restArgs[2]) -- restArgs[2]值为"new a4"
      -- 不管赋值语句，还是在表声明中，出现位置不在末尾的都相当于以下逻辑
      local expFirst = (...) -- 转换成表达式，只能获得第一个值
      local a3, a4 = expFirst, "new a4"
      local restArgs = { expFirst, "new a4"}
    end
    testParams("a1", "a2", "a3", "a4")
    testParams("a1", "a2", table.unpack({ "a3", "a4" })) -- 和上面等价，表中元素会逐个展开
    testParams("a1", "a2", (function() return "a3", "a4" end)()) -- 返回多个值的函数调用结果也可以直接被展开

    -- 函数返回值
    -- lua 的函数返回值可以有多个
    local function testReturn()
      return "a1", "a2", "a3"
      -- return table.unpack({ "a1", "a2", "a3" }) -- 和上面的返回值等价
    end
    local a1, a2, a3, a4 = testReturn() -- a1 = "a1", a2 = "a2", a3 = "a3", a4 = nil
    ```

#### 3. 操作符

表格说明：以下操作符的优先级按照从高到低排列，结合顺序里未标明的表示符合直觉的从左到右依序运算，`<-`符号表示运算顺序为从右到左

| 优先级 |                操作符                 | 运算顺序 | 示例                   | 说明                                                                     |
| :----- | :-----------------------------------: | :------- | :--------------------- | ------------------------------------------------------------------------ |
| 8      |                  `^`                  | <-       | 2 ^ 2 ^ 3              | 先算 2^3=8，再算 2^8=256                                                 |
| 7      |                 `not`                 | <-       | `not (2 > 1)`          | `not` 的优先级比比较运算符优先级高，所以例子中需要使用 `()` 来保证优先级 |
| 7      |        `-` (一元操作符，取负)         | <-       | `-1 + 2`               | `-` 一元操作符比二元运算符`+`优先级高，所以会先将 1 取负再与 2 相加      |
| 6      |               `*` , `/`               |          | `2 * 3 / 4`            | 乘法与除法                                                               |
| 5      |               `+` , `-`               |          | `2 + 3 - 4`            | 加法与减法                                                               |
| 4      |                 `..`                  |          | `"hello" .. " world!"` | 字符串连接                                                               |
| 3      | `<` , `>` , `==` , `<=` , `>=` , `~=` |          | `1 ~= 2`               | `~=` 表示不等于，这与我们平常语言经常见到的 `!=` 有点不一样              |
| 2      |                 `and`                 |          | `2 > 1 and 3 > 2`      |                                                                          |
| 1      |                 `or`                  |          | `2 > 1 or 1 > 2`       | `not`、`and`、 `or` 都采用了关键字来作为运算符                           |

这里大家可能发现里面缺少常见取模运算符 `%`，lua 官方文档里给的运算方式是 `a % b == a - math.floor(a / b) * b`；也缺少常见的位运算符，这依赖于所使用的 lua 解释器，在官方 lua 解释器中，`5.3` 版本支持了位运算符 `&`（按位与）、`|`（按位或）、`~`（二元运算符按位异或）、`<<`（左移）、`>>`（右移）、`~`（一元运算符按位非），`5.3` 以下版本需要使用 `bit32` 库提供的方法来做对应操作；如果解释器是 `luajit` 则需要使用它提供 `bit` 库。

#### 4. 流程控制与循环

1. `if` 条件判断

   ```lua
   local a = 2;
   if a > 2 then
      -- 条件1
   elseif a > 1 then
      -- 条件2
   else
      -- 都不满足的情况下
   end
   ```

2. `while` 循环

   ```lua
   local n = 10
   while n > 0 do
      print(n)
      n = n - 1
   end
   while n < 10 do
      print(n)
      -- lua循环支持break关键字，但不支持continue
      -- 可以使用 goto 关键字 + 标签的形式间接实现，但 goto 语句大家一般都建议少使用
      if n > 0 then
        break
      end
   end
   ```

3. `repeat & until` 循环

   ```lua
   local n = 10
   repeat
     print(n)
     n = n - 1
   until(n == 0)  -- until后条件为true时停止循环、这与 js 里的 `do while` 组合 while 里的表达式为 false 才停止循环相反
   ```

4. `for` 循环

   ```lua
   -- = 符号右侧可设置三个参数，起始值、结束值、步阶（默认为1）
   for n = 0, 10, 1 do
      print(n)
   end
   ```

#### 5. `for` 循环与迭代器
