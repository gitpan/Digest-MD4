#!/usr/local/bin/perl
# $Id: mddriver.pl,v 1.2 2000/08/27 23:19:12 mikem Exp $

require 'getopts.pl';
use Digest::MD4;
sub DoTest;

&Getopts('s:x');

$md4 = new Digest::MD4;

if (defined($opt_s))
{
    $md4->add($opt_s);
    $digest = $md4->digest();
    print("MD4(\"$opt_s\") = " . unpack("H*", $digest) . "\n");
}
elsif ($opt_x)
{
    DoTest("", "31d6cfe0d16ae931b73c59d7e0c089c0");
    DoTest("a", "bde52cb31de33e46245e05fbdbd6fb24");
    DoTest("abc", "a448017aaf21d8525fc10ae87aa6729d");
    DoTest("message digest", "d9130a8164549fe818874806e1c7014b");
    DoTest("abcdefghijklmnopqrstuvwxyz", "d79e1c308aa5bbcdeea8ed63df412da9");
    DoTest("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
	   "043f8582f241db351ce627e153e7f0e4");
    DoTest("12345678901234567890123456789012345678901234567890123456789012345678901234567890",
	   "e33b4ddc9c38f2199c3e7b164fcc0536");
}
else
{
    if ($#ARGV >= 0)
    {
	foreach $ARGV (@ARGV)
	{
	    die "Can't open file '$ARGV' ($!)\n" unless open(ARGV, $ARGV);

	    $md4->reset();
	    $md4->addfile(ARGV);
	    $hex = $md4->hexdigest();
	    print "MD4($ARGV) = $hex\n";

	    close(ARGV);
	}
    }
    else
    {
	$md4->reset();
	$md4->addfile(STDIN);
	$hex = $md4->hexdigest();

	print "$hex\n";
    }
}

exit 0;

sub DoTest
{
    my ($str, $expect) = @_;
    my ($digest, $hex);
    my $md4 = new Digest::MD4;

    $md4->add($str);
    $digest = $md4->digest();
    $hex = unpack("H*", $digest);

    print "MD4(\"$str\") =>\nEXPECT: $expect\nRESULT: $hex\n"
}
