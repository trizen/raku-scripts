#!/usr/bin/perl6

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 22 September 2015
# Website: https://github.com/trizen

# The script generates formulas for calculating the sum
# of consecutive numbers raised to a given power, such as:
#    1^p + 2^p + 3^p + ... + n^p
# where p is a positive integer.

# See also: https://en.wikipedia.org/wiki/Faulhaber%27s_formula

# To simplify the formulas, use Wolfram Alpha:
# http://www.wolframalpha.com/

# This function returns the nth Bernoulli number
# See: https://en.wikipedia.org/wiki/Bernoulli_number
sub bernoulli_number($n) is cached {

    return 1/2 if $n == 1;        # 1/2 if n is 1
    return 0/1 if $n % 2;         # 0 if n is odd

    my @A;
    for 0..$n -> $m {
        @A[$m] = 1 / ($m + 1);
        for $m, $m-1 ... 1 -> $j {
            @A[$j - 1] = $j * (@A[$j - 1] - @A[$j]);
        }
    }

    return @A[0];                    # which is Bn
}

# The binomial coefficient
# See: https://en.wikipedia.org/wiki/Binomial_coefficient
sub binomial($n, $k) is cached {
    $k == 0 || $n == $k ?? 1 !! binomial($n-1, $k-1) + binomial($n-1, $k);
}

# The Faulhaber's formula
# See: https://en.wikipedia.org/wiki/Faulhaber%27s_formula
sub faulhaber_s_formula($p) {

    my @formula;
    for 0..$p -> $j {
        push @formula, ('(' ~ join('/', (binomial($p + 1, $j) * bernoulli_number($j)).Rat.nude) ~ ')') ~ '*' ~ "n^" ~ ($p + 1 - $j);
    }

    my $formula = join(' + ', @formula.grep({$_.Str !~~ m{'(0/1)*'}}));

    $formula .= subst(rx{ '(1/1)*' }, '', :g);
    $formula .= subst(rx{ '^1'» }, '', :g);

    "1/" ~ ($p + 1) ~ " * ($formula)";
}

for 0..10 -> $i {
    say "$i: ", faulhaber_s_formula($i);
}
