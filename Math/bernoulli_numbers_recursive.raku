#!/usr/bin/raku

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 22 September 2015
# Website: https://github.com/trizen

# Recursive computation of Bernoulli numbers.

# See: https://en.wikipedia.org/wiki/Bernoulli_number#Recursive_definition
#      https://en.wikipedia.org/wiki/Binomial_coefficient#Recursive_formula

use experimental :cached;

sub binomial($n, $k) is cached {
    $k == 0 || $n == $k ?? 1 !! binomial($n-1, $k-1) + binomial($n-1, $k);
}

sub bern_helper($n, $k) is cached {
    binomial($n, $k) * (bernoulli_number($k) / ($n - $k + 1));
}

sub bern_diff($n, $k, $d) {
    $n < $k ?? $d !! bern_diff($n, $k+1, $d - bern_helper($n+1, $k));
}

sub bernoulli_number($n) is cached {

    return 1/2 if $n == 1;        # 1/2 if n is 1
    return 0/1 if $n % 2;         # 0 if n is odd

    $n > 0 ?? bern_diff($n-1, 0, 1) !! 1;
}

for 0..50 -> $i {
    printf "B%-2d = %s/%s\n", $i, bernoulli_number($i).Rat.nude;
}
