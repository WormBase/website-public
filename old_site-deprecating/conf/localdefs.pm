# where acedb is running
$HOST = 'localhost';
#$HOST = 'vab.wormbase.org';

# cache
#$CACHEROOT = '/usr/local/wormbase/cache';
#$CACHEEXPIRES = '1 day';

# port on which acedb is listening
$PORT  = 2005;

# acedb username and password
$USERNAME = '';
$PASSWORD = '';

# the location of the mysql databases
$MYSQL_HOST = 'localhost';
$MYSQL_USER = 'nobody';
$MYSQL_PASS = '';

# turn on extra debugging code
$DEBUG = 0;

# we are the master (definitive) database
$MASTER      = 0;       # 0 = false, 1 = true

# we are a mirror site
$MIRROR      = 'Development';       # a flag and the name of the site

# we are a development site
$DEVELOPMENT = 1;       # 0 = false, 1 = true

# where do we go for BLAST/BLAT?
$WORMBASE2BLAST = 'http://dev.wormbase.org';

# where does the BLAST page go for its xrefs?
$BLAST2WORMBASE = 'http://dev.wormbase.org';

# AQL queries
$WORMBASE2AQL = 'http://dev.wormbase.org';
$AQL2WORMBASE = 'http://dev.wormbase.org';

# WQL queries
$WORMBASE2WQL = 'http://dev.wormbase.org';
$WQL2WORMBASE = 'http://dev.wormbase.org';

# WormMart
#$WORMMART_URL = 'http://dev.wormbase.org/Multi/martview';
$WORMMART_URL = 'http://dev.wormbase.org/biomart/martview';

# Google Maps API related
$GMAP_API_KEY = 'ABQIAAAAGB-Wqdj00NegDlW0aNTPQRT0kmb1hGpfTs2MOyy1b828YonADhTYLcGFlWLAmh79UVtQaartAy14gg';
$GEO_MAP_DB   = 'geo_map';
$GEO_MAP_USER = 'geo_map';
$GEO_MAP_PASS = 'geo_map';

1;
