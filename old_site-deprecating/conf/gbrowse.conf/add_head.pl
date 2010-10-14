while(<*.conf>) {
  next if `grep doAutocomplete $_`;


  my $patch = <<END;

# wormbases-specific mod.  Turn off autocomplete
head = <script>var doAutocomplete;</script>
END
;

  open IN, $_;
  system "cp $_ $_.bak";

  open OUT, ">$_.bak2";

  my $f = $_;
  while (<IN>) {
    print OUT and next unless /\[GENERAL\]/i;
    chomp;
    s/(\[GENERAL\].*)/$1\n$patch\n/i;
    print OUT "$_\n";
  }

  system "cp $f.bak2 $f" or warn $!;

}
