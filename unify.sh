#!/bin/sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function removeFile() {

	outputFile=${1##*/}

	rm "./pkg/pandabot_$outputFile"
}

function insertIntoFile() {

	dependencyFile=$1
	outputFile=${2##*/}

	grep -v "^loadDependency" "${DIR}"/$dependencyFile >> ./pkg/pandabot_$outputFile
}

function unify() {

	removeFile $1

	insertIntoFile util.lua $1
	insertIntoFile Pickle.lua $1
	insertIntoFile preferences.lua $1
	insertIntoFile midiEditor.lua $1

	insertIntoFile $1 $1
}

unify copyRhythm.lua
unify pasteRhythm.lua