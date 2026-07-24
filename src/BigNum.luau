--!optimize 2
--!native

--[[
				General information
				
	Creator: @FoundForces
	Name: BigNum Library
	Description: A library to handle numbers upto 10^2^1024

	How it works: 
		BigNum is a table with 2 fields:
			1. sign: 
				A number representing the sign of the number (-1, 0, 1)
				
			2. exponent: 
				A number representing the exponent of the number
				The exponent is log10 of x
				For example, 1234 has an exponent of 3.091315159697223 (10^3.0913.. = 1234)
		
		Mathematical representation:
		sign * 10^exponent = number
		For example, -1234 = {-1, 3.091315159697223}
		
	For a function list look down below.
]]

local module = {}

--[[
				CONFIG

	POW_ZERO: Value of 0^0 (default: 0)
	precision: Digits of precision for toNumber(BN)
	display_precision: Digits of precision for toScientific, toEngineer, toSuffix
]]

module.POW_ZERO = { 0, 0 } -- 0^0
module.precision = 5 -- 5 digits
module.display_precision = 2 -- 2 digits

--[[
			Functions
		
	Some functions have a more detailed description at their definition below.
			
Converting:
	fromNumber(number: number) -> BN -- Converts a number to BigNum
	toNumber(BN: BN) -> number -- Converts a BigNum to number
	fromString(str: string) -> BN -- Converts a string to BigNum
	toString(BN: BN) -> string -- Converts a string to BigNum
	toBN(BN: any) -> BN -- Converts generic input to BigNum
	
Arithmatic:
	add(BN1: BN, BN2: BN) -> BN -- a + b 
	sub(BN1: BN, BN2: BN) -> BN -- a - b 
	mul(BN1: BN, BN2: BN) -> BN -- a * b 
	div(BN1: BN, BN2: BN) -> BN -- a / b 
	intdiv(BN1: BN, BN2: BN) -> BN -- a // b 
	pow(BN1: BN, BN2: BN) -> BN -- a ^ b 
	powf(BN1: BN, x: number) -> BN -- a ^ b 
	pow10(BN: BN) -> BN -- 10^a 
	sqrt(BN: BN) -> BN -- v(a)  (square root)
	root(BN1: BN, BN2: BN) -> BN -- bv(a) (b'th root of a)
	neg(BN: BN) -> BN -- -a
	abs(BN: BN) -> BN -- |a|
	mod(BN1: BN, BN2: BN) -> BN -- a % b 
	recip(BN: BN) -> BN -- 1/a
	fact(BN: BN) -> BN -- a!
	log(BN: BN, base?: BN) -> BN -- log_a(b)
	exp(BN: BN) -> BN -- e^a
	log10(BN: BN) -> BN -- log_10(a)
	log2(BN: BN) -> BN -- log_2(a)

Rounding: 
	round(BN: BN) -> BN -- Round to nearest integer
	floor(BN: BN) -> BN -- Round down to nearest integer
	ceil(BN: BN) -> BN -- Round up to nearest integer

Comparison:
	eq(BN1: BN, BN2: BN) -> boolean -- a == b
	lt(BN1: BN, BN2: BN) -> boolean -- a < b
	gt(BN1: BN, BN2: BN) -> boolean -- a > b
	lte(BN1: BN, BN2: BN) -> boolean -- a <= b
	gte(BN1: BN, BN2:BN) -> boolean -- a >= b

Misc:
	sign(BN: BN) -> number -- Returns the sign of a BigNum (-1, 0, or 1) same as BN[1]
	isNegative(BN: BN) -> boolean -- Returns true if the BigNum is negative same as BN[1] == -1
	isPositive(BN: BN) -> boolean -- Returns true if the BigNum is positive same as BN[1] == 1
	isZero(BN: BN) -> boolean -- Returns true if the BigNum is zero same as BN[1] == 0
	isBigNum(value: any) -> boolean -- Returns whether or not a value is a BigNum
	isNaN(BN: BN) -> boolean -- Returns whether or not a BigNum is NaN
	isFloat(BN: BN) -> boolean -- Returns whether or not a BigNum is in valid doublefloat range
	random(min: BN, max: BN) -> BN -- Returns a random BigNum between min and max
	exprand(min: BN, max: BN) -> BN -- Returns a random BigNum between min and max with an exponential distribution

Display:
	toScientific(BN: BN, precision: number?) -> string -- Converts a BigNum to scientific notation (e.g "1e8")
	toEngineer(BN: BN, precision: number?) -> string -- Converts a BigNum to engineering notation (e.g "100e6")
	toSuffix(BN: BN, precision: number?) -> string -- Converts a BigNum to suffix notation (e.g "100M")

Leaderboards: (These functions are used to convert BigNums to numbers for storing in OrderedDataStore)
	lbencode(BN: BN) -> number -- Encodes a BigNum as a number that can be stored in OrderedDataStore
	lbdecode(num: number) -> BN -- Decodes an encoded number back to BigNum


]]

------------------------------------------------------------------------------------------------------------
module.ZERO = { 0, 0 }
module.NAN = { -2, 0 }

local INF = 1e309
local NAN = 0 / 0
local euler = 2.7182818284590452353602874713526
local pmul = 10 ^ module.precision
local spmul = 10 ^ module.display_precision

export type BN = { number }

--[[
	fromNumber converts a number input to a BigNum,
	If the input is invalid it will return NaN
	
	Examples:
		fromNumber(10) -> {1, 1}
		fromNumber(-10) -> {-1, 1}
		fromNumber("Invalid") -> {-2, 0} (NaN)
]]
function module.fromNumber(number: number)
	if type(number) ~= "number" then
		return table.clone(module.NAN)
	end

	if number == 0 then
		return table.clone(module.ZERO)
	end

	if number ~= number then
		return table.clone(module.NAN)
	end

	local sign = math.sign(number)
	return { sign, math.log10(math.abs(number)) }
end

--[[
	toNumber converts a BigNum to a number,
	If the input is invalid it will return NaN
	
	Examples:
		toNumber({1, 1}) -> 10
		toNumber({-1, 1}) -> -10
		toNumber({-2, 0}) -> NaN
]]
function module.toNumber(BN): number
	if BN[1] == -2 then
		return NAN
	end
	local x = BN[1] * 10 ^ BN[2]

	if x < 2 ^ 52 then
		return math.round(x * pmul) / pmul
	end

	return x
end

--[[
	fromString converts a string input to a BigNum,
	If the input is invalid it will return NaN
	
	Examples:
		fromString("10") -> {1, 1}
		fromString("-10") -> {-1, 1}
		fromString("1e100") -> {1, 100}
		fromString("-1e100") -> {-1, 100}
		fromString("Invalid") -> {-2, 0} (NaN)		
]]
function module.fromString(str: string)
	local e = string.find(str, "e")
	if e then -- Assume its scientific notation
		local mantissa = tonumber(string.sub(str, 1, e - 1))
		local exponent = tonumber(string.sub(str, e + 1, -1))

		if (mantissa ~= mantissa) or (mantissa == nil) then
			return table.clone(module.NAN)
		end

		if (exponent ~= exponent) or (exponent == nil) then
			return table.clone(module.NAN)
		end

		if mantissa == 0 then
			return table.clone(module.ZERO)
		end

		return { math.sign(mantissa), math.log10(math.abs(mantissa)) + exponent }
	elseif string.find(str, ";") then
		local p = string.find(str, ";")

		local layer = tonumber(string.sub(str, 1, p - 1))
		local exponent = tonumber(string.sub(str, p + 1, -1))

		if (layer ~= layer) or (layer == nil) then
			return table.clone(module.NAN)
		end

		if (exponent ~= exponent) or (exponent == nil) then
			return table.clone(module.NAN)
		end

		if layer == 0 then
			return module.fromNumber(exponent)
		elseif math.abs(layer) == 1 then
			return { math.sign(layer), exponent }
		else
			return { math.sign(layer), math.huge }
		end
	else
		if string.lower(str) == "inf" then
			return { 1, INF }
		end

		local number = tonumber(str)
		if (number ~= number) or (number == nil) then
			return table.clone(module.NAN)
		end

		if number == 0 then
			return table.clone(module.ZERO)
		end

		return { math.sign(number), math.log10(math.abs(number)) }
	end
end

--[[
	toString converts a BigNum to a string,
	This function should be used to store BigNums in StringValues / Storing for datastores.
	If you are looking to display numbers in scientifc notation use toScientific(BN: BN)
	
	Examples:
		toString({0, 0}) -> "0e0"
		toString({1, 1}) -> "1e1"
		toString({-1, 1}) -> "-1e1"
		toString({1, 100}) -> "1e100"
		toString({-2, 0}) -> "NaN"
		toString({1, inf}) -> "inf"
]]
function module.toString(BN): string
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == 0 then
		return "0e0"
	end
	if BN[1] == -2 then
		return "NaN"
	end
	if BN[2] == INF then
		return (if BN[1] == -1 then "-" else "") .. "inf"
	end

	local exponent = math.floor(BN[2])
	local mantissa = 10 ^ (BN[2] - exponent)
	return (if BN[1] == -1 then "-" else "") .. mantissa .. "e" .. exponent
end

function module.add(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if BN1[1] == -2 or BN2[1] == -2 then
		return table.clone(module.NAN)
	end

	--[[
		formula: (x / y + 1) * y = x + y
	]]

	if BN1[1] == 0 then
		return table.clone(BN2)
	elseif BN2[1] == 0 then
		return table.clone(BN1)
	end

	local difference = BN1[2] - BN2[2]
	if difference > 16 then
		return table.clone(BN1)
	elseif difference < -16 then
		return table.clone(BN2)
	elseif difference == 0 and BN1[1] ~= BN2[1] then
		return table.clone(module.ZERO)
	end

	if BN1[1] == BN2[1] then
		return { BN1[1], math.log10(10 ^ difference + 1) + BN2[2] }
	else
		if difference >= 0 then
			return { BN1[1], BN1[2] + math.log10(1 - 10 ^ -difference) }
		else
			return { -BN1[1], BN2[2] + math.log10(1 - 10 ^ difference) }
		end
	end
end

function module.sub(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if BN1[1] == -2 or BN2[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN1[1] == 0 then
		return table.clone(BN2)
	elseif BN2[1] == 0 then
		return table.clone(BN1)
	end

	local difference = BN1[2] - BN2[2]
	if difference > 16 then
		return table.clone(BN1)
	elseif difference < -16 then
		return table.clone(BN2)
	elseif difference == 0 and BN1[1] == BN2[1] then
		return table.clone(module.ZERO)
	end

	if BN1[1] == BN2[1] then
		if difference >= 0 then
			return { BN1[1], BN1[2] + math.log10(1 - 10 ^ -difference) }
		else
			return { -BN1[1], BN2[2] + math.log10(1 - 10 ^ difference) }
		end
	else
		return { BN1[1], math.log10(10 ^ difference + 1) + BN2[2] }
	end
end

function module.mul(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end
	if BN1[1] == -2 or BN2[1] == -2 then
		return table.clone(module.NAN)
	end
	return { BN1[1] * BN2[1], BN1[2] + BN2[2] }
end

function module.div(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end
	if BN1[1] == -2 or BN2[1] == -2 then
		return table.clone(module.NAN)
	end
	if BN2[1] == 0 then
		return table.clone(module.NAN)
	end
	return { BN1[1] * BN2[1], BN1[2] - BN2[2] }
end

--[[
	intdiv (integer devision)
		Same as x // y | floor(x / y)
]]
function module.intdiv(BN1, BN2)
	return module.floor(module.div(BN1, BN2))
end

--[[
NOTE:
	pow(x, y) returns incorrect results if y is a decimal and x a negative number
	e.g. pow(-2, 0.5) returns 1.41421 instead of nan
]]
function module.pow(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if BN1[1] == -2 or BN2[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN1[1] == 0 then
		if BN2[1] == 0 then
			return table.clone(module.POW_ZERO)
		end
		return table.clone(module.ZERO)
	end

	if BN1[1] == -1 then
		return { if module.toNumber(BN2) % 2 == 1 then -1 else 1, BN1[2] * 10 ^ BN2[2] * BN2[1] }
	end

	return { 1, BN1[2] * 10 ^ BN2[2] * BN2[1] }
end

--[[
	powf
		Same as pow(BN: BN1, BN: BN2) but the second argument is a number
]]
function module.powf(BN1, x: number)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if BN1[1] ~= 1 then
		return table.clone(module.NAN)
	end
	if x == 0 then
		return { 0, 0 }
	end
	if x == 1 then
		return { 1, 0 }
	end
	return { 1, BN1[2] * x }
end

function module.pow10(BN) -- 10^x
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] == -2 then
		return table.clone(module.NAN)
	end
	return { 1, BN[1] * 10 ^ BN[2] }
end

function module.sqrt(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] < 0 then
		return table.clone(module.NAN)
	elseif BN[1] == 0 then
		return table.clone(module.ZERO)
	end

	return { 1, 0.5 * BN[2] }
end

function module.root(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if BN2[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN2[2] == 0 or BN1[1] < 0 then
		return table.clone(module.NAN)
	elseif BN1[1] == 0 then
		return table.clone(module.ZERO)
	end

	return { 1, 1 / module.toNumber(BN2) * BN1[2] }
end

function module.cmp(BN1, BN2): number
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if BN1[1] ~= BN2[1] then
		return if BN1[1] > BN2[1] then 1 else -1
	end

	return if BN1[2] > BN2[2] then BN1[1] elseif BN1[2] < BN2[2] then -1 * BN1[1] else (BN1[1] ~= -2) and 0 or -1
end

function module.eq(BN1, BN2): boolean -- ==
	return module.cmp(BN1, BN2) == 0
end

function module.lt(BN1, BN2): boolean -- <
	return module.cmp(BN1, BN2) == -1
end

function module.gt(BN1, BN2): boolean -- >
	return module.cmp(BN1, BN2) == 1
end

function module.lte(BN1, BN2): boolean -- <=
	return module.cmp(BN1, BN2) ~= 1
end

function module.gte(BN1, BN2): boolean -- >=
	return module.cmp(BN1, BN2) ~= -1
end

function module.isBigNum(BN: any): boolean
	return type(BN) == "table" and type(BN[1]) == "number" and type(BN[2]) == "number"
end

function module.isNaN(BN): boolean
	return math.abs(BN[1]) > 1
end

--sign(BN: BN) -> boolean -- Returns true if the BigNum is negative
function module.sign(BN: BN): number
	return BN[1]
end

--isNegative(BN: BN) -> boolean -- Returns true if the BigNum is negative
function module.isNegative(BN: BN): boolean
	return BN[1] == -1
end

--isPositive(BN: BN) -> boolean -- Returns true if the BigNum is positive
function module.isPositive(BN: BN): boolean
	return BN[1] == 1
end

--isZero(BN: BN) -> boolean -- Returns true if the BigNum is zero
function module.isZero(BN: BN): boolean
	return BN[1] == 0
end

function module.isFloat(BN): boolean
	return BN[2] <= 308.2304489213783 and math.abs(BN[1]) <= 1
end

function module.neg(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return table.clone(module.NAN)
	end
	return { -BN[1], BN[2] }
end

function module.abs(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return table.clone(module.NAN)
	end
	return { 1, BN[2] }
end

function module.toBN(input: any)
	if type(input) == "string" then
		return module.fromString(input)
	elseif type(input) == "number" then
		return module.fromNumber(input)
	elseif type(input) == "table" then
		return { input[1], input[2] }
	else
		warn(`Invalid input type '{type(input)}' -> {input}`)
		return table.clone(module.ZERO)
	end
end

function module.recip(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	return { BN[1], BN[2] * -1 }
end

function module.log10(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] ~= 1 then
		return table.clone(module.NAN)
	end
	return { math.sign(BN[2]), math.log10(math.abs(BN[2])) }
end

function module.log2(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] ~= 1 then
		return table.clone(module.NAN)
	end
	return { math.sign(BN[2]), math.log10(math.abs(BN[2]) / 0.3010299956639812) }
end

function module.ln(BN) -- natural log
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] ~= 1 then
		return table.clone(module.NAN)
	end
	return { math.sign(BN[2]), math.log10(math.abs(BN[2]) / 0.4342944819032518) }
end

function module.log(BN, base)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	base = base and module.toNumber(module.toBN(base)) or euler
	if BN[1] ~= 1 then
		return table.clone(module.NAN)
	end

	if not base then
		-- ln(x)
		return { math.sign(BN[2]), math.log10(math.abs(BN[2]) / 0.4342944819032518) }
	end

	return { math.sign(BN[2]), math.log10(math.abs(BN[2]) / math.log10(base :: number)) }
end

-- e^x
function module.exp(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return table.clone(module.NAN)
	end
	return { 1, 0.4342944819032518 * 10 ^ BN[2] * BN[1] }
end

local C = {
	0.99999999999980993,
	676.5203681218851,
	-1259.1392167224028,
	771.32342877765313,
	-176.61502916214059,
	12.507343278686905,
	-0.13857109526572012,
	9.9843695780195716e-6,
	1.5056327351493116e-7,
}
local function gamma(Value: number): number
	if Value > 0.5 then
		Value -= 1
		local x = C[1]
		for i = 1, 7 do
			x += C[i + 1] / (Value + i)
		end
		local t = Value + 7.5
		return x * t ^ (Value + 0.5 - 36) * math.exp(-t) * t ^ 36 * 2.50662827463100050241576528
	end

	return 3.141592653589793238 / (math.sin(3.141592653589793238 * Value) * gamma(1 - Value))
end

-----------------------------------------
local twopi = { 1, 0.7981798683581151 }
local eul = { 1, 0.4342944819032518 }
local r1 = { 1, -1.079181246064997 }
local r2 = { 1, -2.556302501983312 }

-- x!
function module.fact(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return table.clone(module.NAN)
	end
	local N = module.toNumber(BN)

	if BN[1] == -1 then
		return table.clone(module.NAN)
	end

	if N < 170.61 then
		return module.fromNumber(gamma(N + 1))
	end

	local tp = twopi
	local res2 = module.div(r1, BN)
	local res3 = module.div(r2, module.powf(BN, 3)) -- r2 / BN ^ 3

	tp = module.mul(tp, BN)
	tp = module.sqrt(tp)
	res2 = module.sub(res2, res3)
	res2 = module.exp(res2)
	res3 = module.div(BN, eul)
	res3 = module.pow(res3, BN)
	res3 = module.mul(res3, tp)

	return module.mul(res2, res3)
end
-----------------------------------------

function module.random(min, max)
	if type(min) ~= "table" then
		min = module.toBN(min)
	end
	if type(max) ~= "table" then
		max = module.toBN(max)
	end
	if min[1] == -2 or max[1] == -2 then
		return table.clone(module.NAN)
	end
	return module.add(module.mul(module.sub(max, min), module.fromNumber(math.random())), min)
end

function module.exprand(min, max)
	if type(min) ~= "table" then
		min = module.toBN(min)
	end
	if type(max) ~= "table" then
		max = module.toBN(max)
	end
	if min[1] == -2 or max[1] == -2 then
		return table.clone(module.NAN)
	end
	return { min[1], min[2] + max[2] * math.random() }
end

function module.min(...): BN
	local args = { ... }
	local min = args[1]

	for _, arg in args do
		if module.cmp(arg, min) == -1 then
			min = arg
		end
	end

	return module.toBN(min)
end

function module.max(...): BN
	local args = { ... }
	local max = args[1]

	for _, arg in args do
		if module.cmp(arg, max) == 1 then
			max = arg
		end
	end

	return module.toBN(max)
end

function module.floor(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN[2] >= 16 then
		return table.clone(BN)
	end
	if BN[1] == 0 or BN[2] < 0 then
		return table.clone(module.ZERO)
	end

	if BN[1] == -1 then
		return { -1, math.log10(math.ceil(10 ^ BN[2])) }
	end

	return { 1, math.log10(math.floor(10 ^ BN[2])) }
end

function module.ceil(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN[2] >= 16 then
		return table.clone(BN)
	end
	if BN[1] == 0 or BN[2] < 0 then
		return table.clone(module.ZERO)
	end

	if BN[1] == -1 then
		return { -1, math.log10(math.floor(10 ^ BN[2])) }
	end

	return { 1, math.log10(math.ceil(10 ^ BN[2])) }
end

function module.round(BN)
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	if BN[1] == -2 then
		return table.clone(module.NAN)
	end

	if BN[2] >= 16 then
		return table.clone(BN)
	end
	if BN[1] == 0 or BN[2] < 0 then
		return table.clone(module.ZERO)
	end

	return { BN[1], math.log10(math.round(10 ^ BN[2])) }
end

function module.mod(BN1, BN2)
	if type(BN1) ~= "table" then
		BN1 = module.toBN(BN1)
	end
	if type(BN2) ~= "table" then
		BN2 = module.toBN(BN2)
	end

	if module.isFloat(BN1) and module.isFloat(BN2) then
		return module.fromNumber(module.toNumber(BN1) % module.toNumber(BN2))
	end

	-- x - y * (x // y)
	return module.sub(BN1, module.mul(BN2, module.intdiv(BN1, BN2)))
end

-----------------------------------------------
function module.lbencode(BN): number
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	local a = module.add({ 1, BN[2] }, { 1, 0 }) -- abs(x) + 1
	if a[2] ~= a[2] then
		return 0
	end

	local exponent = a[2]
	if exponent > 1.7976931348623157e+308 then
		exponent = 1.7976931348623157e+308
	end

	if a[1] == 0 or exponent <= 0 then
		return 0
	end

	return math.floor((math.log10(exponent + 1) + 1) * 291262135922330) * BN[1]
end

function module.lbencodePrecise(BN): number
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	local a = module.add({ 1, BN[2] }, { 1, 0 }) -- abs(x) + 1
	if a[2] ~= a[2] then
		return 0
	end

	local exponent = a[2]
	if exponent > 1.7976931348623157e+308 then
		exponent = 1.7976931348623157e+308
	end

	if a[1] == 0 or exponent <= 0 then
		return 0
	end

	return math.floor((math.log10(exponent + 1) + 1) * 4503599627370496 * BN[1])
end

function module.lbdecode(num: number)
	if num == 0 then
		return table.clone(module.ZERO)
	end

	local s = math.sign(num)
	num = math.abs(num)

	local BN = { 1, 10 ^ (num / 291262135922330 - 1) - 1 }
	BN = module.sub(BN, { 1, 0 })
	return { s, BN[2] }
end

function module.lbdecodePrecise(num: number)
	if num == 0 then
		return table.clone(module.ZERO)
	end

	local s = math.sign(num)
	num = math.abs(num)

	local BN = { 1, 10 ^ (num / 4503599627370496 - 1) - 1 }
	BN = module.sub(BN, { 1, 0 })
	return { s, BN[2] }
end

function module.toScientific(BN): string
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return "NaN"
	end
	if BN[1] == 0 then
		return "0e0"
	end
	local sign = if BN[1] == -1 then "-" else ""

	local exponent = math.floor(BN[2])
	local mantissa = math.round(10 ^ (BN[2] - exponent) * spmul) / spmul
	return sign .. mantissa .. "e" .. exponent
end

function module.toEngineer(BN): string
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == -2 then
		return "NaN"
	end
	if BN[1] == 0 then
		return "0e0"
	end
	local sign = if BN[1] == -1 then "-" else ""

	local exponent = math.floor(BN[2])
	exponent = exponent - (exponent % 3)
	local mantissa = math.round(10 ^ (BN[2] - exponent) * spmul) / spmul
	return sign .. mantissa .. "e" .. exponent
end

----------------------------------------------------------------------
local SmallOnes = { "k", "M", "B" }
local FirstOnes = { "", "U", "D", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No" }
local SecondOnes = { "", "De", "Vt", "Tg", "qg", "Qg", "sg", "Sg", "Og", "Ng" }
local ThirdOnes = { "", "Ce", "Du", "Tr", "Qa", "Qi", "Se", "Si", "Ot", "Ni" }
local MultOnes = {
	"Mi",
	"Mc",
	"Na",
	"Pi",
	"Fm",
	"At",
	"Zp",
	"Yc",
	"Xo",
	"Ve",
	"Me",
	"Due",
	"Tre",
	"Te",
	"Pt",
	"He",
	"Hp",
	"Oct",
	"En",
	"Ic",
	"Mei",
	"Dui",
	"Tri",
	"Teti",
	"Pti",
	"Hei",
	"Hp",
	"Oci",
	"Eni",
	"Tra",
	"TeC",
	"MTc",
	"DTc",
	"TrTc",
	"TeTc",
	"PeTc",
	"HTc",
	"HpT",
	"OcT",
	"EnT",
	"TetC",
	"MTetc",
	"DTetc",
	"TrTetc",
	"TeTetc",
	"PeTetc",
	"HTetc",
	"HpTetc",
	"OcTetc",
	"EnTetc",
	"PcT",
	"MPcT",
	"DPcT",
	"TPCt",
	"TePCt",
	"PePCt",
	"HePCt",
	"HpPct",
	"OcPct",
	"EnPct",
	"HCt",
	"MHcT",
	"DHcT",
	"THCt",
	"TeHCt",
	"PeHCt",
	"HeHCt",
	"HpHct",
	"OcHct",
	"EnHct",
	"HpCt",
	"MHpcT",
	"DHpcT",
	"THpCt",
	"TeHpCt",
	"PeHpCt",
	"HeHpCt",
	"HpHpct",
	"OcHpct",
	"EnHpct",
	"OCt",
	"MOcT",
	"DOcT",
	"TOCt",
	"TeOCt",
	"PeOCt",
	"HeOCt",
	"HpOct",
	"OcOct",
	"EnOct",
	"Ent",
	"MEnT",
	"DEnT",
	"TEnt",
	"TeEnt",
	"PeEnt",
	"HeEnt",
	"HpEnt",
	"OcEnt",
	"EnEnt",
	"Hect",
	"MeHect",
}

local function lowTier(x: number)
	local first = x % 10
	local second = (x // 10) % 10
	local third = (x // 100) % 10
	return FirstOnes[first + 1] .. SecondOnes[second + 1] .. ThirdOnes[third + 1]
end

local function highTier(x: number)
	local res = ""
	for i, v in MultOnes do
		local n = 10 ^ (i * 3 - 3)
		if x < n then
			break
		end

		local s = (x // n) % 1000
		if s > 0 then
			if s == 1 then
				s = 0
			end
			res = lowTier(s) .. v .. res
		end
	end

	return res
end

function module.toSuffix(BN): string
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end

	if BN[1] == 0 then
		return "0"
	end
	if BN[1] == -2 then
		return "NaN"
	end
	if BN[2] == INF then
		return "inf"
	end

	local sign = if BN[1] == -1 then "-" else ""

	if BN[2] < 0 then
		return sign .. math.round(10 ^ BN[2] * spmul) / spmul
	end

	BN[2] = math.round(BN[2] * 100000000000) / 100000000000

	local exponent = (BN[2] - 3) // 3

	local exponent2 = math.floor(BN[2])
	exponent2 = exponent2 - (exponent2 % 3)
	local mantissa = math.round(10 ^ (BN[2] - exponent2) * spmul) / spmul

	if exponent < 1000 then
		if exponent < 3 then
			return sign .. mantissa .. (SmallOnes[exponent + 1] or "")
		end

		return sign .. mantissa .. lowTier(exponent)
	end

	return sign .. mantissa .. highTier(exponent // 1000) .. lowTier(exponent % 1000)
end

function module.roundMantissa(BN: any, Digits: number): BN
	if type(BN) ~= "table" then
		BN = module.toBN(BN)
	end
	local mantissa = math.round(10 ^ (BN[2] % 1 + Digits)) / 10 ^ Digits
	return { BN[1], math.floor(BN[2]) + math.log10(mantissa) }
end

function module.map(x: any, inmin: any, inmax: any, outmin: any, outmax: any)
	-- t1 * t2 / t3 + outmin
	local t1 = module.sub(x, inmin)
	local t2 = module.sub(outmax, outmin)
	local t3 = module.sub(inmax, inmin)

	return module.add(module.div(module.mul(t1, t2), t3), outmin)
end

return module
