local rpc = require("starter.rpc")
local util = require("common.util")
local Pipe = util.Pipe

function table.equals(t1, t2)
	for k, _ in pairs(t1) do
		local b
		if type(t1[k]) == "table" then
			b = table.equals(t1[k], t2[k])
		else
			b = t1[k] == t2[k]
		end
		if not b then return false end
	end
	return true
end

function serialize_tests()
	local i = 0 
	function check(v)
		r = rpc.serialize(v)
		--print(r)
		result = rpc.deserialize(r)
		--print(result)
		if type(v) == "table" then
			assert(table.equals(v, result))
		else
			assert(v == result)
		end
		i = i + 1
		print("成功数"..i)
	end

	check(0)
	check("Test")
	check(true)
	check(nil)
	check({a = nil})
	check({a = 1})
	check({a = "="})
	check({a = ","})
	check({a = "=", b = "#"})
	check({a = {b = 1}, c = 2})
	check({a = 1, b = {}})
	check({1, 2, false})
	check({foo = "bar", 2})
	check({a = {b = {c = 2, t = 0.8 , x = false,}}, c = {a = 5, "as"}})
	check({a = {b = {}}})
	check({result = "return 2#2"})
end

function rpc_tests()
	local MyClass = {}

	function MyClass.new()
		return {counter = 0}
	end

	function MyClass.hello(t)
		return "Hi"
	end

	function MyClass.incr(t)
		t.counter = t.counter + 1
		return t.counter
	end

	local MyClassRPC = rpc.rpcify(MyClass)

	local inst = MyClassRPC.new()

	assert(MyClassRPC.hello(inst) == "Hi")

	local future = MyClassRPC.hello_async(inst)
	assert(future() == "Hi")

	assert(1 == MyClassRPC.incr(inst))
	assert(2 == MyClassRPC.incr(inst))

	MyClassRPC.exit(inst)
	print("test_1 pass")
end

function rpc_tests_2()
	local MyClass = {}

	function MyClass.new()
		return {counter = 0}
	end

	function MyClass.hello(t, name)
		local ans = "Hi " .. name
		return ans 
	end

	function MyClass.incr(t, val)
		t.counter = t.counter + val
		return t.counter
	end

	local MyClassRPC = rpc.rpcify(MyClass)

	local inst = MyClassRPC.new()

	assert(MyClassRPC.hello(inst, "zr") == "Hi zr")

	local future = MyClassRPC.hello_async(inst, "zr")
	assert(future() == "Hi zr")

	assert(2 == MyClassRPC.incr(inst, 2))
	assert(5 == MyClassRPC.incr(inst, 3))

	MyClassRPC.exit(inst)
	print("test_2 pass")
end

serialize_tests()
rpc_tests()
rpc_tests_2()
