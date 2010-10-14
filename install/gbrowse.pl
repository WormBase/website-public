#!/usr/bin/perl

use FindBin '$Bin';
use Cwd;
use strict;

$Bin =~ s/\/install//;

# GBrowse MUST be installed after BioPerl
my $cmd = <<END;
export PERL5LIB=../../extlib
cd build
tar xzf gbrowse-stable.tgz
cd gbrowse-stable

perl Makefile.PL NONROOT=1 CONF=$Bin/conf LIB=$Bin/extlib HTDOCS=$Bin/root/static CGIBIN=$Bin/root/static/cgi BIN=$Bin/bin GBROWSE_ROOT=gbrowse APACHE=none DO_XS=0

make
make install
cp GGB.def ../.
cd ..
rm -rf gbrowse-stable

END

system($cmd);
