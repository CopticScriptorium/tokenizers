Coptic SCRIPTORIUM Tokenization Script
======================================
This Perl script tokenizes a running text of Sahidic Coptic word forms into their constituent
morphemes, ideally compatible with the Coptic SCRIPTORIUM part-of-speech tagging guidelines.
The script expects space separated word forms in UTF-8, e.g. (the UTF-8 equivalent of):

afsotp nqiphllo

Is tokenized into

a<br>
f<br>
sotp<br>
nqi<br>
p<br>
hllo<br>

In order to retain the original word form border, the script optionally outputs the whole word
as well in an SGML tag aruond each group of tokens. The script ignores inline SGML tags,
so you can tokenize files that already include tags, even within words. It is therefore possible
to tokenize the UTF-8 equivalent of <hi rend="big">t</hi>eishime ('this woman' with an annotated
initial tao). 

Usage:  tokenize_coptic.pl [options] <FILE>

Options and argument:

  * -h              print this [h]elp message and quit
  * -d              specify [d]ictionary file, default is copt_lex.tab in script directory
  * -s              specify [s]egmentation file, default is segmentation_table.tab in script directory
  * -m              specify [m]orph table file, default is morph_table.tab in script directory
  * -p              output [p]ipe separated word forms instead of tokens in separate lines wrapped by <norm> tags
  * -l               add [l]ine tags marking original linebreaks in input file
  * -n              [n]o output of word forms in <norm_group> elements before the set of tokens extracted from each group

Examples:

Tokenize a Coptic plain text file in UTF-8 encoding (without BOM):

tokenize_coptic.pl in_Coptic_utf8.txt > out_Coptic_tokenized.txt
  
  * v2.X.X adds the -l parameter, which allows tokenization of text that breaks across lines (as in a diplomatic transcription of a manuscript)
  * v3.X.X adds a file with most frequently used previous segmentations called segmentation_table.tab. This file should be in the same directory as the tokenizer and the lexicon file, copt_lex.tab.
  * v4.X.X adds morphological analysis and a corresponding file with known morphological segmentations, morph_table.tab.

Copyright 2013-2016, Amir Zeldes

This program is free software. You may copy or redistribute it under
the same terms as Perl itself.

This script relies on a lexicon derived from materials kindly provided by Prof. Tito Orlandi
of the CMCL project. Please cite CMCL whenever using this script for your publications.
