local function loadDependency(arg)
  dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. arg .. ".lua")
end

loadDependency("preferences")
loadDependency("util")
loadDependency("Pickle")
loadDependency("midiEditor")


local function getStartingNotePositionsWithPitches()

	local numberOfNotes = getNumberOfNotes()
	local startingNotePositionsWithPitches = {}

	for noteIndex = 0, numberOfNotes-1 do

		local _, noteIsSelected, noteIsMuted, noteStartPositionPPQ, noteEndPositionPPQ, midiChannel, pitch = reaper.MIDI_GetNote(firstSelectedTake(), noteIndex)

			local existingValues = startingNotePositionsWithPitches[noteStartPositionPPQ]

			local pitches = nil

			if existingValues == nil then
				pitches = {}
			else
				pitches = existingValues
			end

			table.insert(pitches, pitch)


			startingNotePositionsWithPitches[noteStartPositionPPQ] = pitches
	end

	return startingNotePositionsWithPitches
end


local function getNearestPitchSet(startingNotePositionsWithPitches, rhythmStartingPosition)

	local nearestPitchSet = nil
	local minimumPpqDelta = 999999999

	for startingNotePosition, pitches in pairs(startingNotePositionsWithPitches) do

		local ppqDelta = math.abs(rhythmStartingPosition-startingNotePosition)

		if ppqDelta <= minimumPpqDelta then
			nearestPitchSet = pitches
			minimumPpqDelta = ppqDelta
		end
	end

	return nearestPitchSet
end


local function deleteAllNotes()

	local numberOfNotes = getNumberOfNotes()

	for noteIndex = numberOfNotes-1, 0, -1 do
		reaper.MIDI_DeleteNote(firstSelectedTake(), noteIndex)
	end
end


local rhythmNotes = getRhythmNotesFromPreferences()
local startingNotePositionsWithPitches = getStartingNotePositionsWithPitches()
deleteAllNotes()


for i = 1, #rhythmNotes do

	local rhythmNote = rhythmNotes[i]

	local rhythmNoteStartingPosition = rhythmNote[1][1]
	local rhythmNoteEndingPosition = rhythmNote[1][2]

	local rhythmNoteChannels = rhythmNote[2]
	local notePitches = getNearestPitchSet(startingNotePositionsWithPitches, rhythmNoteStartingPosition)
	local rhythmNoteVelocities = rhythmNote[3]

	for i = 1, #notePitches do
		insertMidiNote(rhythmNoteStartingPosition, rhythmNoteEndingPosition, rhythmNoteChannels[i], notePitches[i], rhythmNoteVelocities[i])
	end
end

