#!/usr/bin/perl6

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 10 April 2016
# Website: https://github.com/trizen

# Implementation of a variation of the Mersenne Twister (unbounded and with arbitrary precision).
# Returns a random float in the interval [0, 1)
# See: https://en.wikipedia.org/wiki/Mersenne_Twister

class MT19937 {

    has $.seed is required;
    has $.prec is required;

    constant $l = 18;
    constant $a = 0x9908B0DF16;
    constant $f = 1812433253;
    constant $u = 11;
    constant $d = 0xFFFFFFFF16;
    constant $s = 7;
    constant $b = 0x9D2C568016;
    constant $t = 5;
    constant $c = 0xEFC6000016;
    constant $n = 624;
    constant $m = 397;

    submethod BUILD(:$!seed, :$!prec) {

        has $!index = $n;
        has @!mt; @!mt[0] = $!seed;
        has $!decimals = 10**$!prec;

        for ^($n-1) -> $i {
            @!mt[$i+1] = ($f * (@!mt[$i] +^ (@!mt[$i] +> ($!prec-2))) + $i+1);
        }
    }

    method extract_number {
        if ($!index >= $n) {
            if ($!index > $n) {
                die "Generator was never seeded";
            }
            self.twist();
        }

        my $y = @!mt[$!index];
        $y = ($y +^ (($y +> $u) +& $d));
        $y = ($y +^ (($y +< $s) +& $b));
        $y = ($y +^ (($y +< $t) +& $c));
        $y = ($y +^ ($y +> $l));

        ++$!index;
        ($y % $!decimals) / $!decimals;
    }

    method twist {
        for ^$n -> $i {
            my $x = (@!mt[$i] + @!mt[($i+1) % $n]);
            my $xA = ($x +> 1);
            if (($x % 2) != 0) {
                $xA +^= $a;
            }
            @!mt[$i] = (@!mt[($i + $m) % $n] +^ $xA);
        }
        $!index = 0;
    }
}

my $obj = MT19937.new(seed => 42, prec => 32);
for ^10 { say $obj.extract_number() }
