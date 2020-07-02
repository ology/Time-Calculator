package Time::Calculator;
use Dancer2;

our $VERSION = '0.1';

use DateTime;
use DateTime::Format::Natural;
use DateTime::Format::Strptime;
use Time::Duration::Parse;

my %DURATIONS = (
    w => 'weeks',
    d => 'days',
    h => 'hours',
    m => 'minutes',
    s => 'seconds',
);

=head1 NAME

Time::Calculator - A simple date and time calculator

=head1 ROUTES

=head2 /

=cut

any '/' => sub {
    my $data = calculate(
        first     => params->{first},
        output    => params->{output},
        op        => params->{op},
        undo_text => params->{undo_text},
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
    my $undo  = $args{undo_text};

    my $offset = $first =~ /\A\d+\z/ ? $first : 1;

    my ( $first_dt, $out_dt );

    my $parser = DateTime::Format::Natural->new;
    if ( $first ) {
        $first_dt = $parser->parse_datetime($first);
    }
    if ( $out ) {
        $first_dt = $parser->parse_datetime($out);
    }

    $undo = "$first,$out" unless $op eq 'undo';

    my $dispatch = {
        swap            => sub { my $temp = $first; $first = $out; $out = $temp; },
        clear           => sub { $out = ''; $first = ''; },
        now             => sub { $first = DateTime->now( time_zone => 'local' ) },
        localtime       => sub { $out = scalar localtime $first },
        dow             => sub { $out = $first_dt->day_name },
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
                $first = '';
                $out   = sprintf '%dy %dm %dd or %dh %dm %ds',
                    $first_dt->delta_md($out_dt)->years,
                    $first_dt->delta_md($out_dt)->months,
                    $first_dt->delta_md($out_dt)->days,
                    $first_dt->delta_ms($out_dt)->hours,
                    $first_dt->delta_ms($out_dt)->minutes,
                    $first_dt->delta_ms($out_dt)->seconds;
            }
        },
        duration => sub {
            my $timestring = $first =~ s/(\d+)([a-z])/$1 $DURATIONS{$2} /gr;
            $out = parse_duration($timestring) . 's';
        },
        undo => sub {
            my ( $temp_first, $temp_out ) = ( $first, $out );
            ( $first, $out ) = split ',', $undo;
            $undo = "$temp_first,$temp_out";
        },
    };

    $dispatch->{$op}->();

    return { first => $first, output => $out, undo => $undo };
}

true;

__END__

=head1 AUTHOR
 
Gene Boggs <gene@cpan.org>
 
=head1 COPYRIGHT AND LICENSE
 
This software is copyright (c) 2019 by Gene Boggs.
 
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
 
=cut
