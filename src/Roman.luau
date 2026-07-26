local ROMAN_MAP = {
	{ 1000, "M" },
	{ 900, "CM" },
	{ 500, "D" },
	{ 400, "CD" },
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" },
}

local function ToRoman(num: number): string
	if num <= 0 then
		return ""
	end

	local result = ""
	num = math.floor(num)

	for _, entry in ROMAN_MAP do
		local value, symbol = entry[1], entry[2]
		while num >= value do
			result ..= symbol
			num -= value
		end
	end

	return result
end

return ToRoman
