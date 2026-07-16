local function derive_namespace(relative_path)
  if not relative_path or relative_path == "" or relative_path == "." then
    return nil
  end
  local parts = {}
  for segment in relative_path:gmatch("[^/]+") do
    if segment ~= "src" and segment ~= "include" and segment ~= "lib" then
      segment = segment:upper()
      table.insert(parts, segment)
    end
  end
  if #parts == 0 then
    return nil
  end
  return table.concat(parts, "::")
end

local function header_template(relative_path, filename)
  local ns = derive_namespace(relative_path)
  local lines = { "#pragma once" }
  if ns then
    table.insert(lines, "")
    table.insert(lines, "namespace " .. ns .. " {")
    table.insert(lines, "")
    table.insert(lines, "|cursor|")
    table.insert(lines, "")
    local close = "}  // namespace " .. ns
    table.insert(lines, close)
  else
    table.insert(lines, "")
    table.insert(lines, "|cursor|")
  end
  return table.concat(lines, "\n") .. "\n"
end

local function impl_template(relative_path, filename)
  local base = filename:match("^(.+)%.cpp$") or filename:match("^(.+)%.cc$") or filename:match("^(.+)%.cxx$") or filename:match("^(.+)%.")
  local ns = derive_namespace(relative_path)
  local lines = {}

  if base then
    if vim.fn.filereadable(relative_path .. "/" .. base .. ".hpp") == 1 then
      table.insert(lines, '#include "' .. base .. '.hpp"')
    elseif vim.fn.filereadable(relative_path .. "/" .. base .. ".h") == 1 then
      table.insert(lines, '#include "' .. base .. '.h"')
    else
      table.insert(lines, '#include "' .. base .. '.hpp"')
    end
    table.insert(lines, "")
  end

  if ns then
    table.insert(lines, "namespace " .. ns .. " {")
    table.insert(lines, "")
  end

  table.insert(lines, "|cursor|")

  if ns then
    table.insert(lines, "")
    table.insert(lines, "}  // namespace " .. ns)
  end

  return table.concat(lines, "\n") .. "\n"
end

local function main_template(_, _)
  return [[#include <iostream>

int main() {
  |cursor|
  return 0;
}
]]
end

local function fallback_template(relative_path, filename)
  local base = filename:match("^(.+)%.") or filename
  local ns = derive_namespace(relative_path)
  local lines = {}

  if base then
    table.insert(lines, '#include "' .. base .. '.hpp"')
    table.insert(lines, "")
  end

  if ns then
    table.insert(lines, "namespace " .. ns .. " {")
    table.insert(lines, "")
  end

  table.insert(lines, "|cursor|")

  if ns then
    table.insert(lines, "")
    table.insert(lines, "}  // namespace " .. ns)
  end

  return table.concat(lines, "\n") .. "\n"
end

return function(opts)
  local template = {
    { pattern = ".*%.hpp?$",        content = header_template },
    { pattern = "main%.cpp$",       content = main_template },
    { pattern = ".*%.(cpp|cc|cxx)$", content = impl_template },
    { pattern = ".*",               content = fallback_template },
  }

  local full_path = opts.full_path or ""
  for _, entry in ipairs(template) do
    if string.match(full_path, entry.pattern) then
      return entry.content(opts.relative_path, opts.filename)
    end
  end
end
