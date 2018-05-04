#!/usr/bin/env perl

# Rest tests for movies

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package movies;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    use LWP::Simple qw(get);
    use JSON        qw(from_json);
    use Net::FTP;

    my $configuration;

    sub config {
        $configuration = $_[0];
    }

    sub test_movies {
        my $ftp = Net::FTP->new('caltech.wormbase.org')
            or die "Cannot connect to some.host.name: $@";
        $ftp->login('anonymous')
            or die "Cannot login ", $ftp->message;
        $ftp->cwd('/pub/OICR/Movies/WBPaper00004811')
            or die "Cannot change working directory ", $ftp->message;
        my $size = $ftp->size('001.A06.15c.term.mp4')
            or die "size failed ", $ftp->message;
        $ftp->quit;

        is  (($size>0), 1, 'movie found at url');
    }

}

1;
