# LICENSE
# (C) 2021 José María Lahoz-Bengoechea
# This file is part of Intonalyzer.
# Intonalyzer is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation
# either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# For more details, you can find the GNU General Public License here:
# http://www.gnu.org/licenses/gpl-3.0.en.html
# Intonalyzer runs on Praat, a software developed by Paul Boersma
# and David Weenink at University of Amsterdam.



clearinfo
printline Contact, questions, suggestions: José María Lahoz-Bengoechea'newline$''tab$'jmlahoz@ucm.es
printline
printline Intonalyzer is a tool designed to transcribe Spanish intonation
printline following ToBI principles.
printline It runs in two steps.
printline
printline -------------------------------------------------------------------------
printline
printline 1. Insert Break Indices
printline You must select a Sound and a TextGrid to run this script.
printline The input TextGrid must have a "words" and a "syll" tier,
printline e.g. as produced by EasyAlign.
printline The script checks the words against a list of Spanish clitics
printline and labels them with Break Index (BI) = 0.
printline Utterance-final words (detected by the following space or _)
printline are labeled with BI = 4.
printline The rest is labeled with BI = 2 by default.
printline An info window may appear warning about possible hand corrections
printline (e.g. homonyms that may or may not be clitics).
printline BI = 3 according to syntactic structure or relevant pauses
printline must be hand-corrected, too.
printline 
printline Boundaries signaled by Break Indices are interpreted as follows:
printline 0: (unstressed) clitic words
printline 1: stressed but deaccented words (W boundary)
printline 2: (prenuclear) accented words, i.e. accentual phrase (AP boundary)
printline 3: intermediate intonational phrase (iP boundary)
printline 4: (nuclear) accented words, i.e. major intonational phrase (IP boundary)
printline
printline -------------------------------------------------------------------------
printline
printline 2. Insert Tones
printline You must select a Sound and a TextGrid to run this script.
printline The input TextGrid must have a "syll" and a "BI" tier.
printline The script analyzes pitch movements
printline around stressed syllables (pitch accents)
printline and around phrase boundaries (boundary tones),
printline then labels them following ToBI principles.
printline The Melody tier transcribes surface pitch events.
printline The Tones tier interprets the underlying Tones
printline according to Spanish intonational phonology.
printline Some pitch events may be interpreted as interpolations,
printline in which case they will be considered cases of deaccentuation
printline and only the Melody tier will be filled,
printline but the Tones tier will be left empty and BI will be changed to 1.
printline You may then re-run the script choosing not to analyze BI = 1 at all,
printline as some other tones may be interpreted differently because of that.