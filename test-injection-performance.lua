#!/usr/bin/env -S nvim -l
vim.opt.runtimepath:append('.')

local iterations = 50
local test_file = 'test-nix-file.nix'

-- Read test file
local content = vim.fn.readfile(test_file)
local text = table.concat(content, '\n')

local function benchmark(query_file, name)
  local query_content = vim.fn.readfile(query_file)
  local parser = vim.treesitter.get_string_parser(text, 'nix')
  local tree = parser:parse()[1]
  local root = tree:root()

  local ok, query = pcall(vim.treesitter.query.parse, 'nix', table.concat(query_content, '\n'))
  if not ok then
    print(string.format('ERROR: %s failed to parse: %s', name, query))
    return nil
  end

  -- Warmup
  for _ = 1, 5 do
    for _ in query:iter_captures(root, text, 0, -1) do end
  end

  -- Benchmark
  local start = vim.uv.hrtime()
  for _ = 1, iterations do
    for _ in query:iter_captures(root, text, 0, -1) do end
  end
  return (vim.uv.hrtime() - start) / 1e6 / iterations
end

print(string.format('Benchmarking injection queries (%d iterations)', iterations))
print(string.rep('=', 70))

-- Test baseline
local baseline_time = benchmark('runtime/queries/nix/injections.original.scm', 'Baseline')
local baseline_lines = #vim.fn.readfile('runtime/queries/nix/injections.original.scm')

-- Test current
local current_time = benchmark('runtime/queries/nix/injections.scm', 'Current')
local current_lines = #vim.fn.readfile('runtime/queries/nix/injections.scm')

if baseline_time and current_time then
  local speedup = baseline_time / current_time
  local line_change = ((current_lines - baseline_lines) / baseline_lines) * 100

  print(string.format('\nBaseline (original):  %3d lines  %7.2f ms', baseline_lines, baseline_time))
  print(string.format('Current  (active):    %3d lines  %7.2f ms', current_lines, current_time))
  print(string.rep('=', 70))
  print(string.format('Speedup:    %.2fx faster', speedup))
  print(string.format('File size:  %+.1f%% (%s)',
    line_change,
    line_change > 0 and 'larger' or 'smaller'))
end
