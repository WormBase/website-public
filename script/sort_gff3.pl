#!/usr/bin/perl

my $serialized_ids = {};
my $parent_rels = {};
my $feature_stash = {};

my $faux_feature_id = 0;

my $fasta_annex = undef;

while(<>) {
    chomp;
    my $line = $_;

    if ($fasta_annex) {
        # We are in the FASTA section. Just output the sequences as they float by...
        print "$line\n";
    } elsif ($line =~ /^#/) {
        $fasta_annex = 1 if ($line =~ /^##FASTA/); # When the FASTA section starts, mark this, because every following line can be just printed.
        print "$line\n";
    } elsif ($line =~ /^([a-zA-Z0-9.:^*$@!+_?-|]|%[0-9A-F]{2})+\s/) {
        my @ids = $line =~ /ID=([^;]+)/g;
        my @parents = $line =~ /Parent=([^;]+)/g;

        unless (@parents) {
            # No parents. Just print the feature and record its ID.
            $serialized_ids->{$ids[0]} = 1 if (@ids && scalar(@ids) == 1);
            print "$line\n";
        } else {
            @parents = split(/,/, $parents[0]);
            my $parents_serialized = 0;
            foreach my $parent (@parents) {
                $parents_serialized++ if $serialized_ids->{$parent};
            }
            if ($parents_serialized == scalar(@parents)) {
                # Parents already have been serialized, so just write out the feature.
                $serialized_ids->{$ids[0]} = 1 if (@ids && scalar(@ids) == 1);
                print "$line\n";
            } else {
                if (@ids && scalar(@ids) == 1) {
                    # Stash the current input line for future serialization.
                    $parent_rels->{$ids[0]} = \@parents;
                    $feature_stash->{$ids[0]} = $line;
                } else {
                    # No ID that we could keep track of. Create a temporary ID for the feature.
                    $parent_rels->{"% $faux_feature_id"} = \@parents;
                    $feature_stash->{"% $faux_feature_id"} = $line;
                    $faux_feature_id++;
                }
            }
        }

        my $feature_serialized;
        do {
            $feature_serialized = undef;
            my @serialized_features = ();
            while(my ($feature_id, $value) = each %$feature_stash) {
                next unless $value;
                next if $serialized_ids->{$feature_id};
                my $parents_serialized = 0;
                my $parents = $parent_rels->{$feature_id};
                foreach my $parent (@$parents) {
                    $parents_serialized++ if $serialized_ids->{$parent};
                }
                if ($parents_serialized == scalar(@$parents)) {
                    # Parents have been serialized. Get stashed feature out too.
                    print $feature_stash->{$feature_id} . "\n";
                    $serialized_ids->{$feature_id} = 1;
                    push(@serialized_features, $feature_id);
                    $feature_serialized = 1;
                }
            }
            foreach my $feature_id (@serialized_features) {
                delete $feature_stash->{$feature_id};
            }
        } while($feature_serialized);
    } else {
        # Some other content. Just print it.
        print "$line\n";
    }
}

# Stats for error checking:
#print STDERR "Serialized features with IDs: " . keys(%$serialized_ids) . "\n";
#print STDERR "Postponed serialization: " . keys(%$parent_rels) . "\n";

