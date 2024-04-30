#!/usr/bin/raku

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 15th October 2013
# http://trizenx.blogspot.com
# http://trizenx.blogspot.com/2013/11/smart-word-wrap.html

# Smart word wrap algorithm
# See: http://en.wikipedia.org/wiki/Word_wrap#Minimum_raggedness

# This is the ugliest method! It, recursively,
# prepares the words for the combine() function.
sub prepare_words(@words, $width, &callback, $depth=0) {

    my @root;
    my $len = 0;
    my $i = -1;

    my $limit = @words.end;
    while (++$i <= $limit) {
        $len += (my $word_len = @words[$i].chars);

        if ($len > $width) {
            if ($word_len > $width) {
                $len -= $word_len;
                @words = (|@words[^$i], |@words[$i].comb($width), |@words[$i+1..*]);
                $limit = @words.end;
                $i -= 1;
                next;
            }
            last;
        }

        @root.push: [
            @words[0..$i].join(' '),
            prepare_words(@words[$i+1..*], $width, &callback, $depth+1),
        ];

        if $depth == 0 {
            callback(\(@root.first));
            @root = ();
        }

        last if (++$len >= $width);
    }

    @root;
}

# This function combines the
# the parents with the childrens.
sub combine($path, &callback, $root = []) {
    my $key = $path.shift;
    for |$path -> $value {
        $root.push: $key;
        if ($value) {
            for |$value -> $item {
                combine($item, &callback, $root);
            }
        }
        else {
            callback(\($root));
        }
        $root.pop;
    }
}

# This is the main function of the algorithm
# which calls all the other functions and
# returns the best possible wrapped string.
sub smart_wrap($text, $width) {

    my @words = ($text.isa(Array) ?? $text !! $text.words);

    my %best = (
        score => Inf,
        value => [],
    );

    prepare_words(@words, $width, ->($path) {
        combine($path, ->($combination) {
            my $score = 0;
            for $combination[0..*-2] -> $line {
                $score += ($width - $line.chars)**2;
            }

            if ($score < %best<score>) {
                %best<score> = $score;
                %best<value> = [|$combination];
            }
        })
    });

    %best<value>.join("\n")
}


#
## Usage examples
#

my $text = 'aaa bb cc ddddd';
say smart_wrap($text, 6);

say '-' x 80;

$text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
say smart_wrap($text, 20);

say '-' x 80;

$text = "Lorem ipsum dolor ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ amet, consectetur adipiscing elit.";
say smart_wrap($text, 20);

say '-' x 80;

$text = 'As shown in the above phases (or steps), the algorithm does many useless transformations';
say smart_wrap($text, 20);
