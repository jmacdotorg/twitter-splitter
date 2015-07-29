# Twitter::Splitter

This repository contains a command-line program (twittersplit) which uses an also-included Perl module (Twitter::Splitter) to split up a textfile into tweet-length lines. It appends pager-text to every line, in "( _page_ / _total-pages_ )" format.

Command-line options allow you to specify that twittersplit should append the pager to the line, rather than prepend it, or that it should include additional text (such as a hashtag) to each.

In any event, each line, including the pager and the optional hashtag, will be 140 characters or fewer in length. 

Actually posting these lines to Twitter is left as an exercise for the hacker.

## Installation

To install the Perl module's dependencies, run this while in the same directory as this repository's `cpanfile`:

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

## Usage

Splitting the Gettysburg Address into tweets, variously:

    $ twittersplit gettysburg.txt

>(1/12) Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and dedicated to the

>(2/12) proposition that all men are created equal.

> [ ... ]

>(12/12) birth of freedom—and that government of the people, by the people, for the people, shall not perish from the earth.

----

    $ twittersplit --append-pager gettysburg.txt 

>Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and dedicated to the (1/12)

>proposition that all men are created equal. (2/12)

> [ ... ]

----

    $ twittersplit --append-pager --hashtag=#AmericanCivilWar gettysburg.txt

>Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and (1/14) #AmericanCivilWar

>dedicated to the proposition that all men are created equal. (2/14) #AmericanCivilWar

> [ ... ] 

## Bugs and such

* The program only works with textfiles using Unix-style newlines (LF), at present.

* Nothing is documented or test-covered at this time, oh dear.

## Author

Jason McIntosh (jmac@jmac.org)