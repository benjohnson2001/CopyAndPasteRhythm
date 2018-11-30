
function getFirstSelectedTake()

	local activeProjectIndex = 0
	local selectedItemIndex = 0
	local selectedMediaItem = reaper.GetSelectedMediaItem(activeProjectIndex, selectedItemIndex)

	if selectedMediaItem == nil then
		return nil
	end

	return reaper.GetActiveTake(selectedMediaItem)
end

function getNumberOfSelectedItems()
	
	local activeProjectIndex = 0
	return reaper.CountSelectedMediaItems(activeProjectIndex)
end

function getNumberOfNotes(mediaItemTake)

  local _, numberOfNotes = reaper.MIDI_CountEvts(mediaItemTake)
  return numberOfNotes
end

function getCurrentChannel(channelArg)

  if channelArg ~= nil then
    return channelArg
  end

  return 0
end

function getCurrentVelocity(velocityArg)

	if velocityArg ~= nil then
    return velocityArg
  end

  return 96
end

function insertMidiNote(selectedTake, startingPositionArg, endingPositionArg, noteChannelArg, notePitchArg, noteVelocityArg)

	local keepNotesSelected = false
	local noteIsMuted = false

	local channel = getCurrentChannel(noteChannelArg)
	local velocity = getCurrentVelocity(noteVelocityArg)
	local noSort = false

	reaper.MIDI_InsertNote(selectedTake, keepNotesSelected, noteIsMuted, startingPositionArg, endingPositionArg, channel, notePitchArg, velocity, noSort)
end