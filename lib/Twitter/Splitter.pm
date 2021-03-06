package Twitter::Splitter;

use Moose;
use Readonly;
use Encode;
Readonly my $MAX_TWEET_LENGTH => 280;

use Fcntl qw( :seek );

has 'source_fh' => (
    required => 1,
    isa      => 'IO::Seekable',
    is       => 'ro',
);

has 'include_pager' => (
    isa => 'Bool',
    is => 'ro',
    default => 1,
);

has 'append_pager' => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

has 'hashtag' => (
    isa => 'Str',
    is => 'rw',
    default => '',
);

has 'tweet_length' => (
    isa => 'Num',
    is => 'ro',
    default => $MAX_TWEET_LENGTH,
);

has 'tweets' => (
    isa => 'ArrayRef',
    is  => 'rw',
    traits => [ 'Array' ],
    handles => {
        all_tweets => 'elements',
        get_tweet  => 'get',
        add_tweet  => 'push',
    },
    lazy_build => 1,
);

sub _build_tweets {
    my $self = shift;
    my $word = '';
    my $word_ends_in_a_newline = 0;
    my $source_fh = $self->source_fh;
    my $longest_tweet_count_length = 0;

    my @tweets;

    $self->_clean_hashtag;

    until ( $source_fh->eof ) {
        my $tweet = '';
        if ( length (scalar @tweets) > $longest_tweet_count_length ) {
            # Dang! Start all over, increasing the pager's length by one character.
            @tweets = ();
            $word = '';
            $longest_tweet_count_length++;
            $source_fh->seek( 0, 0 );
            next;
        }

        my $word_doesnt_fit = 0;
        until ( $word_doesnt_fit || $word_ends_in_a_newline ) {

            $word ||= $self->read_word;
            unless ( $word =~ /\S/ ) {
                last;
            }

            if ( $word =~ /\n\n$/ ) {
                $word_ends_in_a_newline = 1;
            }
            $word =~ s/\s+$/ /;

            if (
            length( $tweet )
                + length( $word )
                + length( '(/)' )
                + length( scalar @tweets + 1 )
                + ($self->hashtag? length( $self->hashtag ) + 1 : 0)
                + $longest_tweet_count_length
                <= $self->tweet_length
            ) {
                $tweet .= $word;
                $word = '';
            }
            else {
                $word_doesnt_fit = 1;
            }
        }

        if ( $word_doesnt_fit && not $tweet ) {
            die "BAD NEWS: This word is just too long, sorry: $word\n";
        }

        $tweet =~ s/\s+$//;
        push @tweets, $tweet;
        $word_ends_in_a_newline = 0;
    }

    my $tweet_count = scalar @tweets;
    for ( my $index = 0; $index <= $#tweets; $index++ ) {
        my $tweet_number = $index + 1;
        my $pager;
        if ( $self->include_pager ) {
            $pager = "($tweet_number/$tweet_count)";
        }
        else {
            $pager = q{};
        }

        if ( $self->append_pager ) {
            my $hashtag = $self->hashtag
                          ? q{ } . $self->hashtag
                          : ''
                          ;
            $tweets[ $index ] = "$tweets[ $index ] $pager$hashtag";
        }
        else {
            my $hashtag = $self->hashtag
                          ? $self->hashtag . q{ }
                          : ''
                          ;
            $tweets[ $index ] = "$hashtag$pager $tweets[ $index ]";
        }
    }

    return \@tweets;
}

sub _clean_hashtag {
    my $self = shift;

    my $hashtag = $self->hashtag;

    $hashtag =~ s/^\s+//g;
    if ( $hashtag && ( $hashtag =~ /^[^#]/ ) ) {
        $hashtag = q{#} . $hashtag;
    }

    $self->hashtag( $hashtag );
}

sub read_word {
    my $self = shift;
    my $word = '';
    my $letter;

    while ( $self->source_fh->read( $letter, 1 ) ) {
        $word .= $letter;
        if ( $word =~ /^\s/ ) {
            # Read whitespace, but no word-parts yet. Skip and keep reading.
            $word = '';
        }
        elsif ( $word =~ /\s$/ ) {
            # Keep reading whitespace; stop and rewind if we see non-whitespace.
            while ( $self->source_fh->read( $letter, 1 ) ) {
                if ( $letter =~ /^\s$/ ) {
                    $word .= $letter;
                }
                else {
                    my $rewind_bytes = length(Encode::encode_utf8( $letter ) );
                    $self->source_fh->seek( 0 - $rewind_bytes, SEEK_CUR );
                    last;
                }
            }
            last;
        }
    }

    return $word;
}

1;
