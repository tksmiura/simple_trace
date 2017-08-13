#!/usr/bin/perl

%file_map = {};
@start = ();
@end = ();
@fid = ();
@func = ();
# read map.txt for MAC OS X(CLang)
open(MAP, "<", "map.txt") || die "Can't open map file";
while ($line = <MAP>) {
    #[  0] linker synthesized
    if ($line =~ /^\[([^\]])+\](.*)/) {
        my ($fid) = $1;
        my ($fname) = $2;
        $file_map{$fid} = $fname;
    #0x100000D90	0x00000060	[  1] _func1
    } elsif ($line =~ /^0x([0-9A-Fa-f]+)\s+0x([0-9A-Fa-f]+)\s+\[([^\]])+\](.*)/) {
        my($fn) = $4;
        push(@start, hex($1));
        push(@end, hex($1) + hex($2));
        push(@fid, $3);
        $fn =~ s/^\s*\_//;
        push(@func, $fn);
    }
}
close(MAP);

#open(TRACE, "<", "trace.txt") || die "Can't open trace file";
#TRACE=STDIN;
#open(OUT, ">", "sequence.txt") || die "Can't open sequence file";
#OUT=STDOUT;

if ($ARGV[0]) {
    $dest_file = $ARGV[0];
} else {
    $dest_file = "tarce.png";
}

print STDOUT "\@startuml $dest_file\n";
print STDOUT "hide footbox\n\n";
while ($line = <STDIN>) {
    #offset __cyg_profile_func_enter = 10eac2e60
    if ($line =~ /offset\s+([_a-zA-Z0-9]+)\s*\=\s*([0-9A-Fa-f]+)/) {
        my ($base_func) = $1;
        my ($base_func_addr) = hex($2);
        my ($i);
        for($i = 0; $i < $#func; $i++) {
            if ($func[$i] eq $base_func) {
#                print "debug " . sprintf("%x %x\n", $base_func_addr, $start[$i]);
                $offset = $base_func_addr - $start[$i];
                last;
            }
        }
#        print sprintf("base $base_func %x\n", $offset);
    } elsif ($line =~ /in\s+([0-9A-Fa-f]+)\s+\-\>\s+([0-9A-Fa-f]+)/) { 
        my ($cf, $cm) = &func(hex($1) - $offset);
        my ($f, $m) = &func(hex($2) - $offset);
        if ($cm ne "unknown" && $m ne "unknown") {
            print STDOUT "$cm -> $m : $f\n";
            print STDOUT "activate $m\n";
#            print sprintf("in $f(%x)\n", hex($2) - $offset);
        } elsif ($cm ne "unknown" && $m eq "unknown") {
            print STDOUT "$cm ->] : $f\n";
        } elsif ($cm eq "unknown" && $m ne "unknown") {
            print STDOUT "[-> $m : $f\n";
            print STDOUT "activate $m\n";
        } else {
            # no output
        }
    } elsif ($line =~ /out\s+([0-9A-Fa-f]+)\s+\<\-\s+([0-9A-Fa-f]+)/) { 
        my ($cf, $cm) = &func(hex($1) - $offset);
        my ($f, $m) = &func(hex($2) - $offset);
        if ($cm ne $m) {
            if ($cm ne "unknown" && $m ne "unknown") {
                print STDOUT "$cm <-- $m\n";
            } elsif ($cm ne "unknown" && $m eq "unknown") {
                print STDOUT "$cm <--]\n";
            } elsif ($cm eq "unknown" && $m ne "unknown") {
                print STDOUT "[<-- $m\n";
            } else {
                # no output
            }
        }
        print STDOUT "deactivate $m\n";
    }
}

print STDOUT "\n\@enduml\n";
close(STDOUT);
close(STDIN);

exit 0;

sub func {
    my ($addr) = @_;
    my ($i);
    my ($m) = "unknown";
    my ($f) = sprintf("(%x)", $addr);
    for($i = 0; $i < $#func; $i++) {
        #print "$i $addr $start[$i] $end[$i]\n";
        if ($addr >= $start[$i] && $addr < $end[$i]) {
            $f = $func[$i];
            $m = $file_map{$fid[$i]};
            $m =~ s/.trace_o//;
            last;
        }
    }
    return ($f, $m);
}
