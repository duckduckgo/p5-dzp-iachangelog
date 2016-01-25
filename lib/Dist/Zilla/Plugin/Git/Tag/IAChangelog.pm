package Dist::Zilla::Plugin::Git::Tag::IAChangelog;

use Moose;
use namespace::autoclean;
extends 'Dist::Zilla::Plugin::Git::Tag';

use YAML::XS 'Load';
use List::Util qw{ first };

use strict;
use warnings;

has '+changelog' => (default => 'ia_changelog.yml');
# Replace tag_message since it has a default
has '+tag_message' => (default => \&_build_tag_message, lazy => 1);

sub _build_tag_message {
	my $self = shift;

	my $msg = $self->tag . ' was successfully released';

	my $cl_name = $self->changelog;
	my $cl_yaml = first { $_->name eq $cl_name } @{ $self->zilla->files };
	unless ($cl_yaml) {
		$self->log_fatal("WARNING: Unable to find changelog $cl_name");
    }

    my $cl = eval { Load($cl_yaml->content) }
		or $self->log_fatal("Failed to open changelog $cl_name: $@");

    my %changes;
    while(my ($id, $status) = each %$cl){
        push @{$changes{ucfirst $status}}, qq{- [$id](https://duck.co/ia/view/$id)};
    }
    if(%changes){
        $msg .= ' and contains the following changes:';
        for my $status (qw(Added Modified Deleted)){
            if(exists $changes{$status}){
                $msg .= "\n\n**$status**\n\n" . join("\n", sort @{$changes{$status}});
            }
        }
    }

	return $msg;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=encoding utf8

=head1 NAME

Dist::Zilla::Plugin::Git::Tag::IAChangelog - Add DDG changlog to our tag notes 

=head1 SYNOPSIS

This plugin will take our newly minted changelog, convert the YAML to
markdown, and add it as the tag message.

To use:

    [Git::Tag::IAChangelog]

=head1 ATTRIBUTES

=head2 changelog 

Name of the changelog added by IAChangelog.  Keep these in sync.
Defaults to 'ia_changelog.yml'.

=head1 CONTRIBUTING

To browse the repository, submit issues, or bug fixes, please visit
the github repository:

=over 4

L<https://github.com/duckduckgo/p5-dzp-iachangelog>

=back

=head1 AUTHOR

Zach Thompson <zach@duckduckgo.com>

=cut
