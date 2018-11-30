
function firstSelectedTake()

	local activeProjectIndex = 0
	local selectedItemIndex = 0
	local selectedMediaItem

	local selectedMediaItem = reaper.GetSelectedMediaItem(activeProjectIndex, selectedItemIndex)

	if selectedMediaItem == nil then
		return nil
	end

	return reaper.GetActiveTake(selectedMediaItem)
end

function getNumberOfNotes()

  local _, numberOfNotes = reaper.MIDI_CountEvts(firstSelectedTake())
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

function insertMidiNote(startingPositionArg, endingPositionArg, noteChannelArg, notePitchArg, noteVelocityArg)

	local keepNotesSelected = false
	local noteIsMuted = false

	local channel = getCurrentChannel(noteChannelArg)
	local velocity = getCurrentVelocity(noteVelocityArg)
	local noSort = false

	reaper.MIDI_InsertNote(firstSelectedTake(), keepNotesSelected, noteIsMuted, startingPositionArg, endingPositionArg, channel, notePitchArg, velocity, noSort)
end