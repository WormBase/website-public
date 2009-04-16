#!/bin/sh

cd build
tar xzf bioperl-live.tgz
cd bioperl-live
perl ./Build.PL --install_path lib=../../extlib \
                --install_path arch=../../extlib \
                --install_path libdoc=../../extlib/man \
                --network 0
                
./Build install
cd ../
rm -rf bioperl-live
