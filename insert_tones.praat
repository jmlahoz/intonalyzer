# Intonalyzer
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2021-05-27

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


##{ Dialog window
form Intonalyzer...
optionmenu mark_of_tonic 2
option '
option \'1
real threshold_(St) 1.5
real upstep_threshold_(St) 6.0
boolean label_melody 1
boolean label_tones 1
boolean overwrite 1
boolean open_sound_and_tg 1
comment Analyze melody of deaccented words (marked as BI=1)?
boolean analyze_melody_of_BI_1 1
endform
##}

##{ Stipulated variables
f0_floor = 60
f0_ceiling = 600
negthreshold = 0 - threshold
##}

##{ Check conditions to continue
if label_melody = 0 and label_tones = 0
exit Choose at least one out of phonetic or phonological labels
endif

nso = numberOfSelected("Sound")
ntg = numberOfSelected("TextGrid")
if nso = 1 and ntg = 1
so = selected("Sound")
tg = selected("TextGrid")
else
exit Choose one Sound and one TextGrid
endif
##}

##{ Create objects to analyze pitch
select so
sofilt = Filter (stop Hann band)... 900 0 100
noprogress To Pitch... 0.001 f0_floor f0_ceiling ; time step of 0.001 means 1000 pitch values per second (too much? -- Praat suggests about 100, i.e. step of 0.01)
pitch = selected("Pitch")
select sofilt
Remove

select pitch
q25 = Get quantile... 0 0 0.25 Hertz
q75 = Get quantile... 0 0 0.75 Hertz
realfloor = q25 * 0.75
realceiling = q75 * 1.5
range = realceiling - realfloor
third_of_range = range/3
one_third = realfloor + (1*third_of_range)
two_thirds = realfloor + (2*third_of_range)

interpol_pitch = Interpolate
pitchtier = Down to PitchTier
##}

##{ Detect / create relevant tiers in TextGrid
select tg

call findtierbyname syll 1 1
sylltier = findtierbyname.return
call findtierbyname BI 1 0
bitier = findtierbyname.return
call findtierbyname Melody 0 0
melodytier = findtierbyname.return

if melodytier = 0
Insert point tier... bitier+1 Melody
else
if overwrite = 1
Remove tier... melodytier
Insert point tier... melodytier Melody
else
Set tier name... melodytier Melodybak
Insert point tier... bitier+1 Melody
endif
endif

call findtierbyname Tones 0 0
tonestier = findtierbyname.return

if tonestier = 0
Insert point tier... bitier+2 Tones
else
if overwrite = 1
Remove tier... tonestier
Insert point tier... tonestier Tones
else
Set tier name... tonestier Tonesbak
Insert point tier... bitier+2 Tones
endif
endif

call findtierbyname Melody 1 0
melodytier = findtierbyname.return
call findtierbyname Tones 1 0
tonestier = findtierbyname.return

##}

##{ Adapt mark of tonic
if mark_of_tonic = 2
select tg
Replace interval text... sylltier 0 0 \'1 ' Literals
endif
##}

##{ Initialization of variables
there_are_more_prenuclear_accents = 0
prev_tonic_ends_high = 0
tonic_ends_high = 0
there_is_high = 0
highest = 0
prevtargetsyll = 0
prevtone$ = ""
##}

# Loop for syllables
nsyll = Get number of intervals... sylltier

for isyll to nsyll
select tg
isyll$ = Get label of interval... sylltier isyll

# We only analyze tonic syllables 
if mid$(isyll$,1,1) = "'"

##{ Determine pretonic and postonic
there_is_pretonic = 1
if isyll = 1
there_is_pretonic = 0
else
prevsyll$ = Get label of interval... sylltier isyll-1
if prevsyll$ = "" or prevsyll$ = "_"
there_is_pretonic = 0
endif
endif

there_is_postonic = 1
if isyll = nsyll
there_is_postonic = 0
else
nextsyll$ = Get label of interval... sylltier isyll+1
if nextsyll$ = "" or nextsyll$ = "_"
there_is_postonic = 0
endif
endif
##}

##{ Get previous target syllable
select tg
ntonesnow = Get number of points... tonestier
if there_are_more_prenuclear_accents = 1
tprevtone = Get time of point... tonestier ntonesnow
prevtonesyll = Get interval at time... sylltier tprevtone
prevtone$ = Get label of point... tonestier ntonesnow
if prevtone$ = "L*+H" or prevtone$ = "L+<H*"
prevtargetsyll = prevtonesyll+1
else
prevtargetsyll = prevtonesyll
endif
endif
##}

##{ Get reference points along syllable duration
syllini = Get starting point... sylltier isyll
syllend = Get end point... sylltier isyll
syllmid = (syllini + syllend) / 2
if there_is_pretonic = 1
prevsyllini = Get starting point... sylltier isyll-1
prevsyllend = Get end point... sylltier isyll-1
prevsyllmid = (prevsyllini + prevsyllend) / 2
else
prevsyllini = syllini
prevsyllend = syllini
prevsyllmid = syllini
endif
if there_is_postonic = 1
nextsyllini = Get starting point... sylltier isyll+1
nextsyllend = Get end point... sylltier isyll+1
nextsyllmid = (nextsyllini + nextsyllend) / 2
else
nextsyllini = syllend
nextsyllend = syllend
nextsyllmid = syllend
endif
##}

##{ Get next Break Index
select tg
nextjuncture = Get high index from time... bitier syllmid
tbi = Get time of point... bitier nextjuncture
nextbi$ = Get label of point... bitier nextjuncture
nextbi = number(nextbi$)
##}

# Is nuclear accent?
if nextbi > 1-analyze_melody_of_BI_1 and nextbi < 4 ; prenuclear accents

##{ Get pitch values at reference points
select pitchtier
f01pre = Get value at time... prevsyllini
f02pre = Get value at time... prevsyllmid
f03pre = Get value at time... prevsyllend
f01ton = Get value at time... syllini
f02ton = Get value at time... syllmid
f03ton = Get value at time... syllend
f01pos = Get value at time... nextsyllini
f02pos = Get value at time... nextsyllmid
f03pos = Get value at time... nextsyllend
##}

##{ Get pitch maxima and minima
select pitch
f0maxpre = Get maximum... prevsyllini prevsyllend Hertz Parabolic
if f0maxpre = undefined
call undefined f0maxpre prevsyllend
f0maxpre = undefined.return
endif
f0maxton = Get maximum... syllini syllend Hertz Parabolic
if f0maxton = undefined
call undefined f0maxton syllend
f0maxton = undefined.return
endif
f0minton = Get minimum... syllini syllend Hertz Parabolic
tminton = Get time of minimum... syllini syllend Hertz Parabolic
if f0minton = undefined
call undefined f0minton syllend
f0minton = undefined.return
tminton = undefined.time
endif
pctminton = (tminton-syllini)/(syllend-syllini)
f0maxhalf2 = Get maximum... tminton syllend Hertz Parabolic
if f0maxhalf2 = undefined
call undefined f0maxhalf2 syllend
f0maxhalf2 = undefined.return
endif
f0maxpos = Get maximum... nextsyllini nextsyllend Hertz Parabolic
if f0maxpos = undefined
call undefined f0maxpos nextsyllend
f0maxpos = undefined.return
if f0maxpos = undefined
f0maxpos = realfloor
endif
endif
f0minpos = Get minimum... nextsyllini nextsyllend Hertz Parabolic
if f0minpos = undefined
call undefined f0minpos nextsyllend
f0minpos = undefined.return
if f0minpos = undefined
f0minpos = realfloor
endif
endif
##}

##{ Get pitch differences in semitones
difpreton = (12 / log10 (2)) * log10 (f02ton / f02pre)
diftonpos = (12 / log10 (2)) * log10 (f02pos / f02ton)
difton2pos3 = (12 / log10 (2)) * log10 (f03pos / f02ton)
difpremaxton = (12 / log10 (2)) * log10 (f0maxton / f02pre)
diftonton = (12 / log10 (2)) * log10 (f03ton / f01ton)
difton1ton2 = (12 / log10 (2)) * log10 (f02ton / f01ton)
difton2ton3 = (12 / log10 (2)) * log10 (f03ton / f02ton)
difprepre = (12 / log10 (2)) * log10 (f03pre / f01pre)
difprepos = (12 / log10 (2)) * log10 (f02pos / f02pre)
difmintonmaxpos = (12 / log10 (2)) * log10 (f0maxpos / f0minton)
difmaxtonmaxpos = (12 / log10 (2)) * log10 (f0maxpos / f0maxton)
difmintonmaxton = (12 / log10 (2)) * log10 (f0maxton / f0minton)
difminposmaxpos = (12 / log10 (2)) * log10 (f0maxpos / f0minpos)
difmaxhalf2maxpos = (12 / log10 (2)) * log10 (f0maxpos / f0maxhalf2)
##}

##{ CALCULATE PRENUCLEAR ACCENTS

# Empty labels will appear as default in case pitch does not match any recognizable pattern
surfacetone$ = ""
underlyingtone$ = ""

##{ Monotonal pitch accents
##{ Tonic is level
if (abs(difpreton) < threshold and abs(difmintonmaxpos) < threshold) or abs(diftonton) < threshold or abs(difmintonmaxton) < threshold

# Range-based method
if there_are_more_prenuclear_accents = 0
if f02ton >= two_thirds
surfacetone$ = "H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
there_is_high = 1
highest = f0maxton
else
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif

# Declination-based method
elsif there_are_more_prenuclear_accents = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0max_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0max_prevtarget = undefined
call undefined f0max_prevtarget prevtargetend
f0max_prevtarget = undefined.return
endif
difmaxprevtargetton = (12 / log10 (2)) * log10 (f02ton / f0max_prevtarget)
if (difmaxprevtargetton > negthreshold) and (prev_tonic_ends_high = 1)
surfacetone$ = "H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
else
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
endif ; there_are_more_prenuclear_accents = 0 then range-based, otherwise declination-based

endif ; tonic is level
##}

##{ Tonic target is Low and there is no postonic tone
if prev_tonic_ends_high = 1 ; by default that means there_are_more_prenuclear_accents = 1 (upon initialization, prev_tonic_ends_high = 0)
if (difmintonmaxton >= threshold) and (diftonton < 0) and (abs (difmintonmaxpos) < threshold)
if isyll-prevtargetsyll >= 2
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if difprevtargetpre < negthreshold
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
endif
endif
endif ; prev_tonic_ends_high = 1
##}
##}

##{ Bitonal pitch accents
##{ Falling
if prev_tonic_ends_high = 0
##{ H*+L
if (abs(difton1ton2) < threshold or abs(diftonton) < threshold)
... and (diftonpos < negthreshold or difton2pos3 < negthreshold or difmaxtonmaxpos < negthreshold)
surfacetone$ = "H*+L"
underlyingtone$ = "H*+L"
tonic_ends_high = 0
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
if (difpremaxton > threshold)
... and (diftonpos < negthreshold or difton2pos3 < negthreshold or difmaxtonmaxpos < negthreshold)
surfacetone$ = "H*+L"
underlyingtone$ = "H*+L"
tonic_ends_high = 0
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif

if underlyingtone$ = "H*+L" and nextbi = 3
surfacetone$ = "H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
endif
##}

##{ H+L*
if isyll-prevtargetsyll >= 2
if difpreton < negthreshold
surfacetone$ = "H+L*"
underlyingtone$ = "H+L*"
tonic_ends_high = 0
there_is_high = 1
if f0maxpre > highest
highest = f0maxpre
endif
endif
if difmintonmaxpos >= threshold and abs(difpreton) >= abs(difmintonmaxpos)
surfacetone$ = "H+(L*+H)"
underlyingtone$ = "H+L*"
tonic_ends_high = 0
there_is_high = 1
if f0maxpre > highest
highest = f0maxpre
endif
endif
endif
if (difmintonmaxton >= threshold) and (diftonton < 0) and (abs (difmintonmaxpos) < threshold)
surfacetone$ = "H+L*"
underlyingtone$ = "H+L*"
tonic_ends_high = 0
there_is_high = 1
if f0maxpre > highest
highest = f0maxpre
endif
endif
##}
endif ; prev_tonic_ends_high = 0 then falling trend is falling pitch accent
##}

##{ Rising
##{ L*+H
if difmintonmaxton < threshold and difmintonmaxpos >= threshold and difminposmaxpos >= threshold
surfacetone$ = "L*+H"
underlyingtone$ = "L*+H"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
if difpreton < negthreshold and difmintonmaxpos >= threshold and abs(difpreton) < abs(difmintonmaxpos)
surfacetone$ = "(H+L*)+H"
underlyingtone$ = "L*+H"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif

if underlyingtone$ = "L*+H" and nextbi = 3
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
##}

##{ L+H*
if difmintonmaxton >= threshold and diftonton > 0 and difmaxtonmaxpos < threshold
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
if difpreton >= threshold and difprepre < threshold
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
if prev_tonic_ends_high = 1 and isyll-prevtargetsyll >= 1 and difton1ton2 < 0 and pctminton < 0.70 and difmaxhalf2maxpos < threshold and prevtone$ != "L+<H*"
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
##}

##{ L+<H*
if difmintonmaxton >= threshold and diftonton > 0 and difmaxtonmaxpos >= threshold
surfacetone$ = "L+<H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
if difpreton >= threshold and diftonpos >= threshold
surfacetone$ = "L+<H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
if difmintonmaxton >= threshold and diftonton > 0 and (difmaxtonmaxpos > 0 or (f01pos >= f02ton and f02pos >= f01pos))
surfacetone$ = "L+<H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
if difprepre < 0 and (diftonton > 0 or difton2ton3 > 0)
if difmaxtonmaxpos >= threshold and prevtone$ = "L+<H*"
surfacetone$ = "L+H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
elsif difmaxtonmaxpos >= 0 and prevtone$ = "L+<H*"
surfacetone$ = "L+H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
endif
if prev_tonic_ends_high = 1 and isyll-prevtargetsyll < 2 and difton1ton2 < 0 and pctminton < 0.70
if difmaxhalf2maxpos >= threshold
surfacetone$ = "L+<H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
elsif prevtone$ = "L+<H*"
surfacetone$ = "L+H*"
underlyingtone$ = "L+<H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxpos > highest
highest = f0maxpos
endif
endif
endif
##}
##}
##}

##{ Deaccented
if prev_tonic_ends_high = 1
if (difpreton < negthreshold and diftonpos < negthreshold)
... or(difprepos < negthreshold and diftonton < threshold)
surfacetone$ = "H+L*"
underlyingtone$ = "deaccented"
endif
endif ; prev_tonic_ends_high = 1 then falling trend is interpolation and thereby deaccented

if prev_tonic_ends_high = 1 and isyll-prevtargetsyll < 2
if difton1ton2 < 0 and pctminton >= 0.70
surfacetone$ = "H+L*"
underlyingtone$ = "deaccented"
endif
endif ; prev_tonic_ends_high = 1 and there is stress clash, then falling trend (even not reaching threshold) is interpolation and thereby deaccented

# if syllend = tbi and index("aeiou",right$(prevsyll$,1))!=0 and (index("aeiou",left$(prevsyll$,1))!=0 or (mid$(prevsyll$,1,1)="'" and index("aeiou",mid$(prevsyll$,2,1))!=0))
if syllend = tbi and index("aeiou",right$(isyll$,1))!=0 and (index("aeiou",left$(nextsyll$,1))!=0 or (mid$(nextsyll$,1,1)="'" and index("aeiou",mid$(nextsyll$,2,1))!=0))
if prev_tonic_ends_high = 1 and (difmintonmaxton < threshold or diftonton < 0)
surfacetone$ = "H*"
underlyingtone$ = "deaccented"
elsif prev_tonic_ends_high = 0 and (difmintonmaxton < threshold or diftonton > 0)
surfacetone$ = "L*"
underlyingtone$ = "deaccented"
endif
endif

if prev_tonic_ends_high = 0 and there_are_more_prenuclear_accents = 1
if difpreton >= threshold and difmintonmaxton >= threshold and diftonton > 0
surfacetone$ = "L+H*"
underlyingtone$ = "deaccented"
endif
endif ; prev_tonic_ends_high = 0 then rising trend is interpolation and thereby deaccented
##}

##}

##{ Write calculated labels on TextGrid
select tg
if underlyingtone$ != "deaccented"
there_are_more_prenuclear_accents = 1
prev_tonic_ends_high = tonic_ends_high
Insert point... melodytier syllmid 'surfacetone$'
Insert point... tonestier syllmid 'underlyingtone$'
elsif nextbi = 2 or nextbi = 1 ; set BI to 1
Set point text... bitier nextjuncture 1
Insert point... melodytier syllmid 'surfacetone$'
else
there_are_more_prenuclear_accents = 1
prev_tonic_ends_high = tonic_ends_high
Insert point... melodytier syllmid 'surfacetone$'
Insert point... tonestier syllmid 'surfacetone$'
endif
##}

##{ Intermediate phrase (iP) boundary tones T- at Break Index 3
if nextbi = 3

##{ Get reference points
select tg
posbreak = Get interval at time... sylltier tbi
prebreak = posbreak - 1
prebreakini = Get starting point... sylltier prebreak
posbreakend = Get end point... sylltier posbreak
if prev_tonic_ends_high = 1 and right$(surfacetone$,1) = "*"
tailini = syllini
else
tailini = syllend
endif
##}

##{ Get pitch values at reference points
select pitchtier
f0atbi = Get value at time... tbi
f0posbreakend = Get value at time... posbreakend
f0prebreakini = Get value at time... prebreakini
f0tailini = Get value at time... tailini
##}

##{ Get pitch differences in semitones
diftailbi = (12 / log10 (2)) * log10 (f0atbi / f0tailini)
if there_is_high = 1
difhighestbi = (12 / log10 (2)) * log10 (f0atbi / highest)
else
difhighestbi = 0
endif
##}

##{ Calculate boundary tones (T-)
surfaceboundarytone$ = ""
underlyingboundarytone$ = ""

if f0prebreakini > f0atbi
# ... and f0posbreakend > f0atbi
surfaceboundarytone$ = "L-"
underlyingboundarytone$ = "L-"
endif

if f0prebreakini <= f0atbi and (diftailbi < upstep_threshold and difhighestbi < threshold)
# ... and f0posbreakend <= f0atbi 
surfaceboundarytone$ = "H-"
underlyingboundarytone$ = "H-"
there_is_high = 1
if f0atbi > highest
highest = f0atbi
endif
endif

if f0prebreakini <= f0atbi and (diftailbi >= upstep_threshold or difhighestbi >= threshold)
# ... and f0posbreakend <= f0atbi 
surfaceboundarytone$ = "HH-"
underlyingboundarytone$ = "HH-"
there_is_high = 1
if f0atbi > highest
highest = f0atbi
endif
endif
##}

##{ Write calculated labels on TextGrid
select tg
nocheck Insert point... melodytier tbi 'surfaceboundarytone$'
nocheck Insert point... tonestier tbi 'underlyingboundarytone$'
##}

endif ; nextbi = 3
##}

elsif nextbi = 4 ; nuclear accent

##{ Get stress pattern
select tg
lastsyll = Get low interval at time... sylltier tbi
stresspattern = lastsyll - isyll
##}

##{ Get reference points
if stresspattern = 0 ; word-final stress
sylldur = syllend - syllini
ton01 = syllini
ton02 = syllini + (0.25*sylldur)
ton03 = syllini + (0.50*sylldur)
tailini = syllini + (0.50*sylldur)
elsif stresspattern > 0 ; non-final stress
ton01 = syllini
ton02 = syllmid
ton03 = syllend
tailini = syllend
endif

taildur = tbi - tailini
tail_0  = tailini
tail_25 = tailini + (0.25*taildur)
tail_50 = tailini + (0.50*taildur)
tail_75 = tailini + (0.75*taildur)
tail_100 = tailini + (1.0*taildur)
##}

##{ Get pitch values at reference points
select pitchtier
f01pre = Get value at time... prevsyllini
f02pre = Get value at time... prevsyllmid
f03pre = Get value at time... prevsyllend
f01ton = Get value at time... ton01
f02ton = Get value at time... ton02
f03ton = Get value at time... ton03

f0tail_0 = Get value at time... tail_0
f0tail_25 = Get value at time... tail_25
f0tail_50 = Get value at time... tail_50
f0tail_75 = Get value at time... tail_75
f0tail_100 = Get value at time... tail_100
##}

##{ Get pitch maxima and minima
select pitch
f0maxton = Get maximum... ton01 ton03 Hertz Parabolic
if f0maxton = undefined
call undefined f0maxton ton03
f0maxton = undefined.return
endif
f0minton = Get minimum... ton01 ton03 Hertz Parabolic
if f0minton = undefined
call undefined f0minton ton03
f0minton = undefined.return
endif

f0maxtail_050 = Get maximum... f0tail_0 f0tail_50 Hertz Parabolic
if f0maxtail_050 = undefined
f0maxtail_050 = f0tail_50
endif
f0mintail_050 = Get minimum... f0tail_0 f0tail_50 Hertz Parabolic
if f0mintail_050 = undefined
f0mintail_050 = f0tail_50
endif
##}

##{ Get pitch differences in semitones
difpreton = (12 / log10 (2)) * log10 (f02ton / f02pre)
difpremaxton = (12 / log10 (2)) * log10 (f0maxton / f02pre)
diftonton = (12 / log10 (2)) * log10 (f03ton / f01ton)
difton1ton2 = (12 / log10 (2)) * log10 (f02ton / f01ton)
difton2ton3 = (12 / log10 (2)) * log10 (f03ton / f02ton)
difprepre = (12 / log10 (2)) * log10 (f03pre / f01pre)
difmintonmaxton = (12 / log10 (2)) * log10 (f0maxton / f0minton)
difmaxtontail_100 = (12 / log10 (2)) * log10 (f0tail_100 / f0maxton)

if there_is_high = 1
difhighestmaxton = (12 / log10 (2)) * log10 (f0maxton / highest)
difhighestend = (12 / log10 (2)) * log10 (f0tail_100 / highest)
elsif there_is_high = 0
difhighestmaxton = 0
difhighestend = 0
endif

# diftail_025 = (12 / log10 (2)) * log10 (f0tail_25 / f0tail_0)
diftail_050 = (12 / log10 (2)) * log10 (f0tail_50 / f0tail_0)
diftail_2550 = (12 / log10 (2)) * log10 (f0tail_50 / f0tail_25)
# diftail_5075 = (12 / log10 (2)) * log10 (f0tail_75 / f0tail_50)
# diftail_75100 = (12 / log10 (2)) * log10 (f0tail_100 / f0tail_75)
diftail_50100 = (12 / log10 (2)) * log10 (f0tail_100 / f0tail_50)
diftail_0100 = (12 / log10 (2)) * log10 (f0tail_100 / f0tail_0)
diftail_0max050 = (12 / log10 (2)) * log10 (f0maxtail_050 / f0tail_0)

##}

##{ CALCULATE NUCLEAR ACCENTS

# Empty labels will appear as default in case pitch does not match any recognizable pattern
surfacetone$ = ""
underlyingtone$ = ""

##{ Monotonal pitch accents
##{ Tonic is level
if abs(difpreton) < threshold or abs(diftonton) < threshold or abs(difmintonmaxton) < threshold

# Range-based method
if there_are_more_prenuclear_accents = 0
if f01ton >= two_thirds ; prenuclear accents based on f02ton instead of f01ton
surfacetone$ = "H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
there_is_high = 1
highest = f0maxton
else
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif

# Declination-based method
else ; there_are_more_prenuclear_accents = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0max_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0max_prevtarget = undefined
call undefined f0max_prevtarget prevtargetend
f0max_prevtarget = undefined.return
endif
difmaxprevtargetton = (12 / log10 (2)) * log10 (f02ton / f0max_prevtarget)
if difmaxprevtargetton >= threshold and prev_tonic_ends_high = 1
surfacetone$ = "¡H*"
underlyingtone$ = "¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
elsif difmaxprevtargetton > negthreshold and prev_tonic_ends_high = 1
surfacetone$ = "H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
elsif difhighestmaxton >= threshold
surfacetone$ = "¡H*"
underlyingtone$ = "¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
else
surfacetone$ = "L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
endif ; there_are_more_prenuclear_accents = 0 then range-based, otherwise declination-based

endif ; tonic is level
##}

##{ Underlying monotonal with surface contour
##{ Tonic is underlyingly low (but falling on the surface)
if prev_tonic_ends_high = 1
if (difmintonmaxton >= threshold) and (diftonton < 0)
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
if isyll-prevtargetsyll >= 2
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if difprevtargetpre <= negthreshold
surfacetone$ = "H+L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
else ; stress clash
difprevtargetton = (12 / log10 (2)) * log10 (f02ton / f0_prevtarget)
if difprevtargetton <= negthreshold
surfacetone$ = "H+L*"
underlyingtone$ = "L*"
tonic_ends_high = 0
endif
endif
endif
endif ; prev_tonic_ends_high = 1
##}

##{ Tonic is underlyingly high (but rising on the surface)
if prev_tonic_ends_high = 0
if (difmintonmaxton >= threshold) and (diftonton > 0)
if isyll-prevtargetsyll >= 2 and there_are_more_prenuclear_accents = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if difprevtargetpre > threshold
surfacetone$ = "L+H*"
underlyingtone$ = "H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
endif
endif
endif ; prev_tonic_ends_high = 0
##}

##{ Tonic is underlyingly upstep-high (and rising on the surface)
if prev_tonic_ends_high = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetton = (12 / log10 (2)) * log10 (f02ton / f0_prevtarget)
if difprevtargetton > threshold
surfacetone$ = "¡H*"
underlyingtone$ = "¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
endif ; prev_tonic_ends_high = 1
##}
##}
##}

##{ Bitonal pitch accents
##{ Falling
##{ H+L*

if difpreton < negthreshold or diftonton < negthreshold or(difmintonmaxton >= threshold and diftonton < 0)
if prev_tonic_ends_high = 0
surfacetone$ = "H+L*"
underlyingtone$ = "H+L*"
tonic_ends_high = 0
elsif prev_tonic_ends_high = 1 and isyll-prevtargetsyll > 0
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if difprevtargetpre > negthreshold
surfacetone$ = "H+L*"
underlyingtone$ = "H+L*"
tonic_ends_high = 0
endif
endif
endif

##}
##}

##{ Rising
##{ L+H*
if difpreton >= threshold or diftonton >= threshold or (difmintonmaxton >= threshold and diftonton > 0)
if there_are_more_prenuclear_accents = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if prev_tonic_ends_high = 0 and isyll-prevtargetsyll >= 2 and difprevtargetpre < threshold
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
elsif prev_tonic_ends_high = 1 and isyll-prevtargetsyll >=2 and difprevtargetpre < negthreshold
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
elsif there_are_more_prenuclear_accents = 0
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
endif
if (difpreton <= negthreshold or difprepre <= negthreshold) and difton2ton3 >= threshold and abs(difton2ton3) > abs(difton1ton2)
surfacetone$ = "L+H*"
underlyingtone$ = "L+H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
##}

##{ L+¡H*
if difpreton >= threshold or diftonton >= threshold or (difmintonmaxton >= threshold and diftonton > 0)
if there_are_more_prenuclear_accents = 1
select tg
prevtargetini = Get starting point... sylltier prevtargetsyll
prevtargetend = Get end point... sylltier prevtargetsyll
select pitch
f0_prevtarget = Get maximum... prevtargetini prevtargetend Hertz Parabolic
if f0_prevtarget = undefined
call undefined f0_prevtarget prevtargetend
f0_prevtarget = undefined.return
endif
difprevtargetpre = (12 / log10 (2)) * log10 (f02pre / f0_prevtarget)
if prev_tonic_ends_high = 0 and isyll-prevtargetsyll >= 2 and difprevtargetpre < threshold
... and (difhighestmaxton >= threshold or difpremaxton >= upstep_threshold or diftonton >= upstep_threshold or (difmintonmaxton >= upstep_threshold and diftonton > 0))
surfacetone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
elsif prev_tonic_ends_high = 1 and isyll-prevtargetsyll >=2 and difprevtargetpre < negthreshold
... and (difhighestmaxton >= threshold or difpremaxton >= upstep_threshold or diftonton >= upstep_threshold or (difmintonmaxton >= upstep_threshold and diftonton > 0))
surfacetone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
elsif there_are_more_prenuclear_accents = 0
... and (difpremaxton >= upstep_threshold or diftonton >= upstep_threshold or (difmintonmaxton >= upstep_threshold and diftonton > 0))
surfacetone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
endif
if (difpreton <= negthreshold or difprepre <= negthreshold) and difton2ton3 >= threshold and abs(difton2ton3) > abs(difton1ton2)
... and (difhighestmaxton >= threshold or difpremaxton >= upstep_threshold or diftonton >= upstep_threshold or (difmintonmaxton >= upstep_threshold and diftonton > 0))
surfacetone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
tonic_ends_high = 1
there_is_high = 1
if f0maxton > highest
highest = f0maxton
endif
endif
##}
##}
##}

##{ Tritonal pitch accents
##{ L+H*+L
if difton1ton2 >= threshold and difton2ton3 <= negthreshold
surfacetone$ = "L+H*+L"
underlyingtone$ = "L+H*+L"
tonic_ends_high = 0
endif
##}
##{ L+¡H*+L
if difton1ton2 >= threshold and difton2ton3 <= negthreshold
... and (abs(difton1ton2) >= upstep_threshold or abs(difton2ton3) >= upstep_threshold or difhighestmaxton >= threshold)
surfacetone$ = "L+¡H*+L"
underlyingtone$ = "L+¡H*+L"
tonic_ends_high = 0
endif
##}
##}

##}

##{ Write calculated labels on TextGrid
select tg
Insert point... melodytier ton02 'surfacetone$'
Insert point... tonestier ton02 'underlyingtone$'
##}

##{ Recalculate highest pitch
if there_is_high = 1
difhighestmaxton = (12 / log10 (2)) * log10 (f0maxton / highest)
difhighestend = (12 / log10 (2)) * log10 (f0tail_100 / highest)
elsif there_is_high = 0
difhighestmaxton = 0
difhighestend = 0
endif
##}

##{ Intonational phrase (IP) boundary tones T% at Break Index 4

# Empty labels will appear as default in case pitch does not match any recognizable pattern
surfaceboundarytone$ = ""
underlyingboundarytone$ = ""

##{ Monotonal boundary tones

##{ L%
if tonic_ends_high = 0 and diftail_050 < threshold and diftail_50100 < threshold
surfaceboundarytone$ = "L%"
underlyingboundarytone$ = "L%"
endif
if tonic_ends_high = 1 and diftail_050 < negthreshold and diftail_50100 < threshold and f0tail_100 < one_third
surfaceboundarytone$ = "L%"
underlyingboundarytone$ = "L%"
endif
if tonic_ends_high = 0 and diftail_050 >= threshold and diftail_50100 > negthreshold and f0tail_100 < one_third
surfaceboundarytone$ = "L%"
underlyingboundarytone$ = "L%"
endif
if tonic_ends_high = 0 and (abs(diftail_050) < threshold or diftail_050 <= negthreshold) and diftail_50100 >= threshold and f0tail_100 < one_third
surfaceboundarytone$ = "L%"
underlyingboundarytone$ = "L%"
endif
##}

##{ H%
if tonic_ends_high = 0 and diftail_050 >= threshold and diftail_50100 > negthreshold and f0tail_100 >= two_thirds
... and diftail_0100 < upstep_threshold and difhighestend < threshold
surfaceboundarytone$ = "H%"
underlyingboundarytone$ = "H%"
endif
if tonic_ends_high = 1 and diftail_050 > negthreshold and diftail_50100 > negthreshold and diftail_0100 < threshold and difhighestend < threshold
surfaceboundarytone$ = "H%"
underlyingboundarytone$ = "H%"
endif
##}

##{ HH%
if tonic_ends_high = 0 and ((diftail_0100 >= upstep_threshold or difmaxtontail_100 >= upstep_threshold)
... or ((diftail_0100 >= threshold or difmaxtontail_100 >= threshold) and difhighestend >= threshold))
surfaceboundarytone$ = "HH%"
underlyingboundarytone$ = "HH%"
endif
if tonic_ends_high = 1
... and (((diftail_050 >= threshold and diftail_50100 > negthreshold)
... or (diftail_050 > negthreshold and diftail_50100 >= threshold)
... or diftail_0100 >= threshold)
... or difhighestend >= threshold)
surfaceboundarytone$ = "HH%"
underlyingboundarytone$ = "HH%"
endif

if underlyingboundarytone$ = "HH%"
select tg
ntonesnow = Get number of points... tonestier
prevtone$ = Get label of point... tonestier ntonesnow
if prevtone$ = "L+¡H*"
underlyingtone$ = "L+H*"
Set point text... tonestier ntonesnow 'underlyingtone$'
endif
endif

##}

##{ M%
if tonic_ends_high = 0 and diftail_050 >= threshold and diftail_50100 > negthreshold and f0tail_100 >= one_third and f0tail_100 < two_thirds
surfaceboundarytone$ = "M%"
underlyingboundarytone$ = "M%"
endif
if tonic_ends_high = 1 and (diftail_050 <= negthreshold and diftail_50100 < threshold) and f0tail_100 >= one_third
surfaceboundarytone$ = "M%"
underlyingboundarytone$ = "M%"
endif
if tonic_ends_high = 1 and difmaxtontail_100 < 1 and taildur > 0.500 and f0tail_100 > one_third
surfaceboundarytone$ = "M%"
underlyingboundarytone$ = "M%"
endif
if tonic_ends_high = 1 and abs(diftail_050) < threshold and diftail_50100 <= negthreshold and f0tail_100 > one_third
... and stresspattern = 0
surfaceboundarytone$ = "HM%"
underlyingboundarytone$ = "M%"
endif
if tonic_ends_high = 1 and (diftail_050 >= threshold or diftail_0max050 >= threshold) and diftail_50100 <= negthreshold and f0tail_100 > one_third
... and stresspattern = 0
surfaceboundarytone$ = "¡HM%"
underlyingboundarytone$ = "M%"
select tg
ntonesnow = Get number of points... tonestier
prevtone$ = Get label of point... tonestier ntonesnow
if prevtone$ = "H*" or prevtone$ = "¡H*"
underlyingtone$ = "¡H*"
Set point text... tonestier ntonesnow 'underlyingtone$'
elsif prevtone$ = "L+H*" or prevtone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
Set point text... tonestier ntonesnow 'underlyingtone$'
endif
endif
##}

##}

##{ Bitonal boundary tones

##{ HL%
if tonic_ends_high = 0 and diftail_050 >= threshold and diftail_50100 <= negthreshold and f0tail_100 <= one_third
surfaceboundarytone$ = "HL%"
underlyingboundarytone$ = "HL%"
endif
if tonic_ends_high = 1 and abs(diftail_050) < threshold and diftail_50100 <= negthreshold and f0tail_100 <= one_third
surfaceboundarytone$ = "HL%"
underlyingboundarytone$ = "HL%"
endif
if tonic_ends_high = 1 and diftail_050 >= threshold and diftail_50100 <= negthreshold and f0tail_100 <= one_third
surfaceboundarytone$ = "¡HL%"
underlyingboundarytone$ = "HL%"
endif

if surfaceboundarytone$ = "¡HL%"
select tg
ntonesnow = Get number of points... tonestier
prevtone$ = Get label of point... tonestier ntonesnow
if prevtone$ = "H*" or prevtone$ = "¡H*"
underlyingtone$ = "¡H*"
underlyingboundarytone$ = "L%"
Set point text... tonestier ntonesnow 'underlyingtone$'
elsif prevtone$ = "L+H*" or prevtone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
underlyingboundarytone$ = "L%"
Set point text... tonestier ntonesnow 'underlyingtone$'
endif
endif
##}

##{ HM%
if tonic_ends_high = 0 and (diftail_050 >= threshold or diftail_0max050 >= threshold) and diftail_50100 <= negthreshold and f0tail_100 > one_third
surfaceboundarytone$ = "HM%"
underlyingboundarytone$ = "HM%"
endif
if tonic_ends_high = 1 and abs(diftail_050) < threshold and diftail_50100 <= negthreshold and f0tail_100 > one_third
... and stresspattern > 0
surfaceboundarytone$ = "HM%"
underlyingboundarytone$ = "HM%"
endif
if tonic_ends_high = 1 and (diftail_050 >= threshold or diftail_0max050 >= threshold) and diftail_50100 <= negthreshold and f0tail_100 > one_third
... and stresspattern > 0
surfaceboundarytone$ = "¡HM%"
underlyingboundarytone$ = "HM%"
select tg
ntonesnow = Get number of points... tonestier
prevtone$ = Get label of point... tonestier ntonesnow
if prevtone$ = "H*" or prevtone$ = "¡H*"
underlyingtone$ = "¡H*"
underlyingboundarytone$ = "M%"
Set point text... tonestier ntonesnow 'underlyingtone$'
elsif prevtone$ = "L+H*" or prevtone$ = "L+¡H*"
underlyingtone$ = "L+¡H*"
underlyingboundarytone$ = "M%"
Set point text... tonestier ntonesnow 'underlyingtone$'
endif
endif
##}

##{ LH%
if tonic_ends_high = 0 and (abs(diftail_050) < threshold or abs(diftail_2550) < threshold or diftail_050 <= negthreshold) and diftail_50100 >= threshold and f0tail_100 >= two_thirds
surfaceboundarytone$ = "LH%"
underlyingboundarytone$ = "LH%"
endif
if tonic_ends_high = 1 and diftail_050 < negthreshold and diftail_50100 >= threshold and f0tail_100 >= two_thirds
surfaceboundarytone$ = "LH%"
underlyingboundarytone$ = "LH%"
endif
##}

##{ LM%
if tonic_ends_high = 0 and (abs(diftail_050) < threshold or diftail_050 <= negthreshold) and diftail_50100 >= threshold and f0tail_100 > one_third and f0tail_100 < two_thirds
surfaceboundarytone$ = "LM%"
underlyingboundarytone$ = "LM%"
endif
if tonic_ends_high = 1 and diftail_050 < negthreshold and diftail_50100 >= threshold and f0tail_100 < two_thirds
surfaceboundarytone$ = "LM%"
underlyingboundarytone$ = "LM%"
endif
##}

##}

##}

##{ Write calculated labels on TextGrid
select tg
nocheck Insert point... melodytier tbi 'surfaceboundarytone$'
nocheck Insert point... tonestier tbi 'underlyingboundarytone$'
##}

##{ Initialization of variables
# (in case there are new intonational groups after this, in the same file)
there_are_more_prenuclear_accents = 0
prev_tonic_ends_high = 0
tonic_ends_high = 0
there_is_high = 0
highest = 0
prevtargetsyll = 0
prevtone$ = ""
##}

endif ; prenuclear, otherwise nuclear accent
endif ; syllable is tonic
endfor ; to nsyll

##{ Restore mark of tonic
if mark_of_tonic = 2
select tg
Replace interval text... sylltier 0 0 ' \'1 Literals
endif
##}

##{ Remove tiers unasked for
if label_melody = 0
select tg
Remove tier... melodytier
endif
if label_tones = 0
select tg
Remove tier... tonestier
endif
##}

##{ Clear workspace and show result
select pitch
plus interpol_pitch
plus pitchtier
Remove
select so
plus tg
View & Edit
##}


# Procedures

procedure undefined .value .reftime
total_duration = Get total duration
.time = .reftime
while .value = undefined and .time < total_duration
.time = .time + 0.001
.value = Get value at time... .time Hertz Linear
endwhile
if .value = undefined
.time = .reftime
while .value = undefined and .time > 0
.time = .time - 0.001
.value = Get value at time... .time Hertz Linear
endwhile
endif
.return = .value
endproc

procedure findtierbyname .name$ .v1 .v2
  .n = Get number of tiers
  .return = 0
  for .i to .n
    .tmp$ = Get tier name... '.i'
    if .tmp$ == .name$
      .return = .i
    endif
  endfor
  if  (.return == 0) and (.v1 > 0)
    exit Tier ''.name$'' not found in TextGrid. Exiting...
  endif
  if  (.return > 0) and (.v2 > 0)
    .i = Is interval tier... '.return'
    if .i == 0
      exit Tier number '.return' named '.name$' is not an interval tier. Exiting...
    endif
  endif

endproc
