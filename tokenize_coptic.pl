#!/usr/bin/perl -w

# tokenize_coptic.pl Version 1.1.1

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

Usage:  tokenize_coptic_openXML.pl [options] <FILE>

Options and argument:

-h              print this [h]elp message and quit
-p              output [p]ipe separated word forms instead of unanalyzed words in SGML elements
-n              [n]o output of word forms in SGML elements before the set of tokens extracted from each word

<FILE>    A text file encoded in UTF-8 without BOM, one word per line


Examples:

Tokenize a Coptic plain text file in UTF-8 encoding (without BOM):
  tokenize_coptic.pl in_Coptic_utf8.txt > out_Coptic_tokenized.txt

Copyright 2013-2014, Amir Zeldes

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
$pprep = "ⲁϫⲛⲧ|ⲉϩⲣⲁ|ⲉϩⲣⲁⲓⲉϫⲱ|ⲉϫⲛⲧⲉ|ⲉϫⲱ|ⲉⲣⲁⲧ|ⲉⲣⲁⲧⲟⲩ|ⲉⲣⲟ|ⲉⲣⲱ|ⲉⲧⲃⲏⲏⲧ|ⲉⲧⲟⲟⲧ|ϩⲁⲉⲓⲁⲧ|ϩⲁϩⲧⲏ|ϩⲁⲣⲁⲧ|ϩⲁⲣⲓϩⲁⲣⲟ|ϩⲁⲣⲟ|ϩⲁⲣⲱ|ϩⲁⲧⲟⲟⲧ|ϩⲓϫⲱ|ϩⲓⲣⲱ|ϩⲓⲧⲉ|ϩⲓⲧⲟⲟⲧ|ϩⲓⲧⲟⲩⲱ|ϩⲓⲱ|ϩⲓⲱⲱ|ⲕⲁⲧⲁⲣⲟ|ⲕⲁⲧⲁⲣⲱ|ⲙⲙⲟ|ⲙⲙⲱ|ⲙⲛⲛⲥⲱ|ⲙⲡⲁⲙⲧⲟⲉⲃⲟⲗ|ⲛⲏⲧⲛ|ⲛⲁ|ⲛϩⲏⲧ|ⲛⲙⲙⲏ|ⲛⲙⲙⲁ|ⲛⲥⲁⲃⲗⲗⲁ|ⲛⲥⲱ|ⲛⲧⲟⲟⲧ|ⲟⲩⲃⲏ|ϣⲁⲣⲟ|ϣⲁⲣⲱ|ⲛⲏ|ⲛⲛⲁϩⲣⲁ|ⲟⲩⲧⲱ|ⲛⲛⲁϩⲣⲏ|ϩⲁⲧⲏ|ⲉⲧⲃⲏⲏ|ⲛⲣⲁⲧ|ⲉⲣⲁ|ⲛⲁϩⲣⲁ|ⲛϩⲏ|ϩⲓⲧⲟⲟ|ⲕⲁⲧⲁ|ⲙⲉⲭⲣⲓ|ⲡⲁⲣⲁ|ⲉⲧⲃⲉ|ⲛⲧⲉ|ⲙⲛⲛⲥⲱ";
$nprep = "ⲉ|ⲛ|ⲙ|ⲉⲧⲃⲉ|ϣⲁ|ⲛⲥⲁ|ⲕⲁⲧⲁ|ⲙⲛ|ϩⲓ|ⲛⲧⲉ|ϩⲁⲧⲛ|ϩⲓⲣⲙ|ϩⲓⲣⲛ|ⲉⲣⲁⲧ";
$indprep = "ⲉⲧⲃⲉ|ϩⲛ";
$ppers = "ⲓ|ⲕ|ϥ|ⲥ|ⲛ|ⲧⲉⲧⲛ|(?<=ⲙⲡ|ϣⲁⲛⲧ)ⲉⲧⲛ|ⲟ?ⲩ|(?<=ⲛ)ⲅ";
$ppero = "ⲓ|ⲕ|ϥ|ⲥ|ⲛ|ⲧⲛ|ⲧⲏⲩⲧⲛ|ⲟ?ⲩ";
$art = "ⲡ|ⲡⲉ(?=(?:[^ⲁⲉⲓⲟⲩⲏⲱ][^ⲁⲉⲓⲟⲩⲏⲱ]|ⲯ|ⲭ|ⲑ|ⲫ|ⲝ|ϩⲟⲟⲩ|ⲟ?ⲩⲟⲉⲓϣ|ⲣⲟⲙⲡⲉ|ⲟ?ⲩϣⲏ|ⲟ?ⲩⲛⲟⲩ))|ⲛ|ⲛⲉ(?=(?:[^ⲁⲉⲓⲟⲩⲏⲱ][^ⲁⲉⲓⲟⲩⲏⲱ]|ⲯ|ⲭ|ⲑ|ⲫ|ⲝ|ϩⲟⲟⲩ|ⲟ?ⲩⲟⲉⲓϣ|ⲣⲟⲙⲡⲉ|ⲟ?ⲩϣⲏ|ⲟ?ⲩⲛⲟⲩ))|ⲧ|ⲧⲉ(?=(?:[^ⲁⲉⲓⲟⲩⲏⲱ][^ⲁⲉⲓⲟⲩⲏⲱ]|ⲯ|ⲭ|ⲑ|ⲫ|ⲝ|ϩⲟⲟⲩ|ⲟ?ⲩⲟⲉⲓϣ|ⲣⲟⲙⲡⲉ|ⲟ?ⲩϣⲏ|ⲟ?ⲩⲛⲟⲩ))|ⲟⲩ|ϩⲉⲛ|ⲡⲉⲓ|ⲧⲉⲓ|ⲛⲉⲓ|ⲕⲉ|ⲙ(?=ⲙ)";
$ppos = "[ⲡⲧⲛ]ⲉ[ⲕϥⲥⲛⲩ]|[ⲡⲧⲛ]ⲉⲧⲛ|[ⲡⲧⲛ]ⲁ";
$triprobase = "ⲁ|ⲙⲡ|ⲙⲡⲉ|ϣⲁ|ⲙⲉ|ⲙⲡⲁⲧ|ϣⲁⲛⲧⲉ?|ⲛⲧⲉⲣⲉ?|ⲛⲛⲉ|ⲛⲧⲉ|ⲛ|ⲧⲣⲉ|ⲧⲁⲣⲉ|ⲙⲁⲣⲉ|ⲙⲡⲣⲧⲣⲉ"; 
$trinbase = "ⲁ|ⲙⲡⲉ|ϣⲁⲣⲉ|ⲙⲉⲣⲉ|ⲙⲡⲁⲧⲉ|ϣⲁⲛⲧⲉ|ⲛⲧⲉⲣⲉ|ⲛⲛⲉ|ⲛⲧⲉⲣⲉ|ⲛⲧⲉ|ⲧⲣⲉ|ⲧⲁⲣⲉ|ⲙⲁⲣⲉ|ⲙⲡⲣⲧⲣⲉ|ⲉⲣϣⲁⲛ";
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

#add negated TM forms of verbs
$tm = $verblist;
$tm =~ s/\|/|ⲧⲙ/g;
$verblist .=  "|$tm";

$nounlist .="%%%";
$verblist .="%%%";
$vstatlist .="%%%";
$advlist .="%%%";
$namelist .="%%%";
}
### END LEXICON ###

# ADD TAG SUPPORT TO LEXICON
#$namelist =~ s/(.)/$1(?:(?:<[^>]+>)+)?/g;

open FILE,"<:encoding(UTF-8)",shift or die "could not find input document";

while (<FILE>) {

    chomp;
    $line = $_;

	#protect up to *4* spaces in XML tags
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3\@$4\@$5/g; 
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3\@$4/g; 
	$line =~ s/(<[^>]+) ([^>]+) ([^>]+>)/$1\@$2\@$3/g; 
	$line =~ s/(<[^>]+) ([^>]+>)/$1\@$2/g; 
	$line =~ s/</ </g; 
	$line =~ s/>/> /g; 
	$line =~ s/\./ ./g; 
	$line =~ s/ +/ /g; 
		
	#$tagbuffer= "";
	#$tagoutput="";
	
	@words = split(/ +/, $line);
	foreach $word (@words)
	
	{
	if ($word =~ /<.+>/)
	{
		$word =~ s/@/ /g;
		print "$word\n"; #XML tag
	}
	elsif ($word eq ""){}
	#elsif ($word =~ /.*\|.*/){
	#manual tokenization found
	#$dipl = $word;
		#$word =~ s/(̈|%|̄|`|̅)//g; 
#	}
	else
	{
		
		$dipl = $word;
		$word =~ s/(̈|%|̄|`|̅)//g; 
		
		#remove supralinear strokes and other decorations for tokenization
		if ($word =~ /\|/) #pipes found, assume explicit tokenization is present
		{
		
		@toks = split(/\|/, $word);
		$dipl =~ s/\|//g;
		}
		else #try to tokenize based on grammar patterns
		{

			#check for theta/phi containing an article
			if($word =~ /^($nprep|$pprep)?(ⲑ|ⲫ)(.+)$/) 
			{
				if (defined($1)){$opt_prep = $1;}else{$opt_prep="";}
				$theta_phi = $2;
				$noun_candidate = $3;
				$noun_candidate =  "ϩ" . $noun_candidate;
				if ($noun_candidate =~ /^($nounlist|$namelist)$/) #experimentally allowing proper nouns with articles
				{
					if ($theta_phi eq "ⲑ") {$theta_phi = "ⲧ";} else {$theta_phi = "ⲡ";}
					$word = $opt_prep . $theta_phi . $noun_candidate;
				}
			}

			#check for fused t-i
			if($word =~ /^(ϣⲁⲛ)ϯ(.*)/) 
			{
				$candidate = $1;
				$candidate .=  "ⲧ";
				if (defined($2)){$ending = $2;}else{$ending="";}
				if ($candidate =~ /^($triprobase|$pprep)$/) 
				{
					$word = $candidate . "ⲓ". $ending;
				}
			}
			elsif($word =~ /^(.*)ϯ(.+)$/) 
			{
				$candidate = $2;
				$candidate =  "ⲓ" . $candidate;
				if (defined($1)){$start = $1;}else{$start="";}
				if ($candidate =~ /^($nounlist|$namelist)$/) 
				{
					$word = $start . "ⲧ". $candidate;
				}
			}
			
			#check stoplist
			if (exists $stoplist{$word}) {$word = $word;} 

			#adhoc segmentations
			elsif ($word =~ /^ⲛⲁⲩ$/){$word = "ⲛⲁ|ⲩ";} #free standing nau is a PP not a V
			elsif ($word =~ /^ⲛⲁϣ$/){$word = "ⲛ|ⲁϣ";} #"in which (way)"
			elsif ($word =~ /^ⲉⲓⲣⲉ$/){$word = "ⲉⲓⲣⲉ";} #free standing eire is not e|i|re
			elsif ($word =~ /^ⲉϫⲓ$/){$word = "ⲉ|ϫⲓ";} 
			
			#adverbs
			elsif ($word =~ /^($advlist)$/){$word = $1;}
			
			
			#ⲧⲏⲣ=
			elsif ($word =~ /^(ⲧⲏⲣ)($ppero)$/){$word = $1 ."|" . $2;}

			#pure existential
			elsif ($word =~ /^(ⲟⲩⲛ|ⲙⲛ)($nounlist)$/) {$word = $1 . "|" . $2 ;}

			#prepositions
			elsif ($word =~ /^($pprep)($ppero)$/){$word = $1 . "|" . $2;}
			elsif ($word =~ /^($nprep)($namelist)$/){$word = $1 . "|" . $2;}
			elsif ($word =~ /^($nprep)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;} #experimentally allowing proper nouns with articles
			#elsif ($word =~ /^($nprep)($art|$ppos)ⲉ($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}

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

			#elsif ($word =~ /^($art|$ppos)($namelist)$/) {$word = $1 . "|" . $2 ;} #experimental, allow names with article
			#relative generic NP p-et-o, ... 
			elsif ($word =~ /^(ⲉⲧ)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 ;}
			elsif ($word =~ /^($art)(ⲉⲧ)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^($art)(ⲉⲧ)($pprep)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ)(ⲛⲁ)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2. "|" . $3 ;}
			elsif ($word =~ /^($art)(ⲉⲧ)(ⲛⲁ)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3. "|" . $4;}
			#presentative
			elsif ($word =~ /^(ⲉⲓⲥ)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}

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
			elsif ($word =~ /^($bibase)(ⲛⲁ)($verblist)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3. "|".$4 . "|" . $5;}
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
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)($nprep)($art)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4."|".$5;} #PP predicate
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($ppero)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4."|".$5;}
			#nominal
			elsif ($word =~ /^(ⲉⲧ?|ⲛ?ⲉⲣⲉ)($art|$ppos)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛ?ⲉⲣⲉ)($art|$ppos)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛ?ⲉⲣⲉ)($art|$ppos)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5."|".$6;}
			#indefinite
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)($verblist|$vstatlist|$advlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)(ⲛⲁ)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲉⲧ?|ⲛⲉ)($exist)($nounlist)(ⲛⲁ)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}

			#simple NP - moved from before "relative generic NP p-et-o, ... " to account for preterite ne|u-sotm instead of possessive *neu-sotm with nominalized verb
			#if this causes trouble consider splitting ART and PPOS cases of simple NP
			elsif ($word =~ /^($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 ;}

			#nominal separated future verb or independent/to-infinitive
			elsif($word =~ /^($verblist)($ppero)$/){$word = $1 . "|" . $2;}
			elsif($word =~ /^(ⲛⲁ|ⲉ)($verblist)$/){$word = $1 . "|" . $2;}
			elsif($word =~ /^(ⲛⲁ|ⲉ)($verblist)($ppero)$/){$word = $1 . "|" . $2 . "|" . $3;}
			elsif($word =~ /^(ⲉ)(ⲧⲣⲉ)($ppers)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif($word =~ /^(ⲉ)(ⲧⲣⲉ)($ppers)($verblist)($ppero)$/){$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}

			#converted tripartite clause
			#pronominal
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($ppers)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}
			elsif ($word =~ /^($art)(ⲉⲛⲧ)(ⲁ)($ppers)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;} #nominalized
			elsif ($word =~ /^($art)(ⲉⲛⲧ)(ⲁ)($ppers)($verblist)($ppero)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5 . "|" . $6;} #nominalized
			###
			#prenominal
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)$/)   {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)$/)   {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4 ."|" . $5;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)($ppero)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}
			elsif ($word =~ /^(ⲛⲧ|ⲉ)(ⲁ)($art|$ppos)($nounlist)($verblist)($nounlist)$/)  {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|".$6;}
			elsif ($word =~ /^($art)(ⲉⲛⲧ)(ⲁ)($art|$ppos)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5;}  #nominalized
			elsif ($word =~ /^($art)(ⲉⲛⲧ)(ⲁ)($art|$ppos)($nounlist)($verblist)$/) {$word = $1 . "|" . $2 . "|" . $3 . "|" . $4. "|" . $5. "|" . $6;}  #nominalized

			#possessives
			elsif ($word =~ /^((?:ⲟⲩⲛⲧ|ⲙⲛⲧ)[ⲁⲉⲏ]?)($ppers)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3;}
			elsif ($word =~ /^((?:ⲟⲩⲛⲧ|ⲙⲛⲧ)[ⲁⲉⲏ]?)($ppers)$/) {$word = $1 . "|" . $2 ;}
			elsif ($word =~ /^(ⲛⲉ|ⲉ)((?:ⲟⲩⲛⲧ|ⲙⲛⲧ)[ⲁⲉⲏ]?)($ppers)($nounlist)$/) {$word = $1 . "|" . $2 . "|" . $3."|".$4;}
			elsif ($word =~ /^(ⲛⲉ|ⲉ)((?:ⲟⲩⲛⲧ|ⲙⲛⲧ)[ⲁⲉⲏ]?)($ppers)$/) {$word = $1 . "|" . $2 . "|" . $3 ;}

			#optative/conditional, make ppers a portmanteau segment with base
			elsif ($word =~ /^(ⲉ)($ppers)(ⲉ|ϣⲁⲛ)($verblist)$/) {$word = $1 . $2 . $3 . "|" . $4;}
			
			#converter+prep
			elsif ($word =~ /^(ⲉⲧ)($indprep)$/) {$word = $1 . "|" . $2;}

			#negative imperative
			elsif ($word =~ /^(ⲙⲡⲣ)($verblist)$/) {$word = $1 . "|" . $2;}

			#else {			
			#nothing found
			#}
		
		

		#split off negating TMs
		if ($word=~/\|ⲧⲙ(?!ⲁⲉⲓⲏⲩ|ⲁⲓⲏⲩ|ⲁⲓⲟ|ⲁⲓⲟⲕ|ⲙⲟ|ⲟ$)/) {$word =~ s/\|ⲧⲙ/|ⲧⲙ|/;}
		
		
		@toks = split(/\|/, $word);
		
		#print word and tokens
		#$dipl =~ s/\|//g;
}


		if ($noword==0)
		{
			print "<word word=\"";
				if ($pipes ==0) {print $word;}else{print $dipl;}	
				print "\">\n";
		}

		
		foreach $tok (@toks)
		{
			#restore protected spaces in XML elements
			$tok =~ s/\@/ /g; 
			if ($tok =~ /(.*)(<.*>)$/) #final tag, belongs to next token
			{
			$tok = $1;
			#$tagbuffer= $2;
			}
			else{
			$tok =~ s/<(.*)>(.+)/%<$1>$2/g;
			}
			@subtoks = split(/%/, $tok);
			foreach $subtok (@subtoks)
			{
				$subtok =~ s/(<.*>)(.*)/$2\t$1/g;
				print $subtok;
				print "\n";
			}
		}
			print "</word>\n";
		
	
	}
}

}
