package Time::Calculator;
use Dancer2;

our $VERSION = '0.1';

use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::DateParse;

=head1 NAME

Time::Calculator - A simple date and time calculator

=head1 ROUTES

=head2 /

=cut

any '/' => sub {
    my $data = calculate(
        first  => params->{first},
        output => params->{output},
        op     => params->{op},
    );

    template 'index', $data;
};

=head1 METHODS

=head2 calculate()

=cut

sub calculate {
    my %args = @_;

    my $first  = $args{first};
    my $offset = $first =~ /\A\d+\z/ ? $first : 1;

    my $out   = $args{output};
    my $op    = $args{op};

    my $format = DateTime::Format::Strptime->new(
       pattern   => '%Y-%m-%dT%H:%M:%S',
       time_zone => 'local',
       on_error  => 'croak',
    );
    my $parsed = eval { $format->parse_datetime($out) };
    my $dt = !$@ && params->{output}
        ? $parsed
        : DateTime->now(time_zone => 'local');

    if ($op) {
        if ( $op eq 'clear' ) {
            $out   = '';
            $first = '';
        }
        elsif ( $op eq 'now' ) {
            if ($out) {
                $first = DateTime->now(time_zone => 'local');
            }
            else {
                $out = DateTime->now(time_zone => 'local');
            }
        }
        elsif ( $op eq 'dow' ) {
            $out = $dt->day_name();
        }
        elsif ( $op eq 'add_year' ) {
            $out = $dt->add( years => $offset );
        }
        elsif ( $op eq 'subtract_year' ) {
            $out = $dt->subtract( years => $offset );
        }
        elsif ( $op eq 'add_month' ) {
            $out = $dt->add( months => $offset );
        }
        elsif ( $op eq 'subtract_month' ) {
            $out = $dt->subtract( months => $offset );
        }
        elsif ( $op eq 'add_day' ) {
            $out = $dt->add( days => $offset );
        }
        elsif ( $op eq 'subtract_day' ) {
            $out = $dt->subtract( days => $offset );
        }
        elsif ( $op eq 'add_hour' ) {
            $out = $dt->add( hours => $offset );
        }
        elsif ( $op eq 'subtract_hour' ) {
            $out = $dt->subtract( hours => $offset );
        }
        elsif ( $op eq 'add_minute' ) {
            $out = $dt->add( minutes => $offset );
        }
        elsif ( $op eq 'subtract_minute' ) {
            $out = $dt->subtract( minutes => $offset );
        }
        elsif ( $op eq 'add_second' ) {
            $out = $dt->add( seconds => $offset );
        }
        elsif ( $op eq 'subtract_second' ) {
            $out = $dt->subtract( seconds => $offset );
        }
        elsif ( $op eq 'difference' ) {
            if ( $first && $out ) {
                my $parsed = DateTime::Format::DateParse->parse_datetime($first);
                my $format = DateTime::Format::Strptime->new(
                   pattern   => '%Y-%m-%dT%H:%M:%S',
                   time_zone => 'local',
                   on_error  => 'croak',
                );
                my $first_parsed = $format->parse_datetime("$parsed");

                $out = $first_parsed->delta_md($dt)->years()          . 'y';
                $out .= ' ' . $first_parsed->delta_md($dt)->months()  . 'm';
                $out .= ' ' . $first_parsed->delta_md($dt)->days()    . 'd';
                $out .= ' ' . $first_parsed->delta_md($dt)->hours()   . 'h';
                $out .= ' ' . $first_parsed->delta_ms($dt)->minutes() . 'm';
                $out .= ' ' . $first_parsed->delta_ms($dt)->seconds() . 's';

                $first = '';
            }
        }
    }

    return { output => "$out", first => $first };
}

true;
