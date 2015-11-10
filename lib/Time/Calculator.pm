package Time::Calculator;
use Dancer2;

our $VERSION = '0.1';

use Date::Manip;
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

    my $op    = $args{op} // 'clear';
    my $out   = $args{output};
    my $first = $args{first};

    my $offset = $first =~ /\A\d+\z/ ? $first : 1;

    my $format = DateTime::Format::Strptime->new(
       pattern   => '%Y-%m-%dT%H:%M:%S',
       time_zone => 'local',
       on_error  => 'croak',
    );
    my $parsed = eval { $format->parse_datetime($out) };
    my $dt = !$@ && params->{output}
        ? $parsed
        : DateTime->now(time_zone => 'local');

    my $dispatch = {
        clear => sub { $out = ''; $first = ''; },
        now   => sub {
            if ($out) {
                $first = DateTime->now(time_zone => 'local');
            }
            else {
                $out = DateTime->now(time_zone => 'local');
            }
        },
        dow             => sub { $out = $dt->day_name },
        add_year        => sub { $out = $dt->add( years => $offset ) },
        subtract_year   => sub { $out = $dt->subtract( years => $offset ) },
        add_month       => sub { $out = $dt->add( months => $offset ) },
        subtract_month  => sub { $out = $dt->subtract( months => $offset ) },
        add_day         => sub { $out = $dt->add( days => $offset ) },
        subtract_day    => sub { $out = $dt->subtract( days => $offset ) },
        add_hour        => sub { $out = $dt->add( hours => $offset ) },
        subtract_hour   => sub { $out = $dt->subtract( hours => $offset ) },
        add_minute      => sub { $out = $dt->add( minutes => $offset ) },
        subtract_minute => sub { $out = $dt->subtract( minutes => $offset ) },
        add_second      => sub { $out = $dt->add( seconds => $offset ) },
        subtract_second => sub { $out = $dt->subtract( seconds => $offset ) },
        difference      => sub {
            if ( $first && $out ) {
                my $date = UnixDate( $first, "%Y-%m-%eT%H:%M:%S" );
                my $first_dt = DateTime::Format::DateParse->parse_datetime($date);
                if ( $first_dt ) {
                    $out = sprintf '%dy %dm %dd or %dh %dm %ds',
                        $first_dt->delta_md($dt)->years,
                        $first_dt->delta_md($dt)->months,
                        $first_dt->delta_md($dt)->days,
                        $first_dt->delta_ms($dt)->hours,
                        $first_dt->delta_ms($dt)->minutes,
                        $first_dt->delta_ms($dt)->seconds;
                }
                $first = '';
            }
        },
        localtime       => sub { $out = scalar localtime $first },
    };

    $dispatch->{$op}->();

    return { first => $first, output => $out };
}

true;
