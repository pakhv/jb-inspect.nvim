local M = {}

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

M.INSPECTION_LEVEL = {
  error = 0,
  warning = 1,
  note = 2
}

function M.sort_inspect_json(tbl)
  table.sort(tbl, function(a, b)
    local a_level = a["locations"][1]["physicalLocation"]["region"]["startLine"]
    local b_level = b["locations"][1]["physicalLocation"]["region"]["startLine"]

    return a_level < b_level
  end)
end

return M
