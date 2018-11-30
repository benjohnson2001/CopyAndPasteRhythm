local function loadDependency(arg)
  dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. arg .. ".lua")
end

loadDependency("util")
loadDependency("Pickle")
loadDependency("preferences")
loadDependency("midiEditor")


local function getExistingNote(existingNotes, startingNotePosition)

	for i = 1, #existingNotes do

		local existingNote = existingNotes[i]
		local existingNoteStartingPosition = existingNotes[i][1]

	  if existingNoteStartingPosition == startingNotePosition then
	  	return existingNote
	  end
	end

  return nil
end


local function getExistingNotes(selectedTake)

	local numberOfNotes = getNumberOfNotes(selectedTake)

	local existingNotes = {}

	for noteIndex = 0, numberOfNotes-1 do

		local _, noteIsSelected, noteIsMuted, noteStartPositionPPQ, noteEndPositionPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(selectedTake, noteIndex)

			local existingNote = getExistingNote(existingNotes, noteStartPositionPPQ)

			if existingNote == nil then

				existingNote = {}
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
			else
				table.insert(existingNote[2], noteChannel)
				table.insert(existingNote[3], noteVelocity)
				table.insert(existingNote[4], notePitch)
			end

			table.insert(existingNotes, existingNote)
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


local function pasteRhythm(mediaItem)

	local selectedTake = reaper.GetActiveTake(mediaItem)

	local rhythmNotes = getRhythmNotesFromPreferences()
	local existingNotes = getExistingNotes(selectedTake)

	deleteAllNotes(selectedTake)

	for i = 1, #rhythmNotes do

		local rhythmNote = rhythmNotes[i]

		local rhythmNoteStartingPosition = rhythmNote[1][1]
		local rhythmNoteEndingPosition = rhythmNote[1][2]

		local rhythmNoteChannels = rhythmNote[2]

		local notePitches = getNearestSetOfNotePitches(existingNotes, rhythmNoteStartingPosition)
		local noteChannels = getNearestSetOfNoteChannels(existingNotes, rhythmNoteStartingPosition)

		local rhythmNoteVelocities = rhythmNote[3]

		for i = 1, #notePitches do
			insertMidiNote(selectedTake, rhythmNoteStartingPosition, rhythmNoteEndingPosition, noteChannels[i], notePitches[i], rhythmNoteVelocities[i])
		end
	end
end

--

local numberOfSelectedItems = getNumberOfSelectedItems()

for i = 0, numberOfSelectedItems-1 do

	local activeProjectIndex = 0
	local selectedMediaITem = reaper.GetSelectedMediaItem(activeProjectIndex, i)
	pasteRhythm(selectedMediaITem)
end

