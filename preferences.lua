local function loadDependency(arg)
  dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. arg .. ".lua")
end

loadDependency("Pickle")


local activeProjectIndex = 0
local sectionName = "com.pandabot.CopyAndPasteRhythm"

local rhythmNotesKey = "rhythmNotes"
local scriptIsRunningKey = "scriptIsRunning"

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

	local pickledValue = getValue(rhythmNotesKey)

	if pickledValue == nil then
		return nil
	end

  return unpickle(pickledValue)
end

function setRhythmNotesInPreferences(arg)
  setValue(rhythmNotesKey, pickle(arg))
end