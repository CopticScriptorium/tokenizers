#!/usr/bin/perl -w

# tokenize_coptic.pl Version 0.9.3

# this assumes a UTF-8 file with untokenized 'word forms'
# separated by spaces
# usage:
# tokenize_coptic.pl [options] file
# See help (-h) for options

use Getopt::Std;
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

my $usage;
{
$usage = <<"_USAGE_";
This script converts characters from one Coptic encoding to another.

Notes and assumptions:
- ...

Usage:  tokenize_coptic.pl [options] <FILE>

Options and argument:

-h              print this [h]elp message and quit
-p              output [p]ipe separated word forms instead of one token per line
-n              [n]o output of word forms before the set of tokens extracted from each word

<FILE>    A text file encoded in UTF-8 without BOM, one word per line


Examples:

Tokenize a Coptic plain text file in UTF-8 encoding (without BOM):
  tokenize_coptic.pl in_Coptic_utf8.txt > out_Coptic_tokenized.txt

Copyright 2013, Amir Zeldes

This program is free software. You may copy or redistribute it under
the same terms as Perl itself.
_USAGE_
}

### OPTIONS BEGIN ###
%opts = ();
getopts('hnp',\%opts) or die $usage;

#help
if ($opts{h} || (@ARGV == 0)) {
    print $usage;
    exit;
}
if ($opts{p})   {$pipes = 0;} else {$pipes = 1;}
if ($opts{n})   {$noword = 1;} else {$noword = 0;}

### OPTIONS END ###

### BUILD LEXICON ###
#build function word lists
$pprep = "ⲁϫⲛⲧ|ⲉϩⲣⲁ|ⲉϩⲣⲁⲓⲉϫⲱ|ⲉϫⲛⲧⲉ|ⲉϫⲱ|ⲉⲣⲁⲧ|ⲉⲣⲁⲧⲟⲩ|ⲉⲣⲟ|ⲉⲣⲱ|ⲉⲧⲃⲏⲏⲧ|ⲉⲧⲟⲟⲧ|ϩⲁⲉⲓⲁⲧ|ϩⲁϩⲧⲏ|ϩⲁⲣⲁⲧ|ϩⲁⲣⲓϩⲁⲣⲟ|ϩⲁⲣⲟ|ϩⲁⲣⲱ|ϩⲁⲧⲟⲟⲧ|ϩⲓϫⲱ|ϩⲓⲣⲱ|ϩⲓⲧⲉ|ϩⲓⲧⲟⲟⲧ|ϩⲓⲧⲟⲩⲱ|ϩⲓⲱ|ϩⲓⲱⲱ|ⲕⲁⲧⲁⲣⲟ|ⲕⲁⲧⲁⲣⲱ|ⲙⲙⲟ|ⲙⲙⲱ|ⲙⲛⲛⲥⲱ|ⲙⲡⲁⲙⲧⲟⲉⲃⲟⲗ|ⲛⲏⲧⲛ|ⲛⲁ|ⲛϩⲏⲧ|ⲛⲙⲙⲏ|ⲛⲙⲙⲁ|ⲛⲥⲁⲃⲗⲗⲁ|ⲛⲥⲱ|ⲛⲧⲟⲟⲧ|ⲟⲩⲃⲏ|ϣⲁⲣⲟ|ϣⲁⲣⲱⲧⲛ|ⲛⲏ|ⲛⲛⲁϩⲣⲁ|ⲟⲩⲧⲱ|ⲛⲛⲁϩⲣⲏ|ϩⲁⲧⲏ|ⲉⲧⲃⲏⲏ|ⲛⲣⲁⲧ|ⲉⲣⲁ|ⲛⲁϩⲣⲁ|ⲛϩⲏ|ϩⲓⲧⲟⲟ|ⲕⲁⲧⲁ|ⲙⲉⲭⲣⲓ|ⲡⲁⲣⲁ|ⲙ|ⲛ|ⲉⲧⲃⲉ";
$nprep = "ⲉ|ⲛ|ⲙ|ⲉⲧⲃⲉ";
$ppers = "ⲓ|ⲕ|ϥ|ⲥ|ⲛ|ⲧⲉⲧⲛ|ⲩ";
$ppero = "ⲓ|ⲕ|ϥ|ⲥ|ⲛ|ⲧⲛ|ⲧⲏⲩⲧⲛ|ⲩ|ⲟⲩ";
$art = "ⲡ|ⲛ|ⲧ|ⲟⲩ|ϩⲉⲛ|ⲡⲉⲓ|ⲧⲉⲓ|ⲛⲉⲓ";
$ppos = "[ⲡⲧⲛ]ⲉ[ⲕϥⲥⲛⲩ]|[ⲡⲧⲛ]ⲉⲧⲛ|[ⲡⲧⲛ]ⲁ";
$triprobase = "ⲁ|ⲙⲡ|ϣⲁ|ⲙⲉ|ⲙⲡⲁⲧ|ϣⲁⲛⲧ|ⲛⲧⲉⲣⲉ|ⲛⲛⲉ|ⲛⲧⲉ|ⲛ|ⲧⲣⲉ|ⲧⲁⲣⲉ|ⲙⲁⲣⲉ|ⲙⲡⲣⲧⲣⲉ"; 
$trinbase = "ⲁ|ⲙⲡⲉ|ϣⲁⲣⲉ|ⲙⲉⲣⲉ|ⲙⲡⲁⲧⲉ|ϣⲁⲛⲧⲉ|ⲛⲧⲉⲣⲉ|ⲛⲛⲉ|ⲛⲧⲉⲣⲉ|ⲛⲧⲉ|ⲧⲣⲉ|ⲧⲁⲣⲉ|ⲙⲁⲣⲉ|ⲙⲡⲣⲧⲣⲉ";
$bibase = "ϯ|ⲧⲉ|ⲕ|ϥ|ⲥ|ⲧⲛ|ⲧⲉⲧⲛ|ⲥⲉ";
$exist = "ⲟⲩⲛ|ⲙⲛ";



#get external open class lexicon
$lexicon = "copt_lex.tab";
if ($lexicon ne "")
{
open LEX,"<:encoding(UTF-8)",$lexicon or die "could not find lexicon file";
while (<LEX>) {
    chomp;
	if ($_ =~ /^(.*)\t(.*)\t(.*)$/) #ignore comments in modifier file marked by #
    {
	if ($2 eq 'N') {$nounlist .= "$1|";} 
	if ($2 eq 'NPROP') {$namelist .= "$1|";} 
	elsif ($2 eq 'V') {	$verblist .= "$1|";} 
	elsif ($2 eq 'VSTAT') {$vstatlist .= "$1|";} 
	elsif ($2 eq 'ADV') {$advlist .= "$1|";} 
	elsif ($2 eq 'VBD') {$vbdlist .= "$1|";} 
	else {$stoplist{$1} = "$1;$2";} 
	}
}
$nounlist .="%%%";
$verblist .="%%%";
$vstatlist .="%%%";
$advlist .="%%%";
$namelist .="%%%";
}
### END LEXICON ###

# ADD TAG SUPPORT TO LEXICON
$namelist =~ s/(.)/$1(?:(?:<[^>]+>)+)?/g;


open FILE,"<:encoding(UTF-8)",shift or die "could not find input document";

while (<FILE>) {

    chomp;
    $line = $_;

	#protect up to *4* spaces in XML tags
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3\@$4\@$5/g; 
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3\@$4/g; 
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3/g; 
	$line =~ s/(<[^>]+) ([^>]+>)/$1\@$2/g; 
	
	$tagbuffer= "";
	$tagoutput="";
	
	@words = split(/ /, $line);
	foreach $word (@words)
	
	{
		$dipl = $word;
		$word =~ s/(̈|%|̄|`|̅)//g; 
		
		#remove supralinear strokes and other decorations for tokenization
		if ($word =~ /\|/) #pipes found, assume explicit tokenization is present
		{
			#@toks = split(/\|/, $word);

		}
		else #try to tokenize based on grammar patterns
		{
			#check stoplist
			if (exists $stoplist{$word}) {$word = $word;} 
			
			#adverbs
			elsif ($word =~ /^($advlist)$/){$word = $1;}
			
			
			#ⲧⲏⲣ=
			elsif ($word =~ /^(ⲧⲏⲣ)($ppero)$/){$word = $1 ."|" . $2;}
			
			#prepositions
			elsif ($word =~ /^($pprep)($ppero)$/){$word = $1 . "|" . $2;}
			elsif ($word =~ /^($nprep)($namelist)$/){$word = $1 . "|" . $2;}
			elsif ($word =~ /^($nprep)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($nprep)($art|$ppos)ⲉ($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}

			#tripartite clause
			#pronominal
			elsif ($word =~ /^($triprobase)($ppers)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($triprobase)($ppers)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^($triprobase)($ppers)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			#proper name subject
			elsif ($word =~ /^($trinbase)($namelist)($verblist)$/)  {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($trinbase)($namelist)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^($trinbase)($namelist)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 ;}
			#prenominal
			elsif ($word =~ /^($trinbase)($art|$ppos)($nounlist)($verblist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^($trinbase)($art|$ppos)($nounlist)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 ."|" . $5;}
			elsif ($word =~ /^($trinbase)($art|$ppos)($nounlist)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 ."|" . $5;}

			#simple NP
			elsif ($word =~ /^($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 ;}
			#relative generic NP p-et-o, ... , TODO: problem with theta
			elsif ($word =~ /^(ⲡ)(ⲉⲧ)($verblist|$vstatlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}

			#'to' infinitive: e-eire
			elsif ($word =~ /^(ⲉ)($verblist)$/){$word = $1 . "|" . $2;}
			elsif ($word =~ /^(ⲉ)($verblist)($nounlist)$/){$word = $1 . "|" . $2."|".$3;}

			#Verboids
			#pronominal subject - peja=f, nanou=s
			elsif ($word =~ /^($vbdlist)($ppero)$/) {$word = $1 . "|" . $2 ;}
			#nominal subject - peje-prwme
			#elsif ($word =~ /^($vbdlist)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			
			#bipartite clause
			#pronominal + future
			elsif ($word =~ /^($bibase)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2;}
			elsif ($word =~ /^($bibase)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($bibase)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3. "|".$4;}
			#nominal + future (+object)
			elsif ($word =~ /^($art|$ppos)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($art|$ppos)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^($art|$ppos)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 . "|".$5;}
			#indefinite + future
			elsif ($word =~ /^($exist)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($exist)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^($exist)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4."|".$5;}
			
			#converted bipartite clause
			#pronominal + future
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4."|".$5;}
			#nominal
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($art|$ppos)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($art|$ppos)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($art|$ppos)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5."|".$6;}
			#indefinite
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}

			#converted tripartite clause
			#pronominal
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			###
			#prenominal
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)$/)   {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 ."|" . $5;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}

			
		
			#nothing found
			#else {}

		
		}

		@toks = split(/\|/, $word);
		
		#print word and tokens
		$dipl =~ s/\|//g;
		$dipl =~ s/<[^>]+>//g; #remove XML tags in dipl form

		
		#isolate XML tags
		$tags = "";
		if ($dipl =~ /(.*)(<[^>]+>)(.*)/)
		{
		$dipl = $1.$3;
		$tags = $2;
		$tags =~ s/></>\t</g;
		}
		
		if ($noword==0)
		{
				if ($pipes ==0) {print $word;}else{print $dipl;}	
		}
		if ($tags ne "") 
		{
		print $tags;
		}
		
		if ($tagbuffer ne "") {$tagoutput=$tagbuffer;$tagbuffer="";}
		foreach $tok (@toks)
		{
			#restore protected spaces in XML elements
			$tok =~ s/\@/ /g; 
			if ($tok =~ /(.*)(<.*>)$/) #final tag, belongs to next token
			{
			$tok = $1;
			$tagbuffer= $2;
			}
			else{
			$tok =~ s/<(.*)>(.+)/%<$1>$2/g;
			}
			@subtoks = split(/%/, $tok);
			foreach $subtok (@subtoks)
			{
				if ($noword==0) {print "\t";}
				$subtok =~ s/(<.*>)(.*)/$2\t$1/g;
				print $subtok;
				if ($tagoutput ne "") {print "\t$tagoutput";$tagoutput="";}
				print "\n";
			}
		}
		
	}


}
