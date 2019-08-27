#!/usr/bin/perl -w

use strict;
use DBI;
use Getopt::Long;
use Date::Calc qw(Days_in_Year Day_of_Year);
use Data::Dumper;

use subs qw(
    hidden_stdin
    log
    mean
    median
    confirmation
);

use vars qw(
    $db_user
    $db_pass
    $db_host
    $db_name
    $db_port

    $table
    $created_field
    $key_field

    $partition_add
    $partition_consider_last
    $partition_inflate
    $partition_function
    $partition_prefix

    $no_dry_run
);

$db_user                 = 'root';
$db_host                 = 'localhost';
$db_name                 = 'rt4';
$created_field           = 'Created';
$key_field               = 'id';

$partition_consider_last = 4;
$partition_inflate       = 1.00; # +5%
$partition_function      = 'mean';
$partition_prefix        = 'year_';
$no_dry_run              = 0;

Getopt::Long::Configure ("bundling");

GetOptions(
    'db-user=s'            => \$db_user,
    'db-name=s'            => \$db_name,
    'db-host=s'            => \$db_host,
    'db-port=i'            => \$db_port,
    'p'                    => \$db_pass,
    'table|t=s'            => \$table,
    'partition-add|A=i'    => \$partition_add,
    'consider-last=i'      => \$partition_consider_last,
    'partition-inflate=f'  => \$partition_inflate,
    'partition-function=s' => \$partition_function,
    'partition-prefix=s'   => \$partition_prefix,
    'created-field=s'      => \$created_field,
    'key-field=s'          => \$key_field,
    'no-dry-run'           => \$no_dry_run
);

unless ($table) {
    log('Table is missing, use "--table=Attachments" or similar with this script');
    exit(1)
}

if ($db_pass) {
    print 'Enter password for ' . $db_user . '@' . $db_host . '/' . $db_name . ': ';
    $db_pass = get_stdin_hidden();
}

my $db_dsn = 'dbi:mysql:database=' . $db_name . ';host=' . $db_host;

if ($db_port) {
    $db_dsn .= ';port=' . $db_port;
}

log('Use dsn: %s', $db_dsn);

my $db = DBI->connect($db_dsn, $db_user, $db_pass);

log('SQL_DBMS: %s', $db->get_info(18));

my $sth = $db->prepare('SELECT YEAR(' . $created_field . ') as cr,'
    . ' MIN(id) as mi, MAX(id) as ma, COUNT(id) as cn from ' . $table
    . ' GROUP BY cr'
    . ' ORDER BY cr ASC;');

$sth->execute();

my $ref = $sth->fetchall_arrayref(\{ 0 => 'created', 1 => 'min', 2 => 'max', 3 => 'count' });
my $last = 0;
my ($year, $month) = map { $$_[5]+1900, $$_[4]+1 } [localtime];
my @counts;
my @borders;
my @names;

# Adding partitions from min year to before current year
foreach my $meta (@{ $ref }) {
    unless ($meta->{'created'} eq $year) {
        log(
            'Partition %s%s between %d and %d (items=%d)',
            $partition_prefix,
            $meta->{'created'},
            $meta->{'min'},
            $meta->{'max'},
            $meta->{'count'}
        );

        push(@counts, $meta->{'count'});
        push(@borders, $meta->{'max'});
        push(@names, $partition_prefix . $meta->{'created'});
    }
}

# Adding current year
# Based on ticket amount of remaining days in relation to the last year
# Value is 60 percent of that

my ($last_year_data, $current_year_data) = @{ $ref }[-2, -1];

my $days_last_year = Days_in_Year($year-1, 12);
my $days_rest_in_relation_to_last = $days_last_year - Days_in_Year($year, $month);

# Add 60% of the last years relative ticket amount
my $add_missing = ((($last_year_data->{'count'} / $days_last_year) * $days_rest_in_relation_to_last) * 0.6);

my $border = int(
        $current_year_data->{'max'} + $add_missing
    );

log(
    'Partition %s%s between %d and %d (items=%d)',
    $partition_prefix,
    $current_year_data->{'created'},
    $current_year_data->{'min'},
    $border,
    $current_year_data->{'count'} + $add_missing
);

push(@counts, $current_year_data->{'count'} + $add_missing);
push(@borders, $border);
push(@names, $partition_prefix . $year);

if ($partition_add) {
    my @last_values = @counts[-$partition_consider_last-1..-2];

    if ($partition_function eq 'mean') {
        $border = mean(@last_values);
    } elsif ($partition_function eq 'median') {
        $border = median(@last_values);
    } else {
        die('Partition function "' . $partition_function . '" not available');
    }

    $border = int($border)+1;

    log(
        'Adding %d more partitions with a %s of %d of %d values (inflate by %.2f each)',
        $partition_add,
        $partition_function,
        $border,
        $partition_consider_last,
        $partition_inflate
    );

    my $last_border = $borders[-1];

    for (my $i=0; $i < $partition_add; $i++) {
            $border = int($border * $partition_inflate);

        log(
            'Partition %s%s between %d and %d (items=%d)',
            $partition_prefix,
            $year+1+$i,
            $last_border,
            $last_border + $border,
            $border
        );

        push(@counts, $border);
        push(@borders, $last_border + $border);
        push(@names, $partition_prefix . ($year+1+$i));

        $last_border += $border;
    }
}

log('Generating statement');

my $statement = sprintf("ALTER TABLE %s PARTITION BY RANGE(%s) (\n", $table, $key_field);
for (my $i=0; $i < scalar(@counts); $i++) {
    $statement .= sprintf("    PARTITION %s VALUES LESS THAN(%d),  -- items=%d\n", $names[$i], $borders[$i], $counts[$i]);
}
$statement .= sprintf("    PARTITION %smax VALUES LESS THAN(MAXVALUE)\n", $partition_prefix);
$statement .= sprintf(");\n");

print($statement);

if ($no_dry_run) {
    my $prompt = sprintf('Apply statement to table "%s.%s"', $db_name, $table);

    if (confirmation($prompt)) {
        log('Yes, bold decision! Applying statement');

        $db->do($statement);

        log('Successfully applied statement');

    } else {
        log('Abort, statement not applied');
    }
}

$db->disconnect();

exit(0);

sub get_stdin_hidden {
    system ('stty -echo');
    my $input = <STDIN>;
    system ('stty echo');
    print "\n";
    chomp($input);

    return $input;
}

sub confirmation {
    my $prompt = shift;

    print "$prompt [no]: ";
    my $input = <STDIN>;
    chomp($input);

    if ($input =~ m/^yes$/i) {
        return 1;
    }

    return;
}

sub log {
    my $format = shift;
    my $ts = sprintf(
        "%d-%02d-%02d %02d:%02d:%02d",
        map { $$_[5]+1900, $$_[4]+1, $$_[3], $$_[2], $$_[1], $$_[0] } [localtime]
    );

    print '[' . $ts . ']';

    if (scalar(@_)) {
        printf(' ' . $format, @_)
    } else {
        print ' ' . $format
    }

    print "\n";
}

sub mean {
    my (@data) = @_;

    my $sum;
    foreach (@data) {
        $sum += $_;
    }
    return ( $sum / @data );
}

sub median {
    my (@data) = sort { $a <=> $b } @_;

    if ( scalar(@data) % 2 ) {
        return ( $data[ @data / 2 ] );
    } else {
        my ( $upper, $lower );
        $lower = $data[ @data / 2 ];
        $upper = $data[ @data / 2 - 1 ];
        return ( mean( $lower, $upper ) );
    }
}