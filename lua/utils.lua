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

return M
