/*
**	Perl Extension for the
**
**	RSA Data Security Inc. MD4 Message-Digest Algorithm
**
**	This module originally by Neil Winton (N.Winton@axion.bt.co.uk)
**      Adapted by Mike McCauley mikem@open.com.au
**	$Id: MD4.xs,v 1.3 2001/07/30 23:39:57 mikem Exp $	
**
**	This extension may be distributed under the same terms
**	as Perl. The MD4 code is covered by separate copyright and
**	licence, but this does not prohibit distribution under the
**	GNU or Artistic licences. See the file md4c.c or MD4.pm
**	for more details.
*/

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "global.h"
#include "md4.h"

typedef MD4_CTX	*Digest__MD4;

#ifdef __cplusplus
}
#endif


MODULE = Digest::MD4		PACKAGE = Digest::MD4

PROTOTYPES: DISABLE

Digest::MD4
new(packname = "Digest::MD4")
	char *		packname
    CODE:
	{
	    RETVAL = (MD4_CTX *)safemalloc(sizeof(MD4_CTX));
	    MD4Init(RETVAL);
	}
    OUTPUT:
	RETVAL

void
DESTROY(context)
	Digest::MD4	context
    CODE:
	{
	    safefree((char *)context);
	}


Digest::MD4
reset(context)
	Digest::MD4	context
    CODE:
	{
	    MD4Init(context);
	    RETVAL = context;
	}

Digest::MD4
add(context, ...)
	Digest::MD4	context
    CODE:
	{
	    SV *svdata;
	    STRLEN len;
	    unsigned char *data;
	    int i;

	    for (i = 1; i < items; i++)
	    {
		data = (unsigned char *)(SvPV(ST(i), len));
		MD4Update(context, data, len);
	    }
	    RETVAL = context;
	}

SV *
digest(context)
	Digest::MD4	context
    CODE:
	{
	    unsigned char digeststr[16];

	    MD4Final(digeststr, context);
	    ST(0) = sv_2mortal(newSVpv((char *)digeststr, 16));
	}
