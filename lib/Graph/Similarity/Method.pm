package Graph::Similarity::Method;

use Moose::Role;
use Data::Dumper;

requires qw/calculate/;

has 'num_of_iteration'  => (is => 'rw', isa => 'Int', default => 100);
has 'sim' => (is => 'rw', isa => 'HashRef');

no Moose::Role;

# Set number of the iteration. 
sub setNumOfIteration {
    my ($self, $value) = @_;
    $self->num_of_iteration($value);
}

sub showAllSimilarities {
    my $self = shift;
    my $sim = $self->sim;
    for my $i (keys %$sim) {
        for my $j (keys %{$$sim{$i}}) {
            print "$i - $j : $$sim{$i}{$j}\n";
        }
    }
    #print Dumper $sim;
}

# This is used by the algoritm module 
# to set the similarity hash
sub _setSimilarity {
    my ($self, $ref) = @_; 
    $self->sim($ref);
}

sub getSimilarity {
    my ($self, $a, $b) = @_;
    my $sim = $self->sim;
    for my $i (keys %$sim) {
        if ($i eq $a ) {
            for my $j (keys %{$$sim{$i}}) {
                if ($j eq $b) {
                    return $$sim{$i}{$j};
                }
            }
        }
        elsif ($i eq $b) {
            for my $j (keys %{$$sim{$i}}) {
                if ($j eq $a) {
                    return $$sim{$i}{$j};
                }
            }
        }
    }
    return;
}

1;
