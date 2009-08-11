#!/bin/bash
export PERL5LIB=../../extlib
cd build
tar xzf gbrowse-stable.tgz
cd gbrowse-stable

perl Makefile.PL NONROOT=1 \ 
                CONF=../../conf \
                LIB=../../extlib \
                HTDOCS=../../root/static \ 
                CGIBIN=../../root/static/cgi \
                BIN=../../bin \
                GBROWSE_ROOT=gbrowse \
                APACHE=none \
                DO_XS=0

make
make install
cp GGB.def ../.
cd ..
rm -rf gbrowse-stable

