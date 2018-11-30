local workingDirectory = reaper.GetResourcePath() .. "/Scripts/CopyAndPasteRhythm"
require(workingDirectory .. "/Pickle")


local activeProjectIndex = 0
local sectionName = "com.pandabot.CopyAndPasteRhythm"

local rhythmNotesKey = "rhythmNotes"

--

local function setValue(key, value)
  reaper.SetProjExtState(activeProjectIndex, sectionName, key, value)
end

local function getValue(key)

  local valueExists, value = reaper.GetProjExtState(activeProjectIndex, sectionName, key)

  if valueExists == 0 then
    return nil
  end

  return value
end


--[[ ]]--


function getRhythmNotesFromPreferences()
  return unpickle(getValue(rhythmNotesKey))
end

function setRhythmNotesInPreferences(arg)
  setValue(rhythmNotesKey, pickle(arg))
end