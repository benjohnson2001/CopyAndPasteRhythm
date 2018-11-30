local workingDirectory = reaper.GetResourcePath() .. "/Scripts/CopyAndPasteRhythm"
dofile(workingDirectory .. "/preferences")
dofile(workingDirectory .. "/util")
dofile(workingDirectory .. "/Pickle")
dofile(workingDirectory .. "/midiEditor")

local function getRhythmNote(rhythmNotes, startingNotePosition, endingNotePosition)

	for i = 1, #rhythmNotes do

		local rhythmNote = rhythmNotes[i]
		local rhythmNotePositions = rhythmNotes[i][1]

	  if rhythmNotePositions[1] == startingNotePosition and rhythmNotePositions[2] == endingNotePosition then
	      return rhythmNote
	  end
	end

  return nil
end


-- rhythmNote
-- {{startPosition, endPosition}, {channels}, {velocities}}
-- if there are more notes on the destination then get the default channel/velocity

local function getRhythmNotes()

	local numberOfNotes = getNumberOfNotes()
	local rhythmNotes = {}

	for noteIndex = 0, numberOfNotes-1 do

		local _, noteIsSelected, noteIsMuted, noteStartPositionPPQ, noteEndPositionPPQ, noteChannel, notePitch, noteVelocity  = reaper.MIDI_GetNote(firstSelectedTake(), noteIndex)
	
		if not (noteStartPositionPPQ == 0 and noteEndPositionPPQ == 0) then

			local rhythmNote = getRhythmNote(rhythmNotes, noteStartPositionPPQ, noteEndPositionPPQ)

			if rhythmNote == nil then
				rhythmNote = {}

				local rhythmNotePositions = {}
				table.insert(rhythmNotePositions, noteStartPositionPPQ)
				table.insert(rhythmNotePositions, noteEndPositionPPQ)

				local rhythmNoteChannels = {}
				table.insert(rhythmNoteChannels, noteChannel)

				local rhythmNoteVelocities = {}
				table.insert(rhythmNoteVelocities, noteVelocity)

				table.insert(rhythmNote, rhythmNotePositions)
				table.insert(rhythmNote, rhythmNoteChannels)
				table.insert(rhythmNote, rhythmNoteVelocities)

			else

				table.insert(rhythmNote[2], noteChannel)
				table.insert(rhythmNote[3], noteVelocity)
			end

			table.insert(rhythmNotes, rhythmNote)
		end
	end

	return rhythmNotes
end


--

local selectedTake = firstSelectedTake()
if selectedTake ~= nil then

		local rhythmNotes = getRhythmNotes()

		if rhythmNotes == nil then
			return
		end

		setRhythmNotesInPreferences(rhythmNotes)
end


