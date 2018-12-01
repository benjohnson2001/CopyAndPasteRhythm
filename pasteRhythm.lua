local function loadDependency(arg)
  dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. arg .. ".lua")
end

loadDependency("util")
loadDependency("Pickle")
loadDependency("preferences")
loadDependency("midiEditor")


local function getExistingNoteIndex(existingNotes, startingNotePosition)

	for i = 1, #existingNotes do

		local existingNote = existingNotes[i]
		local existingNoteStartingPosition = existingNotes[i][1]

	  if existingNoteStartingPosition == startingNotePosition then
	  	return i
	  end
	end

  return nil
end


local function getExistingNotes(selectedTake)

	local numberOfNotes = getNumberOfNotes(selectedTake)

	local existingNotes = {}

	for noteIndex = 0, numberOfNotes-1 do

		local _, noteIsSelected, noteIsMuted, noteStartPositionPPQ, noteEndPositionPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(selectedTake, noteIndex)

			local existingNoteIndex = getExistingNoteIndex(existingNotes, noteStartPositionPPQ)

			if existingNoteIndex == nil then

				local existingNote = {}
				table.insert(existingNote, noteStartPositionPPQ)

				local existingNoteChannels = {}
				table.insert(existingNoteChannels, noteChannel)

				local existingNoteVelocities = {}
				table.insert(existingNoteVelocities, noteVelocity)

				local existingNotePitches = {}
				table.insert(existingNotePitches, notePitch)

				table.insert(existingNote, existingNoteChannels)
				table.insert(existingNote, existingNoteVelocities)
				table.insert(existingNote, existingNotePitches)

				table.insert(existingNotes, existingNote)
			else

				local existingNote = existingNotes[existingNoteIndex]

				table.insert(existingNote[2], noteChannel)
				table.insert(existingNote[3], noteVelocity)
				table.insert(existingNote[4], notePitch)

				table.insert(existingNotes[existingNoteIndex], existingNote)
			end
	end

	return existingNotes
end


local function getNearestSetOfNotePitches(existingNotes, rhythmStartingPosition)

	local nearestSetOfNotePitches = nil
	local minimumPpqDelta = 999999999

	for i = 1, #existingNotes do

		local existingNote = existingNotes[i]

		local existingNoteStartingPosition = existingNote[1]
		local existingNotePitches = existingNote[4]

		local ppqDelta = math.abs(rhythmStartingPosition-existingNoteStartingPosition)

		if ppqDelta <= minimumPpqDelta then
			nearestSetOfNotePitches = existingNotePitches
			minimumPpqDelta = ppqDelta
		end
	end

	return nearestSetOfNotePitches
end

local function getNearestSetOfNoteChannels(existingNotes, rhythmStartingPosition)

	local nearestSetOfNoteChannels = nil
	local minimumPpqDelta = 999999999

	for i = 1, #existingNotes do

		local existingNote = existingNotes[i]

		local existingNoteStartingPosition = existingNote[1]
		local existingNoteChannels = existingNote[2]

		local ppqDelta = math.abs(rhythmStartingPosition-existingNoteStartingPosition)

		if ppqDelta <= minimumPpqDelta then
			nearestSetOfNoteChannels = existingNoteChannels
			minimumPpqDelta = ppqDelta
		end
	end

	return nearestSetOfNoteChannels
end

local function deleteAllNotes(selectedTake)

	local numberOfNotes = getNumberOfNotes(selectedTake)

	for noteIndex = numberOfNotes-1, 0, -1 do
		reaper.MIDI_DeleteNote(selectedTake, noteIndex)
	end
end


local function pasteRhythm(rhythmNotes, mediaItem)

	local selectedTake = reaper.GetActiveTake(mediaItem)
	
	local existingNotes = getExistingNotes(selectedTake)  

	if #existingNotes == 0 then
		return
	end

	deleteAllNotes(selectedTake)

	local previousNoteVelocity

	for i = 1, #rhythmNotes do

		local rhythmNote = rhythmNotes[i]

		local rhythmNoteStartingPosition = rhythmNote[1][1]
		local rhythmNoteEndingPosition = rhythmNote[1][2]

		--local rhythmNoteChannels = rhythmNote[2]

		local notePitches = getNearestSetOfNotePitches(existingNotes, rhythmNoteStartingPosition)
		local noteChannels = getNearestSetOfNoteChannels(existingNotes, rhythmNoteStartingPosition)

		local rhythmNoteVelocities = rhythmNote[3]

		for j = 1, #notePitches do

			local velocity = rhythmNoteVelocities[j]

			if velocity == nil then
				velocity = previousNoteVelocity
			else
				previousNoteVelocity = velocity
			end

			insertMidiNote(selectedTake, rhythmNoteStartingPosition, rhythmNoteEndingPosition, noteChannels[j], notePitches[j], velocity)
		end
	end
end

--


reaper.defer(emptyFunctionToPreventAutomaticCreationOfUndoPoint)

local numberOfSelectedItems = getNumberOfSelectedItems()

if numberOfSelectedItems == 0 then
	return
end

local rhythmNotes = getRhythmNotesFromPreferences()

if rhythmNotes == nil then
	return
end

for i = 0, numberOfSelectedItems-1 do

	local activeProjectIndex = 0
	local selectedMediaItem = reaper.GetSelectedMediaItem(activeProjectIndex, i)

	startUndoBlock()
		pasteRhythm(rhythmNotes, selectedMediaItem)
	endUndoBlock("paste rhythm")
end
