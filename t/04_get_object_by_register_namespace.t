use t::Utils;
use Test::More;
use Test::Container qw/api/;

is api('hoge')->fuga,'Hello Container!','call object method';


done_testing();
