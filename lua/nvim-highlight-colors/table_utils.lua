local M = {}

function M.find(table_param, fun)
	for index, value in pairs(table_param) do
		local assertion = fun(value)
		if assertion then
			return { index, value }
		end
	end

	return nil
end

function M.find_index(table_param, fun)
	for index, value in pairs(table_param) do
		local assertion = fun(value)
		if assertion then
			return index
		end
	end

	return nil
end

function M.filter(table_param, fun)
	local results = {}
	for index, value in pairs(table_param) do
		local assertion = fun(value)
		if assertion then
			table.insert(results, value)
		end
	end

	return results
end

return M
