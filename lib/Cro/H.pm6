use v6.c;
use Cro::Transform;
unit role Cro::H:ver<0.0.1> does Cro::Transform;
has $!top = Supplier::Preserving.new;
has $!bottom = Supplier::Preserving.new;
has Bool $!top-used = False;
has Bool $!bottom-used = False;

method produces() { ... }
method consumes() { ... }
method transformer(Supply:D $pipeline) returns Supply {
  if !$!top-used {
    $!top-used = True;
    return Supply.merge($!bottom.Supply, supply {
      whenever $pipeline {
        $!top.emit: $_;
        emit $_;
      }
    });
  }
  elsif !$!bottom-used {
    $!bottom-used = True;
    return Supply.merge($!top.Supply, supply {
      whenever $pipeline {
        $!bottom.emit: $_;
        emit $_;
      }
    });
  }
  else {
    die "All connections to {self.^name()} used already";
  }
}




=begin pod

=head1 NAME

Cro::H - Interconnect two pipelines

=head1 SYNOPSIS

=begin code
#These classes are stubbed
use Cro::H;
my $h-pipe = Cro::H.new;

my $pipeline1 = Cro.compose(Cro::Source, $h-pipe, Cro::Sink)
my $pipeline2 = Cro.compose(Cro::Source, $h-pipe, Cro::Sink)

($pipeline1, $pipeline2)>>.start;
#Both sinks will receive all the values from both sources
=end code

=head1 DESCRIPTION

Cro::H is a way to interconnect two pipelines
without needing to terminate either pipeline.

Split off a second pipelines by creating a source
that outputs nothing as the start of the second pipeline.

Merge two pipelines by creating a sink that ignores
all incoming values as the end of the second pipeline.


=begin code
Sample pipeline:
 ---------      _______________      -------
| Source1 | -> |_____     _____| -> | Sink1 |
 ---------           |   |           -------
                     | H |
 ---------      _____|   |_____      -------
| Source2 | -> |______________ | -> | Sink2 |
 ---------                           -------
=end code

=head1 AUTHOR

Travis Gibson <TGib.Travis@protonmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Travis Gibson

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod