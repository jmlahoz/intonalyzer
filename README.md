LICENSE
(C) 2021 José María Lahoz-Bengoechea
This file is part of Intonalyzer.
Intonalyzer is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License
as published by the Free Software Foundation
either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY, without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
For more details, you can find the GNU General Public License here:
http://www.gnu.org/licenses/gpl-3.0.en.html
Intonalyzer is partially based on Eti-ToBI, by Wendy Elvira-García (2015),
and further developed by José María Lahoz-Bengoechea.
Intonalyzer runs on Praat, a software developed by Paul Boersma
and David Weenink at University of Amsterdam.

Suggested citation:

Lahoz-Bengoechea, José María (2021). Intonalyzer: A semi-automatic tool for Spanish intonation analysis (1.0) [Computer software]. https://github.com/jmlahoz/intonalyzer

------------------------------------------------------------------------------------------
Intonalyzer is a tool designed to transcribe Spanish intonation following ToBI principles.

How to install Intonalyzer as a Praat plugin in a permanent fashion:
1. Go to your Praat options folder.
   On Windows, this is under your user folder.
   For example, press the Windows key + R, type
   %USERPROFILE%\Praat
   and accept.
2. Create a subfolder named plugin_intonalyzer
   (this is case-sensitive).
3. Copy all the Intonalyzer files into that subfolder.
   You are ready to go.
   Next time you open Praat, go to the Praat menu on the objects window and
   you will find the Intonalyzer sub-menu.


Intonalyzer runs in two steps.

------------------------------------------------------------------------------------------

1. Insert Break Indices

You must select a Sound and a TextGrid to run this script.
The input TextGrid must have a "words" and a "syll" tier,
e.g. as produced by EasyAlign.
The files may contain one or more utterances.
The script checks the words against a list of Spanish clitics
and labels them with Break Index (BI) = 0.
Utterance-final words (detected by the following space or _)
are labeled with BI = 4.
The rest is labeled with BI = 2 by default.
An info window may appear warning about possible hand corrections
(e.g. homonyms that may or may not be clitics).
BI = 3 according to syntactic structure or relevant pauses
must be hand-corrected, too.

Boundaries signaled by Break Indices are interpreted as follows:

0: (unstressed) clitic words

1: stressed but deaccented words (W boundary)

2: (prenuclear) accented words, i.e. accentual phrase (AP boundary)

3: intermediate intonational phrase (iP boundary)

4: (nuclear) accented words, i.e. major intonational phrase (IP boundary)

-------------------------------------------------------------------------

2. Insert Tones

You must select a Sound and a TextGrid to run this script.
The input TextGrid must have a "syll" and a "BI" tier.
The script analyzes pitch movements
around stressed syllables (pitch accents)
and around phrase boundaries (boundary tones),
then labels them following ToBI principles.
The Melody tier transcribes surface pitch events.
The Tones tier interprets the underlying Tones
according to Spanish intonational phonology.
Some pitch events may be interpreted as interpolations,
in which case they will be considered cases of deaccentuation
and only the Melody tier will be filled,
but the Tones tier will be left empty and BI will be changed to 1.
You may then re-run the script choosing not to analyze BI = 1 at all,
as some other tones may be interpreted differently because of that.
