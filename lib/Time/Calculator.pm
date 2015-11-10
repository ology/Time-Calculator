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
    my $first = $args{first};
    my $out   = $args{output};

    my $offset = $first =~ /\A\d+\z/ ? $first : 1;

    my ( $stamp, $first_dt, $out_dt );

    if ( $first ) {
        $stamp = UnixDate( $first, "%Y-%m-%eT%H:%M:%S" );
        $first_dt = DateTime::Format::DateParse->parse_datetime($stamp);
    }
    if ( $out ) {
        $stamp = UnixDate( $out, "%Y-%m-%eT%H:%M:%S" );
        $out_dt = DateTime::Format::DateParse->parse_datetime($stamp);
    }

    my $dispatch = {
        clear => sub { $out = ''; $first = ''; },
        now   => sub {
            if ( $out ) {
                $first = DateTime->now(time_zone => 'local');
            }
            else {
                $out = DateTime->now(time_zone => 'local');
            }
        },
        localtime       => sub { $out = scalar localtime $first },
        dow             => sub { $out = $out_dt->day_name },
        add_year        => sub { $out = $out_dt->add( years => $offset ) },
        subtract_year   => sub { $out = $out_dt->subtract( years => $offset ) },
        add_month       => sub { $out = $out_dt->add( months => $offset ) },
        subtract_month  => sub { $out = $out_dt->subtract( months => $offset ) },
        add_day         => sub { $out = $out_dt->add( days => $offset ) },
        subtract_day    => sub { $out = $out_dt->subtract( days => $offset ) },
        add_hour        => sub { $out = $out_dt->add( hours => $offset ) },
        subtract_hour   => sub { $out = $out_dt->subtract( hours => $offset ) },
        add_minute      => sub { $out = $out_dt->add( minutes => $offset ) },
        subtract_minute => sub { $out = $out_dt->subtract( minutes => $offset ) },
        add_second      => sub { $out = $out_dt->add( seconds => $offset ) },
        subtract_second => sub { $out = $out_dt->subtract( seconds => $offset ) },
        difference      => sub {
            if ( $first_dt && $out_dt ) {
                $out = sprintf '%dy %dm %dd or %dh %dm %ds',
                    $first_dt->delta_md($out_dt)->years,
                    $first_dt->delta_md($out_dt)->months,
                    $first_dt->delta_md($out_dt)->days,
                    $first_dt->delta_ms($out_dt)->hours,
                    $first_dt->delta_ms($out_dt)->minutes,
                    $first_dt->delta_ms($out_dt)->seconds;
                $first = '';
            }
        },
    };

    $dispatch->{$op}->();

    return { first => $first, output => $out };
}

true;
