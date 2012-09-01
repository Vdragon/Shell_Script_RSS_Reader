#!/usr/bin/perl
use strict;

use LWP::Simple;
use XML::Feed;
no warnings;
my @subs = ();

chdir "~/.feed/";

open SUBSCRIPTION , "subscription" or die "file subscription open error: $!";
while (<SUBSCRIPTION>) {
    chomp;
    push @subs, $_;
}

while (<*>) {
  chomp;
  if (-d $_) {
    chdir $_;
    system ("rm *");
    chdir "..";
    rmdir $_ or die "QQ:$_ $!";
  }
}

my $z = 1;
for my $sub (@subs) {
    my $feed = XML::Feed->parse(URI->new($sub))
        or die XML::Feed->errstr;
     
    mkdir $z or die "can't write directory [$z]: $!";
    chdir $z or die "can't cd to directory [$z]: $!";

    for my $entry ($feed->entries) {
        open W, sprintf(">>titles") , or die "can't write file [$z/titles] :$!";
        print W $entry->title, "\n";
        close W;
    }

    my $count = 1;
    for my $entry ($feed->entries) {
        open W, sprintf(">%s", $count) , or die "can't write file [$z/$count] :$!";
        print W "---\n";
        print W "Title: ", $entry->title, "\n";
        print W "Link: \n", $entry->link, "\n";
        print W "---\n";
        print W $entry->content->body, "\n";
        close W;
        $count++;
    }
    chdir "..";
    $z++;
}