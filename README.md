# Swift Parser Exercises
Parser combinators exercise by Tony Morris/NICTA, ported to Swift from [the original Haskell version](https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/src/Course/Parser.hs).
 Please direct all credit to that original project, and attribute any mistakes to me.

The licence/copyright information for the original exercises is [included below](#licence-for-original-exercises).

## Instructions

Clone the repo and open the `ParserExerciseTests.swift` file in the ParserExerciseTests project. The aim is to fill in all the `TODO()` calls with valid implementations. Each time a `TODO()` is completed one or more of the tests should start passing.

The original exercises are designed to be done with an instructor, so if you run into an exercise that doesn't make sense from the context/comments alone then ask a question via [Github Issues](https://github.com/dtchepak/SwiftParserExercises/issues).

I've attempt to provide some tips on using [`flatMap`](https://github.com/dtchepak/SwiftParserExercises/blob/master/ParserExerciseTests/FlatMapPattern.swift) which may help for some of the exercises (or not).

## Licence for original exercises

[Licence source](https://github.com/NICTA/course/blob/af3e945d5eadcaf0a11a462e2ef7f5378b71d7f7/etc/LICENCE)

Copyright 2010-2013 Tony Morris
Copyright 2012-2015 National ICT Australia Limited 2012-2014
Copyright 2012      James Earl Douglas
Copyright 2012      Ben Sinclair

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of the author nor the names of his contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.
