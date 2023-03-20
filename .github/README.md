[![Coverage Status](https://coveralls.io/repos/github/mauke/URL-Search/badge.svg?branch=master)](https://coveralls.io/github/mauke/URL-Search?branch=master)

# NAME

URL::Search - search for URLs in plain text

# SYNOPSIS

```perl
use URL::Search qw( $URL_SEARCH_RE extract_urls partition_urls );

if ($text =~ /($URL_SEARCH_RE)/) {
    print "the first URL in text was: $1\n";
}

my @all_urls = extract_urls $text;
```

# DESCRIPTION

This module searches plain text for URLs and extracts them. It exports (on
request) the following entities:

## `$URL_SEARCH_RE`

This variable is the core of this module. It contains a regex that matches a URL.

NOTE: This regex uses capturing groups internally, so if you embed it in a
bigger pattern, the numbering of any following capture groups will be off. If
this is an issue, use named capture groups of the form `(?<NAME>...)`
instead. See ["Capture groups" in perlre](https://metacpan.org/pod/perlre#Capture-groups).

It only matches URLs with an explicit schema (one of `http` or `https`). The
pattern is deliberately not anchored at the beginning, i.e. it will match
`http://foo` in `"click herehttp://foo"`. If you don't want that, use
`/\b$URL_SEARCH_RE/`.

It tries to exclude artifacts of the surrounding text:

```
Is mayonnaise an instrument? (https://en.wikipedia.org/wiki/Instrument,
https://en.wikipedia.org/wiki/Mayonnaise_(instrument))
```

In this example it will match `https://en.wikipedia.org/wiki/Instrument` and
`https://en.wikipedia.org/wiki/Mayonnaise_(instrument)`, without the comma
after "Instrument" and the final closing parenthesis.

It understands all common URL elements: username, hostname, port, path, query
string, fragment identifier. The hostname can be an IP address (IPv4 and IPv6
are both supported).

Unicode is supported (e.g. `http://поддомен.example.com/déjà-vu?utf8=✓` is
matched correctly).

## `extract_urls`

This function takes a string and returns a list of all contained URLs.

It uses [`$URL_SEARCH_RE`](#url_search_re) to find matches.

Example:

```perl
my $text = 'Visit us at http://html5zombo.com. Also, https://archive.org';
my @urls = extract_urls $text;
# @urls = ('http://html5zombo.com', 'https://archive.org')
```

## `partition_urls`

This function takes a string and splits it up into text and URL segments. It
returns a list of array references, each of which has two elements: The type
(the string `'TEXT'` or `'URL'`) and the portion of the input string that was
classified as text or URL, respectively.

Example:

```perl
my $text = 'Visit us at http://html5zombo.com. Also, https://archive.org';
my @parts = partition_urls $text;
# @parts = (
#   [ 'TEXT', 'Visit us at ' ],
#   [ 'URL', 'http://html5zombo.com' ],
#   [ 'TEXT', '. Also, ' ],
#   [ 'URL', 'https://archive.org' ],
# )
```

You can reassemble the original string by concatenating the second elements of
the returned arrayrefs, i.e.
`join('', map { $_->[1] } partition_urls($text)) eq $text`.

This function can be useful if you want to render plain text as HTML but
hyperlink all embedded URLs:

```perl
use URL::Search qw(partition_urls);
use HTML::Entities qw(encode_entities);

my $text = ...;

my $html = '';
for my $part (partition_urls $text) {
    my ($type, $str) = @$part;
    $str = encode_entities $str;
    if ($type eq 'URL') {
        $html .= "<a rel='nofollow' href='$str'>$str</a>";
    } else {
        $html .= $str;
    }
}
# result is in $html
```

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
[`perldoc`](https://metacpan.org/pod/perldoc) command.

```sh
perldoc URL::Search
```

You can also look for information at [https://metacpan.org/pod/URL::Search](https://metacpan.org/pod/URL::Search).

To see a list of open bugs, visit
[https://rt.cpan.org/Dist/Display.html?Name=URL-Search](https://rt.cpan.org/Dist/Display.html?Name=URL-Search).

To report a new bug, send an email to
`bug-URL-Search [at] rt.cpan.org`.

# AUTHOR

Lukas Mai, `<l.mai at web.de>`

# COPYRIGHT & LICENSE

Copyright 2016, 2017, 2023 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [https://dev.perl.org/licenses/](https://dev.perl.org/licenses/) for more information.
