use strict;
use warnings;

sub slurp {
    my ($file) = @_;
    open my $fh, '<', $file or die "$0: $file: $!\n";
    local $/;
    readline $fh
}

my $version = shift @ARGV;
my @modules = split ' ', shift @ARGV;

my @errors;

if ($version !~ /_|TRIAL/) {
    my $file = 'Changes';
    my $contents = slurp $file;

    my $alt_version = $version;
    $alt_version =~ s/^(\d+\.\d{3})(?=\d)/$1_/;

    $contents =~ m{
        \n
        \n
        (?: \Q$version\E | \Q$alt_version\E ) \s+ \d{4}-\d{2}-\d{2} \n
        [^\n\w]* \w
    }x or push @errors, "$file doesn't seem to contain an entry for $version";
}

my $version_re =
    $version =~ /^\d+(?:\.\d+)?\z/
        ? qr{ \Q$version\E | '\Q$version\E' }x
        : qr{ '\Q$version\E' }x;

for my $module (@modules) {
    my $contents = slurp $module;
    my $pkg = $module;
    $pkg =~ s/\.pm\z//;
    $pkg =~ s![/\\]!::!g;
    $pkg =~ s/^lib:://;

    $contents =~ m{
        ^ [ \t]* (?: our [ \t]+ )?
        \$ (?: \Q$pkg\E :: )? VERSION [ \t]* = [ \t]*
        ( \d+ (?: _ \d+ )* (?: \. \d+ (?: _ \d+ )* )? | '([^'\\]+)' ) ;
    }xm or do {
        push @errors, "$module doesn't contain a parsable VERSION declaration";
        next;
    };
    my $v = $+;
    $v =~ s/(?<=\d)_(?=\d)//g
        if $v =~ /^\d/;

    $v eq $version
        or push @errors, "$module version '$v' doesn't match distribution version '$version'";
}

if (@errors) {
    print STDERR map "$0: $_\n", @errors;
    exit 1;
}
