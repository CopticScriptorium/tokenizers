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

In order to retain the original word form border, the script optionally outputs the word
as well in a separate column at the beginning of each separate word form.

This script relies on a lexicon derived from materials kindly provided by Prof. Tito Orlandi
of the CMCL project. Please cite CMCL whenever using this script for your publications.