package Graph::Similarity;

use warnings;
use strict;

use version; 
our $VERSION = qv('0.0.3');

use Moose;

use Graph::Similarity::SimRank;
use Graph::Similarity::SimilarityFlooding;
use Graph::Similarity::CoupledNodeEdgeScoring;

has 'graph' => (is => 'rw', isa => 'ArrayRef[Graph]', required => 1);

__PACKAGE__->meta->make_immutable;
no Moose;

#===========================================================================
# Select which algorithm is used. And make sure the proper graph is used.
# arg1: algorithm - Please check perldoc for more details
#===========================================================================
sub use {
    my ($self, $algo) = @_; 
    my $g = $self->graph;

    my $method;
    if ($algo eq "SimRank") {

        die "This algorithm can only apply to single graph\n" if (scalar @$g != 1); 
        die "The graph needs to be directed graph\n" unless ($$g[0]->is_directed);
        $method = new Graph::Similarity::SimRank(graph => $$g[0]);

    }elsif ($algo eq "SimilarityFlooding"){

        die "This algorithm can only applied to two graph\n" if (scalar @$g != 2); 
        die "The graph needs to be multiedged\n" unless ($$g[0]->is_multiedged && $$g[1]->is_multiedged);
        die "The graph needs to be directed graph\n" unless ($$g[0]->is_directed && $$g[1]->is_directed);
        $method = new Graph::Similarity::SimilarityFlooding(graph => $g);
    }

    elsif ($algo eq "CoupledNodeEdgeScoring"){

        die "This algorithm can applied to only two graphs\n" if (scalar @$g != 2); 
        die "The graph needs to be directed graph\n" unless ($$g[0]->is_directed && $$g[1]->is_directed);
        $method = new Graph::Similarity::CoupledNodeEdgeScoring(graph => $g);
    }
    else {
        die "$algo is not supported\n";
    }

    return $method;
}




1; # Magic true value required at end of module
__END__

=head1 NAME

Graph::Similarity - Calculate similarity of the vertices in graph(s) 

=head1 VERSION

This document describes Graph::Similarity version 0.0.3


=head1 SYNOPSIS

    use Graph;
    use Graph::Similarity;

    my $g = Graph->new; # Use Graph module
    $g->add_vertices("a","b","c","d","e");
    $g->add_edges(['a', 'b'], ['b', 'c'], ['a', 'd'], ['d', 'e']);

    # Calculate by SimRank
    my $s = new Graph::Similarity(graph => [$g]);
    my $method = $s->use('SimRank');
    $method->setConstnact(0.8);
    $method->calculate();
    $method->showAllSimilarities;
    $method->getSimilarity("c","e"); 

    #===============================================
    # Or by Coupled Node Edge Scoring
    my $g1 = Graph->new;
    $g1->add_vertices("A","B","C");
    $g1->add_edges(['A', 'B'], ['B','C']);

    my $g2 = Graph->new;
    $g2->add_vertices("a","b","c","d","e");
    $g2->add_edges(['a', 'b'], ['b', 'c'], ['a', 'd'], ['d', 'e']);
    my $method = $s->use('CoupledNodeEdgeScoring');
    $method->calculate();
    $method->showAllSimilarities;

    #===============================================
    # Or by Similarity Flooding 
    my $g1 = Graph->new(multiedged => 1);
    $g1->add_vertices("I","coffee","apple","swim");
    $g1->add_edge_by_id("I", "coffee", "drink");
    $g1->add_edge_by_id("I", "swim", "can't");
    $g1->add_edge_by_id("I", "apple", "eat");

    my $g2 = Graph->new(multiedged => 1);
    $g2->add_vertices("she","cake","apple juice","swim");
    $g2->add_edge_by_id("she", "apple juice", "drink");
    $g2->add_edge_by_id("she", "swim", "can");
    $g2->add_edge_by_id("she", "cake", "eat");
    
    my $s = new Graph::Similarity(graph => [$g1,$g2]);
    my $method = $s->use('SimimilarityFlooding');
    $method->calculate();
    $method->showAllSimilarities;
  
=head1 DESCRIPTION

Graph is composed of vertices and edges (This is often also referred as nodes/edge in network).
Graph::Similarity calculate the similarity of the vertices(nodes) by the following algorithms,
 
    *) SimRank - Jeh et al "SimRank: A Measure of Structural-Context Similarity"
    *) Coupled Node Edge Socring  - Laura Zager "Graph Similarity and Matching" 
    *) Similarity Flooding - Melnik et al. "Similarity Flooding: A Versatile Graph Matching Algorithm and its Application to Schema Matching"

The algorithm is implemented by referring to the above papers. Each module in implementation layer(Graph::Similarity::<algorithm>) explains briefly about the algorithm.
However, if you would like to know the details, please read the original papers.


=head1 USAGE 

=head2 $s = new Graph::Similarity(graph => [$g1, $g2])

Constructor. Create instance with L<Graph> argument. SimRank is one Graph, the others need two Graphs for the algorithm.

=head2 $s->use('algorithm')  

You can choose one of the algorithm. This use method verifies Graph feature to see whether it fits to the requirement. 
If there is no required feature, it dies out.
For example, when you specify two Graph in SimRank, it dies because SimRank needs to be calculated from one graph.

=head2 $s->calculate()

Using the method that is specified by use(), calculate the similarity. This returns a hash reference which is the results of calculation.

=head2 setNumOfIteration($num)

Set the number of Iteration. The argument should be Integer.

=head2 $s->showAllSimilarities()

The results to STDOUT.     

=head2 $s->getSimilairity("X", "Y")

The vertex(node) has the name when it's created by Graph Module. Say, if you want to know the similarity between vertex "X" and "Y", use this method.


=head1 DIAGNOSTICS

You may see the following error messages:

=over

=item C<This algorithm can only apply to single graph>

The algorithm needs to have single graph as argument.

=item C<The graph needs to be directed graph>

Undirected graph can't be applied to this algorithm.

=item C<The graph needs to be multiedged>

The algorithm needs to has multiedged graph with Graph->new(multiedged => 1)

=back

=head1 CONFIGURATION AND ENVIRONMENT

Graph::Similarity requires no configuration files or environment variables.


=head1 DEPENDENCIES

None.


=head1 AUTHOR

Shohei Kameda  C<< <shoheik@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, Shohei Kameda C<< <shoheik@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
