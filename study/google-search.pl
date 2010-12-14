#!/usr/bin/perl
# google.pl - command line tool to search google
#
# Since I wrote goosh.org I get asked all the time if it could be used on the command line.
# Goosh.org is written in Javascript, so the answer is no. But google search in the shell
# is really simple, so I wrote this as an example. Nothing fancy, just a starting point.
#
# 2009 by Stefan Grothkopp, this code is public domain use it as you wish!

use LWP::Simple;
use Term::ANSIColor;

# change this to false for b/w output
$use_color = true;
#result size: large=8, small=4
$result_size = "large";

# unescape unicode characters in" content"
sub unescape {
        my($str) = splice(@_);
        $str =~ s/\\u(.{4})/chr(hex($1))/eg;
        return $str;
}

# number of command line args
$numArgs = $#ARGV + 1;

if($numArgs ==0){
        # print usage info if no argument is given
        print "Usage:\n";
        print "$0 <searchterm>\n";
}
else {
        # use first argument as query string
        $q = $ARGV[0];
        # url encode query string
        $q =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;

        # get json encoded search result from google ajax api
        my $content = get("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&start=0&rsz=$result_size&q=$q"); #Get web page in content
                die "get failed" if (!defined $content);

        # ugly result parsing (did not want to depend on a parser lib for this quick hack)
        while($content =~ s/"unescapedUrl":"([^"]*)".*?"titleNoFormatting":"([^"]*)".*?"content":"([^"]*)"//){

                # those three data items are extrated, there are more
                $title = unescape($2);
                $desc  = unescape($3);
                $url   = unescape($1);

                # print result
                if($use_color){
                 print colored ['blue'], "$title\n";
                 print "$desc\n";
                 print colored ['green'], "$url\n\n";
                 print color 'reset';
                }
                else{
                 print "$title\n$desc\n$url\n\n";
                }
        }
}