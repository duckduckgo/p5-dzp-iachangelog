package Dist::Zilla::Plugin::IAChangelog;
# ABSTRACT: Add instant answer change log file to distro 

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::FileGatherer';

use Dist::Zilla::File::InMemory;
use DDG::Meta::Data;
use JSON::XS 'decode_json';
use IO::All;
use YAML::XS 'Dump';

use strict;

sub gather_files {
	my $s = shift;

	my $yml = 'ia_changelog.yml';

	$s->log(["Creating instant answer change log ($yml)"]);

	my $m = DDG::Meta::Data->by_id;

	my %share_paths;
	while(my ($k, $v) = each %$m){
		my $sp = $v->{perl_module};
		$sp =~ s/^DDG:://;
		$sp =~ s|::|/|g;
		$sp =~ s/([a-z])([A-Z])/$1_$2/g;
		$sp = lc $sp;
		$sp = "share/$sp";
		$share_paths{$sp} = $v->{id};
	}

	my $latest_tag  = (reverse(split /\s+/, `git tag -l [0-9]*`))[0];

	open my $gd, "git diff $latest_tag.. --merges --name-status --diff-filter=AMD --ignore-all-space lib/ share/ |"
		or $s->log_fatal(["Failed to execute `git diff`: $!"]);

	my $ia_types = qr/(?:goodie|spice|fathead|longtail)/i;
	my %changes;
	while(my $x = <$gd>){
		my ($status, $file) = split /\s+/, $x;
		
		my $id;
		if($file =~ m{lib/(DDG/$ia_types/.+)\.pm$}){
			my $m = $1;
            $m =~ s|/|::|g;
            if($m =~ /CheatSheets$/){
				$id = 'cheat_sheets';
            }
			else{
				if(my $ia = DDG::Meta::Data->get_ia(module => $m)){
					unless(@$ia == 1){
						$s->log_fatal(["Multiple IDs in metadata for module $m: @$ia"]);
					}
					$id = $ia->[0]{id};
				}
			}
		}
        elsif($file =~ m{share/goodie/cheat_sheets/json/.+\.json$}){
			my $j = decode_json(io($file)->slurp);
			$id = $j->{id};
	    }
		elsif($file =~ m{(share/$ia_types/.+)/.+$}){
			my $sd = $1;
			while(my ($sp, $meta_id) = each %share_paths){
				$s->log(["checking if $sd contains $sp"]);
				if($sd eq $sp){
					$id = $meta_id;
					# status for shared assets atm is always "modified" with respect to the IA
					$status = 'M';
					last
				}
			}
			unless($id){
				$s->log_fatal(["Failed to find share path for $sd in share_paths"]);
			}
		}

		if($id){
			$changes{$id} = $status;
		}
		else{
			$s->log_debug(["No id found for $file"]);
		}

	}

	my $f = Dist::Zilla::File::InMemory->new({
		name => $yml,
		content => Dump(\%changes) 
	});

	$s->add_file($f);
}

1;
