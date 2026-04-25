# Intonalyzer
# Author: José María Lahoz-Bengoechea
# License: GPL-3.0-or-later

# This script takes any number of TextGrids and name-matching Sounds within a folder.
# TextGrids must have a "words" and a "syll" tier, e.g. as produced by FastAlign.
# The files may contain one or more utterances.
# It yields Break Index (BI), Melody and Tones tiers following ToBI principles applied to Spanish.

form Batch Intonalyzer...
comment Write here the path to the folder containing the sounds and TextGrids
comment (any TextGrid should be named the same as its corresponding sound)
sentence folder 
comment Indicate the extension of the sound files
word sound_extension .flac
endform

str = Create Strings as file list... str 'folder$'/*.TextGrid

nstr = Get number of strings

for istr from 1 to nstr
select str

tg$ = Get string... istr
name$ = tg$ - ".TextGrid"
so$ = name$ + sound_extension$

so = Read from file... 'folder$'/'so$'
tg = Read from file... 'folder$'/'tg$'

select so
plus tg
runScript: "insert_bi.praat", "yes", "yes", "no", "no"
runScript: "insert_tones.praat", "\'1", 1.5, 6.0, "yes", "yes", "yes", "no", "yes"
select tg
Save as text file... 'folder$'/'tg$'

select so
plus tg
Remove

endfor ; to nstr

select str
Remove
