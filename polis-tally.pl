#!/usr/bin/env perl
use JSON::XS;
use Text::CSV_XS qw( csv );
my $aoa = csv(in => 'comments.csv');
my (@agree, @disagree);
open my $matrix, '<', 'participants-votes.csv' or die $!;
while (<$matrix>) {
    chomp;
    my ($participant,$group_id,$n_comments,$n_votes,$n_agree,$n_disagree,@x) = split /,/, $_;
    for my $idx (0..$#x) {
        next unless length $_;
        $agree[$idx]++ if $x[$idx] eq 1;
        $disagree[$idx]++ if $x[$idx] eq -1;
    }
}
my @result;
for my $idx (0..$#agree) {
    $agree[$idx] //= 0;
    $disagree[$idx] //= 0;
    my ($comment_id,$author_id,$agrees,$disagrees,$moderated,$comment_body) = @{
        (grep { $_->[0] == $idx } @$aoa)[0]
    };
    $comment_body =~ s/\s*$//;
    push @result, {
        idx => $idx,
        n_agree => $agree[$idx],
        n_disagree => $disagree[$idx],
        comment_body => $comment_body,
        percentage => int(($agree[$idx] / ($agree[$idx] + $disagree[$idx])) * 10000) / 100,
    } if ($agree[$idx] + $disagree[$idx]) >= 5;
}
@result = sort { $b->{percentage} <=> $a->{percentage} } @result;
my $id = 0;
$_->{id} = ++$id for @result;
my $out = shift;
unless ($out) {
    print JSON::XS->new->pretty(1)->canonical(1)->encode(\@result);
    exit;
}
{
    my $json = $out;
    $json =~ s/(?:\.csv|\.json)?$/.json/;
    open my $fh, '>:utf8', $json or die $!;
    print $fh JSON::XS->new->pretty(1)->canonical(1)->encode(\@result);
    close $fh;
}
{
    my $csv = $out;
    $csv =~ s/(?:\.csv|\.json)?$/.csv/;
    my @cols = sort keys %{ $result[0] };
    my $aoa = [ \@cols, map { [ @{$_}{@cols}]  } @result ];
    csv(in => $aoa, out => $csv);
}
