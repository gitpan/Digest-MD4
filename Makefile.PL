# $Id: Makefile.PL,v 1.1 2000/08/27 23:12:24 mikem Exp $
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Digest::MD4',
    'VERSION_FROM' => 'MD4.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'CONFIG'	=> ['byteorder'],	# Used to determine 64-bitness
    'DEFINE'	=> '-DPERL_BYTEORDER=$(BYTEORDER)',
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'OBJECT'	=> q[MD4$(OBJ_EXT) md4c$(OBJ_EXT)],
);
