local M = {}

local JB_ISSUES_NAMESPACE = 'JbIssuesNamespace'

local INSPECTION_LEVEL = {
  error = 'ErrorMsg',
  warning = 'WarningMsg',
  note = 'Character'
}

local function get_highlight_group(hg)
  local group = INSPECTION_LEVEL[hg]

  if group == nil then
    return INSPECTION_LEVEL.note
  else
    return group
  end
end

---Creates extmark with provided text in a buffer
---@param bufnr integer Buffer number
---@param text string Text
---@param l_num integer Line number
---@param c_num integer Column number
---@param hg string Issue type
function M.create(bufnr, text, l_num, c_num, hg)
  local ns_id = vim.api.nvim_get_namespaces()[JB_ISSUES_NAMESPACE]

  if ns_id == nil then
    ns_id = vim.api.nvim_create_namespace(JB_ISSUES_NAMESPACE)
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns_id, l_num, c_num,
    { virt_text = { { ' ' .. text, get_highlight_group(hg) } }, virt_text_pos = 'eol' })
end

---Clears all jb issues extmarks
function M.clear()
  local ns_id = vim.api.nvim_get_namespaces()[JB_ISSUES_NAMESPACE]

  if ns_id == nil then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M
