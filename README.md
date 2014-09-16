Coptic SCRIPTORIUM Tokenization Script
======================================
This Perl script tokenizes a running text of Sahidic Coptic word forms into their constituent
morphemes, ideally compatible with the Coptic SCRIPTORIUM part-of-speech tagging guidelines.
The script expects space separated word forms in UTF-8, e.g. (the UTF-8 equivalent of):

afsotp nqi phllo

Is tokenized into

a
f
sotp
nqi
p
hllo

In order to retain the original word form border, the script optionally outputs the whole word
as well in an SGML tag aruond each group of tokens. The script ignores inline SGML tags,
so you can tokenize files that already include tags, even within words. It is therefore possible
to tokenize the UTF-8 equivalent of <hi rend="big">t</hi>eishime ('this woman' with an annotated
initial tao). 

Usage:  tokenize_coptic.pl [options] <FILE>

Options and argument:

-h              print this [h]elp message and quit
-p              output [p]ipe separated word forms instead of tokens in separate lines wrapped by <tok> tags
-n              [n]o output of word forms in <word> elements before the set of tokens extracted from each word

<FILE>    A text file encoded in UTF-8 without BOM, one word per line


Examples:

Tokenize a Coptic plain text file in UTF-8 encoding (without BOM):
  tokenize_coptic.pl in_Coptic_utf8.txt > out_Coptic_tokenized.txt

Copyright 2013-2014, Amir Zeldes

This program is free software. You may copy or redistribute it under
the same terms as Perl itself.

This script relies on a lexicon derived from materials kindly provided by Prof. Tito Orlandi
of the CMCL project. Please cite CMCL whenever using this script for your publications.