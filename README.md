# Twitter::Splitter

This repository contains a command-line program (twittersplit) which uses an also-included Perl module (Twitter::Splitter) to split up a textfile into tweet-length lines. Each line begins with a "pager" in the ad-hoc "( _page_ / _total-pages_ )" format.

Command-line options allow you to specify that twittersplit should append the pager to the output lines, rather than prepend it, or that it should squeeze a bit of additional text (such as a hashtag) into every line. See __Usage__, below, for examples.

The program understands two or more newlines in the source file as a paragraph break, which it will respect in the output as an early line-end.

In any event, each line, including the pager and the optional hashtag, will be 140 characters or fewer in length. Actually posting these output lines to Twitter is left as an exercise for the hacker.

## Installation

To install the Perl module's dependencies, run this while in the same directory as this repository's `cpanfile`:

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

## Usage

Splitting the [Gettysburg Address](https://en.wikipedia.org/wiki/Gettysburg_Address) into tweets, variously:

**Default behavior**

    $ twittersplit gettysburg.txt

> (1/7) Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and dedicated to the proposition that all men are created equal.

> (2/7) Now we are engaged in a great civil war, testing whether that nation, or any nation so conceived and so dedicated, can long endure. We are met on a great battlefield of that war. We have come to dedicate a portion of that field, as a final resting place for those who here

> (3/7) gave their lives that that nation might live. It is altogether fitting and proper that we should do this.

> [ ... ]

> (7/7) government of the people, by the people, for the people, shall not perish from the earth.

----

**Classic-tweet-length tweets**

    $ twittersplit --tweet-length=140 gettysburg.txt

>(1/12) Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and dedicated to the

>(2/12) proposition that all men are created equal.

> [ ... ]

>(12/12) birth of freedom—and that government of the people, by the people, for the people, shall not perish from the earth.

----

**Append the pager, rather than prepend it**

    $ twittersplit --append-pager --tweet-length=140 gettysburg.txt 

>Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and dedicated to the (1/12)

>proposition that all men are created equal. (2/12)

> [ ... ]

----

**Add a hashtag to every generated tweet**

    $ twittersplit --append-pager --hashtag=#AmericanCivilWar gettysburg.txt

>Four score and seven years ago our fathers brought forth on this continent a new nation, conceived in liberty, and (1/14) #AmericanCivilWar

>dedicated to the proposition that all men are created equal. (2/14) #AmericanCivilWar

> [ ... ]

## Bugs and such

* The program only works with textfiles using Unix-style newlines (LF), at present.

* Beyond this README, nothing here is documented or test-covered at this time, oh dear.

## Author

Jason McIntosh (jmac@jmac.org)
