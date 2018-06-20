docker run -it -d -v ${PWD}:/website -w=/website -p 5001:5000 wormbase/website-env /bin/bash -c "plackup gbrowse.psgi"
