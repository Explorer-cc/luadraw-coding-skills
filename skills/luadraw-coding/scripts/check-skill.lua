-- Validate the Luadraw skill layout. Works from any directory and checks only
-- files inside the skill directory:
--   lua path/to/luadraw-coding/scripts/check-skill.lua

local script = arg and arg[0] or ""
local root = script:gsub("\\", "/"):match("^(.*)/scripts/[^/]*$") or ".."
if script:gsub("\\", "/"):match("^scripts/[^/]*$") then root = "." end

local function read(rel)
  local file = io.open(root .. "/" .. rel, "rb")
  if not file then return nil end
  local text = file:read("*a")
  file:close()
  return text
end

local required = {
  "SKILL.md",
  "README.md",
  "VERSION",
  "LICENSE",
  "luadraw-coding-guide-en.md",
  "examples/minimal-2d.tex",
  "examples/glass-box-3d.tex",
  "references/01-skeleton-and-workflow.md",
  "references/02-style-and-state.md",
  "references/03-rendering-and-patterns.md",
  "references/04-sources-and-validation.md",
  "references/05-corpus-techniques.md",
}

local text, missing = {}, {}
for _, path in ipairs(required) do
  text[path] = read(path)
  if not text[path] then missing[#missing + 1] = path end
end

if #missing > 0 then
  io.stderr:write("Missing required skill files:\n")
  for _, path in ipairs(missing) do io.stderr:write("  ", path, "\n") end
  os.exit(1)
end

local skill = text["SKILL.md"]
assert(text["VERSION"]:match("0%.1%.0"), "skill version is not 0.1.0")
assert(skill:find("version: 0%.1%.0"), "SKILL.md has no 0.1.0 version")
assert(skill:find("name: luadraw%-coding"), "SKILL.md has no skill name")
assert(text["LICENSE"]:find("MIT License", 1, true), "LICENSE is not MIT")
assert(#text["luadraw-coding-guide-en.md"] > 0, "the full English guide is empty")
assert(skill:find("Target API: Luadraw v3%.5"), "SKILL.md has no v3.5 constraint")
assert(skill:find("luadraw%-coding%-guide%-en%.md"), "SKILL.md does not route to the full guide")
assert(skill:find("glass%-box%-3d%.tex"), "SKILL.md does not reference the 3D example")
assert(skill:find("05%-corpus%-techniques%.md"), "SKILL.md does not route to reference 05")
assert(skill:find("Encapsulate only when three or more", 1, true), "SKILL.md lacks the encapsulation threshold")
assert(skill:find("on the spot", 1, true), "SKILL.md lacks the on-the-spot default lookup rule")

-- Self-containment: no link may leave the skill directory, and no file may
-- treat luadraw-v3.5/ as a path that exists next to the skill.
for path, body in pairs(text) do
  if path ~= "luadraw-coding-guide-en.md" then
    assert(not body:find("../../", 1, true), path .. " links outside the skill directory")
  end
end
for _, path in ipairs { "SKILL.md", "README.md" } do
  for ref in text[path]:gmatch("`([^`]*luadraw%-coding%-guide%-en%.md)`") do
    assert(ref == "luadraw-coding-guide-en.md", path .. " has a bad guide path: " .. ref)
  end
end
for path, body in pairs(text) do
  if path:match("^references/") then
    for ref in body:gmatch("`(%.%./[^`]*)`") do
      local target = (ref:gsub("[,;.]+$", ""))
      assert(read("references/" .. target), path .. " links to a missing file: " .. target)
    end
  end
end

print("Luadraw skill layout: OK")
