# polis-tally
Tally Pol.is export format

# Prerequisites

Perl modules `Text::CSV_XS` and `JSON::XS` from CPAN.

# Usage

First, obtain the pol.is export zip file by navigating to the /export page such as https://pol.is/m/8s9hcwinjf/export (you can do this for any pol.is pages created by yourself or configured as "Open Data").

Then unzip the file and cd into the directory, and run:

```
perl /path/to/polis-tally.pl output.json
```

This will generate both a `.json` file and a `.csv` file with the same basename.

