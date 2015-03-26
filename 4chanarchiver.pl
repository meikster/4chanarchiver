#!/usr/bin/perl -w

use	strict;
use	LWP::UserAgent;
use	HTML::TokeParser;

my	$archive_base = "/tmp/4chan";

if (scalar @ARGV != 1)
{
    printf("I need a thread URL !\n");
    exit(-1);
}
else
{
    my	$url = $ARGV[0];
    my	$ua = LWP::UserAgent->new();
    my	$resp = $ua->get($url);
    my	$cont = $resp->decoded_content;

    $url =~ /4chan\.org\/b\/thread\/\d+\/(.*)/;
    my	$title = $1;
    my	$path = sprintf("%s/%s", $archive_base, $title);
    mkdir($path);

    while ($cont =~ /File\: \<a href=\"(\/\/i\.4cdn\.org\/b\/\d+.(jpg|png|gif|webm))\"/g)
    {
	my	$image_name;
	my	$image_url = sprintf("https:%s", $1);
	$image_url =~ /\/(\d+.(jpg|png|gif|webm))$/;
	$image_name = $1;
	printf(">> SAVING %s %s\n", $image_url, $image_name);
	my	$image_resp = $ua->get($image_url);
	my	$image_cont = $image_resp->decoded_content;
	my	$saved_image_path = sprintf("%s/%s", $path, $image_name);
	printf(">>> Saving image in %s\n", $saved_image_path);
	open(FD, "+>$saved_image_path");
	print FD $image_cont;
	close(FD);
    }
}

