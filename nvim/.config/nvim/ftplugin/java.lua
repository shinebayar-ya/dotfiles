local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

-- find Lombok jar
local function get_lombok_path()
  local m2_path = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok")
  local jars = vim.fn.glob(m2_path .. "/**/lombok-*.jar", true, true)

  if #jars > 0 then
    table.sort(jars)
    return jars[#jars]
  end

  return nil
end

-- root
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

if root_dir == "" then
  return
end

-- workspace
local home = vim.fn.expand("$HOME")
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. project_name

-- cmd
local cmd = { "jdtls" }
local lombok_jar = get_lombok_path()

if lombok_jar then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end

-- config
local config = {
  cmd = vim.list_extend(cmd, { "-data", workspace_dir }),
  root_dir = root_dir,
}

jdtls.start_or_attach(config)
