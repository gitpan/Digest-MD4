BEGIN {
	if ($ENV{PERL_CORE}) {
        	chdir 't' if -d 't';
        	@INC = '../lib';
        }
}

print "1..5\n";

use strict;
use Digest::MD4 qw(md4 md4_hex md4_base64);

# To update the EBCDIC section even on a Latin 1 platform,
# run this script with $ENV{EBCDIC_MD4SUM} set to a true value.
# (You'll need to have Perl 5.7.3 or later, to have the Encode installed.)
# (And remember that under the Perl core distribution you should
#  also have the $ENV{PERL_CORE} set to a true value.)
# Similarly, to update MacOS section, run with $ENV{MAC_MD4SUM} set.

my $EXPECT;
if (ord "A" == 193) { # EBCDIC
    $EXPECT = <<EOT;
927629a56819739b827db0cca2222e5e  Changes
0dbd12438619d37abe39c41e4584ebe0  README
766deececcdb7a0c516e72d561f184a2  MD4.pm
e23c115e7141c4349fc045776106e995  MD4.xs
f178f04d0d8305c328a3de281313d642  rfc1320.txt
EOT
} elsif ("\n" eq "\015") { # MacOS
    $EXPECT = <<EOT;
fc44ec0a456c88d0d6c6db75fe94f151  Changes
a64a8e41ca2fe973ffbb46aa66d70bd2  README
6cceb00fad9a0000ec16449d8ab81149  MD4.pm
565df58ac3c127ac917bd19db106a920  MD4.xs
2089ab664427233cd7043d91f0021ff8  rfc1320.txt
EOT
} else {
    # This is the output of: 'md4sum Changes README MD4.pm MD4.xs rfc1320.txt'
    $EXPECT = <<EOT;
fc44ec0a456c88d0d6c6db75fe94f151  Changes
a64a8e41ca2fe973ffbb46aa66d70bd2  README
6cceb00fad9a0000ec16449d8ab81149  MD4.pm
565df58ac3c127ac917bd19db106a920  MD4.xs
2089ab664427233cd7043d91f0021ff8  rfc1320.txt
EOT
}

if (!(-f "README") && -f "../README") {
   chdir("..") or die "Can't chdir: $!";
}

my $testno = 0;

my $B64 = 1;
eval { require MIME::Base64; };
if ($@) {
    print "# $@: Will not test base64 methods\n";
    $B64 = 0;
}

for (split /^/, $EXPECT) {
     my($md4hex, $file) = split ' ';
     my $base = $file;
#     print "# $base\n";
     if ($ENV{PERL_CORE}) {
         if ($file eq 'rfc1321.txt') { # Don't have it in core.
	     print "ok ", ++$testno, " # Skip: PERL_CORE\n";
	     next;
	 }
         use File::Spec;
	 my @path = qw(ext Digest MD4);
	 my $path = File::Spec->updir;
	 while (@path) {
	   $path = File::Spec->catdir($path, shift @path);
	 }
	 $file = File::Spec->catfile($path, $file);
     }
#     print "# file = $file\n";
     unless (-f $file) {
	warn "No such file: $file\n";
	next;
     }
     if ($ENV{EBCDIC_MD4SUM}) {
         require Encode;
	 my $data = cat_file($file);	
	 Encode::from_to($data, 'latin1', 'cp1047');
	 print md4_hex($data), "  $base\n";
	 next;
     }
     if ($ENV{MAC_MD4SUM}) {
         require Encode;
	 my $data = cat_file($file);	
	 Encode::from_to($data, 'latin1', 'MacRoman');
	 print md4_hex($data), "  $base\n";
	 next;
     }
     my $md4bin = pack("H*", $md4hex);
     my $md4b64;
     if ($B64) {
	 $md4b64 = MIME::Base64::encode($md4bin, "");
	 chop($md4b64); chop($md4b64);   # remove padding
     }
     my $failed;
     my $got;

     if (digest_file($file, 'digest') ne $md4bin) {
	 print "$file: Bad digest\n";
	 $failed++;
     }

     if (($got = digest_file($file, 'hexdigest')) ne $md4hex) {
	 print "$file: Bad hexdigest: got $got expected $md4hex\n";
	 $failed++;
     }

     if ($B64 && digest_file($file, 'b64digest') ne $md4b64) {
	 print "$file: Bad b64digest\n";
	 $failed++;
     }

     my $data = cat_file($file);
     if (md4($data) ne $md4bin) {
	 print "$file: md4() failed\n";
	 $failed++;
     }
     if (md4_hex($data) ne $md4hex) {
	 print "$file: md4_hex() failed\n";
	 $failed++;
     }
     if ($B64 && md4_base64($data) ne $md4b64) {
	 print "$file: md4_base64() failed\n";
	 $failed++;
     }

     if (Digest::MD4->new->add($data)->digest ne $md4bin) {
	 print "$file: MD4->new->add(...)->digest failed\n";
	 $failed++;
     }
     if (Digest::MD4->new->add($data)->hexdigest ne $md4hex) {
	 print "$file: MD4->new->add(...)->hexdigest failed\n";
	 $failed++;
     }
     if ($B64 && Digest::MD4->new->add($data)->b64digest ne $md4b64) {
	 print "$file: MD4->new->add(...)->b64digest failed\n";
	 $failed++;
     }

     my @data = split //, $data;
     if (md4(@data) ne $md4bin) {
	 print "$file: md4(\@data) failed\n";
	 $failed++;
     }
     if (Digest::MD4->new->add(@data)->digest ne $md4bin) {
	 print "$file: MD4->new->add(\@data)->digest failed\n";
	 $failed++;
     }
     my $md4 = Digest::MD4->new;
     for (@data) {
	 $md4->add($_);
     }
     if ($md4->digest ne $md4bin) {
	 print "$file: $md4->add()-loop failed\n";
	 $failed++;
     }

     print "not " if $failed;
     print "ok ", ++$testno, "\n";
}


sub digest_file
{
    my($file, $method) = @_;
    $method ||= "digest";
    #print "$file $method\n";

    open(FILE, $file) or die "Can't open $file: $!";
    my $digest = Digest::MD4->new->addfile(*FILE)->$method();
    close(FILE);

    $digest;
}

sub cat_file
{
    my($file) = @_;
    local $/;  # slurp
    open(FILE, $file) or die "Can't open $file: $!";

    # For PerlIO in case of UTF-8 locales.
    eval 'binmode(FILE, ":bytes")' if $] >= 5.008;

    my $tmp = <FILE>;
    close(FILE);
    $tmp;
}

