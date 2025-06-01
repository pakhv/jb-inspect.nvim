local M = {}

---Runs a shell command asynchronously
---@param cmd string Shell command
---@return integer # Job Id
function M.run_async(cmd, on_exit)
  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, data, event)
      if data > 0 then
        print('Command failed with exit code: ' .. data, vim.log.levels.ERROR)
      else
        if on_exit then on_exit(event) end
      end
    end
  })
  return job_id
end

---Sorts jb inspectcode results by line in place
---@param tbl table jb inspectcode results
function M.sort_inspect_json(tbl)
  table.sort(tbl, function(a, b)
    local a_level = a["locations"][1]["physicalLocation"]["region"]["startLine"]
    local b_level = b["locations"][1]["physicalLocation"]["region"]["startLine"]

    return a_level < b_level
  end)
end

---Finds an element in an array
---@param tbl table Table
---@param predicate fun(el: any): boolean Predicate
function M.array_find(tbl, predicate)
  for _, x in ipairs(tbl) do
    if predicate(x) then
      return x
    end
  end

  return nil
end

return M
