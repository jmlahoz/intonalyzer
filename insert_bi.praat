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


form Insert BI...
comment Do you want to keep the words tier?
boolean keep_words_tier 0
comment If BI tier already exists, do you want to overwrite it?
boolean overwrite 1
comment After processing...
boolean show_sound_and_tg 1
boolean show_info_window 1
endform

so = selected("Sound")
tg = selected("TextGrid")

if show_info_window = 1
clearinfo
printline Revisa: debes introducir los BI = 3 a mano (en lugar de 2 o 4) en las fronteras de grupo intermedio.
endif

cliticos = Read Table from comma-separated file... clíticos.csv
nclit = Get number of rows

select 'tg'
call findtierbyname words 1 1
wordtier = findtierbyname.return
call findtierbyname syll 1 1
sylltier = findtierbyname.return
call findtierbyname BI 0 0
bitier = findtierbyname.return
if bitier = 0
Insert point tier... wordtier+1 BI
else
if overwrite = 1
Remove tier... bitier
Insert point tier... bitier BI
else
Set tier name... bitier BIbak
Insert point tier... wordtier+1 BI
endif
endif
call findtierbyname BI 1 0
bitier = findtierbyname.return

nword = Get number of intervals... wordtier

for iword from 1 to nword-1
select tg
lab$ = Get label of interval... wordtier iword
lab2$ = Get label of interval... wordtier iword+1
end = Get end time of interval... wordtier iword
loint = Get low interval at time... sylltier end
hiint = Get high interval at time... sylltier end
if loint != hiint
t = end
elsif index("aeiouáéíóú",right$(lab$,1)) != 0 ; syllable merger context
t = Get end time of interval... sylltier hiint
else ; resyllabification context
t = Get start time of interval... sylltier loint
endif

Insert point... bitier t 
curbi = Get nearest index from time... bitier t

for iclit from 1 to nclit
select cliticos
iclitmay$ = Get value... iclit nacmay
iclitmin$ = Get value... iclit nacmin
if lab$ = iclitmay$ or lab$ = iclitmin$
select tg
Set point text... bitier curbi 0
if show_info_window = 1
if iclit > 12 and iclit < 21
printline Revisa: si en el intervalo 'iword' el posesivo "nuestro(a/os/as)", "vuestro(a/os/as)" es adjetivo en lugar de determinante, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 37
printline Revisa: si en el intervalo 'iword' "bajo" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 39
printline Revisa: si en el intervalo 'iword' "contra" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 43
printline Revisa: si en el intervalo 'iword' "entre" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 46
printline Revisa: si en el intervalo 'iword' "para" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 49
printline Revisa: si en el intervalo 'iword' "sobre" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 54
printline Revisa: si en el intervalo 'iword' "salvo" no es preposición, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 55
Set point text... bitier curbi 2
printline Revisa: si en el intervalo 'iword' "don" es tratamiento de cortesía, cambia el BI a 0 y quita la marca de acento de la sílaba.
elsif iclit = 58
Set point text... bitier curbi 2
printline Revisa: si en el intervalo 'iword' "santa" va seguido del nombre de la santa, cambia el BI a 0 y quita la marca de acento de la sílaba.
elsif iclit = 67
printline Revisa: si en el intervalo 'iword' "sino" significa 'destino', cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 71
printline Revisa: si en el intervalo 'iword' "mientras" es adverbio en lugar de conjunción, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 72
printline Revisa: si en el intervalo 'iword' "luego" es adverbio en lugar de conjunción, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
elsif iclit = 75
printline Revisa: si en el intervalo 'iword' "medio" no es adverbio, cambia el BI a 2 y añade la marca de acento a la sílaba correspondiente.
endif ; warning texts
endif ; show_info_window = 1
endif ; lab$ = iclitmay$ or lab$ = iclitmin$
endfor ; to nclit

select tg
if lab2$ = "_" or lab2$ = ""
Set point text... bitier curbi 4
elsif lab$ = "_" or lab$ = ""
Remove point... bitier curbi
else
curbi$ = Get label of point... bitier curbi
if curbi$ = ""
Set point text... bitier curbi 2
endif
endif

endfor ; to nword

if keep_words_tier = 0
select tg
Remove tier... wordtier
endif

select cliticos
Remove

select so
plus tg
if show_sound_and_tg = 1
View & Edit
endif

if show_info_window = 1
printline 
endif

procedure findtierbyname .name$ .v1 .v2
  .n = Get number of tiers
  .return = 0
  for .i to .n
    .tmp$ = Get tier name... '.i'
    if .tmp$==.name$
      .return = .i
    endif
  endfor
  if  (.return == 0) and (.v1 > 0)
    exit Tier ''.name$'' not found in TextGrid. Exiting...
  endif
  if  (.return > 0) and (.v2>0)
    .i = Is interval tier... '.return'
    if .i==0
      exit Tier #'.return' named '.name$' is not an interval tier. Exiting...
    endif
  endif

endproc

