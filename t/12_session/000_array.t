use strict;
use warnings;
use Test::More;

use Data::ObjectMapper::Session::Array;

{
    package Data::ObjectMapper::Session::DummyUOW;

    sub new { bless +{ add => [], delete => [] }, $_[0] }

    sub add {
        my $self = shift;
        push @{$self->{add}}, @_;
    }

    sub delete {
        my $self = shift;
        push @{$self->{delete}}, @_;
    }

    1;
};

my $uow = Data::ObjectMapper::Session::DummyUOW->new;
my $array = Data::ObjectMapper::Session::Array->new($uow, qw(a b c d));

ok tied(@$array);
is_deeply $array, $uow->{add};
is $array->[0], 'a';

push @$array, 'e';
unshift @$array, 0;
is_deeply $array, [qw(0 a b c d e)];
is_deeply $uow->{add}, [qw(a b c d e 0)];

shift @$array;
is_deeply $array, [qw(a b c d e)];
is_deeply $uow->{add}, [qw(a b c d e 0)];
is_deeply $uow->{delete}, [qw(0)];

pop @$array;
is_deeply $array, [qw(a b c d)];
is_deeply $uow->{add}, [qw(a b c d e 0)];
is_deeply $uow->{delete}, [qw(0 e)];

splice @$array, 0, 0, '1';
is_deeply $array, [qw(1 a b c d)];
is_deeply $uow->{add}, [qw(a b c d e 0 1)];
is_deeply $uow->{delete}, [qw(0 e)];

splice @$array, 0, 1, '2';
is_deeply $array, [qw(2 a b c d)];
is_deeply $uow->{add}, [qw(a b c d e 0 1 2)];
is_deeply $uow->{delete}, [qw(0 e 1)];

splice @$array, 3;
is_deeply $array, [qw(2 a b)];
is_deeply $uow->{add}, [qw(a b c d e 0 1 2)];
is_deeply $uow->{delete}, [qw(0 e 1 c d)];

$array->[3] = 'f';
is_deeply $array, [qw(2 a b f)];
is_deeply $uow->{add}, [qw(a b c d e 0 1 2 f)];
is_deeply $uow->{delete}, [qw(0 e 1 c d)];

is join(',', @$array), '2,a,b,f';

done_testing;
