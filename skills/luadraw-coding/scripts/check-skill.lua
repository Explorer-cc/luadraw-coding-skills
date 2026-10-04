-- Validate the installed Luadraw skill layout.
-- Run from the repository root:
--   lua skills/luadraw-coding/scripts/check-skill.lua

local required = {
  "skills/luadraw-coding/SKILL.md",
  "skills/luadraw-coding/README.md",
  "skills/luadraw-coding/VERSION",
  "skills/luadraw-coding/examples/minimal-2d.tex",
  "skills/luadraw-coding/references/01-skeleton-and-workflow.md",
  "skills/luadraw-coding/references/02-style-and-state.md",
  "skills/luadraw-coding/references/03-rendering-and-patterns.md",
  "skills/luadraw-coding/references/04-sources-and-validation.md",
  "luadraw-coding-guide-en.md",
  "assets/README.md",
  "LICENSE",
}

local missing = {}
for _, path in ipairs(required) do
  local file = io.open(path, "rb")
  if file then
    file:close()
  else
    missing[#missing + 1] = path
  end
end

if #missing > 0 then
  io.stderr:write("Missing required skill files:\n")
  for _, path in ipairs(missing) do
    io.stderr:write("  ", path, "\n")
  end
  os.exit(1)
end

local skill = assert(io.open("skills/luadraw-coding/SKILL.md", "rb")):read("*a")
local guide = assert(io.open("luadraw-coding-guide-en.md", "rb")):read("*a")

local version = assert(io.open("skills/luadraw-coding/VERSION", "rb")):read("*a")
local license = assert(io.open("LICENSE", "rb")):read("*a")

assert(version:match("0%.1%.0"), "skill version is not 0.1.0")
assert(skill:find("version: 0%.1%.0", 1, false), "SKILL.md has no 0.1.0 version")
assert(license:find("MIT License", 1, true), "LICENSE is not MIT")

assert(skill:find("name: luadraw%-coding", 1, false), "SKILL.md has no skill name")
assert(skill:find("Target API: Luadraw v3%.5", 1, false), "SKILL.md has no v3.5 constraint")
assert(skill:find("luadraw%-coding%-guide%-en%.md", 1, false), "SKILL.md does not route to the full guide")
assert(#guide > 0, "the full English guide is empty")

print("Luadraw skill layout: OK")
