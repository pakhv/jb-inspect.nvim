local utils = require('utils')
local json = require('json')
local extmarks = require('extmarks')

local OUTPUT_REL_PATH = 'jbinspect/output.json'

---Show code issues in a buffer
---@param bufnr integer
---@param buf_rel_path string
---@param json_path string
local function show_buf_code_issues(bufnr, buf_rel_path, json_path)
  local inspect_json = json.decode(vim.fn.system('cat ' .. json_path))

  local artifacts = inspect_json["runs"][1]["artifacts"]

  local json_has_buf_code_issues = utils.array_find(artifacts, function(el)
    return el["location"]["uri"] == buf_rel_path
  end)

  if json_has_buf_code_issues == nil then
    print 'No code issues found!'
    return
  end

  local jb_results = inspect_json["runs"][1]["results"]
  local jb_help = inspect_json["runs"][1]["tool"]["driver"]["rules"]
  local qf_list = {}
  local rules_help = {}

  utils.sort_inspect_json(jb_results)

  if jb_help then
    for _, x in ipairs(jb_help) do
      local rule_id = x["id"]
      rules_help[rule_id] = x["helpUri"]
    end
  end

  for i, x in ipairs(jb_results) do
    if x["locations"][1]["physicalLocation"]["artifactLocation"]["uri"] == buf_rel_path then
      qf_list[i] = {}
      qf_list[i]["text"] = x["message"]["text"]
      if rules_help[x["ruleId"]] then
        qf_list[i]["text"] = qf_list[i]["text"] .. ' (' .. rules_help[x["ruleId"]] .. ')'
      end
      qf_list[i]["bufnr"] = bufnr
      qf_list[i]["lnum"] = x["locations"][1]["physicalLocation"]["region"]["startLine"]
      qf_list[i]["end_lnum"] = x["locations"][1]["physicalLocation"]["region"]["endLine"]
      qf_list[i]["col"] = x["locations"][1]["physicalLocation"]["region"]["startColumn"]
      qf_list[i]["end_col"] = x["locations"][1]["physicalLocation"]["region"]["endColumn"]

      extmarks.create(bufnr, x["message"]["text"], qf_list[i]["lnum"] - 1, qf_list[i]["col"] - 1, x["level"])
    end
  end

  if next(qf_list) ~= nil then
    vim.fn.setqflist(qf_list)
    vim.cmd('copen')

    print 'JbInspect done!'
  else
    print 'No code issues found!'
  end
end

vim.api.nvim_create_user_command('JbInspect', function(_)
  extmarks.clear()

  local bufnr = vim.fn.bufnr()
  local filetype = vim.bo.filetype

  if filetype ~= 'cs' then
    print 'Invalid filetype'
    return
  end

  local cs_projs = vim.fn.system('find "$(pwd)" -type f -name "*.csproj"')
  local current_buf_path = vim.api.nvim_buf_get_name(bufnr)
  local current_project_path = nil
  local buf_rel_path = nil

  for s in cs_projs:gmatch("[^\r\n]+") do
    local path = vim.fs.dirname(s)
    buf_rel_path = vim.fs.relpath(path, current_buf_path)

    if buf_rel_path ~= nil then
      current_project_path = s
      break
    end
  end

  if buf_rel_path == nil or current_project_path == nil then
    print 'Couldn\'t find csproj file'
    return
  end

  local command = 'jb inspectcode ' ..
      current_project_path .. ' -o="' .. OUTPUT_REL_PATH .. '" --include="' .. buf_rel_path .. '"'

  local output_full_path = vim.fn.getcwd() .. '/' .. OUTPUT_REL_PATH
  print('Executing: ' .. command)

  utils.run_async(command, function()
    show_buf_code_issues(bufnr, buf_rel_path, output_full_path)
  end)
end, {})

vim.api.nvim_create_user_command('JbClearExtMarks', function(_)
  extmarks.clear()
end, {})
