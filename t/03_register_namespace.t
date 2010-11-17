use t::Utils;
use Test::More;
use Test::Container qw/api/;

isa_ok api('hoge'),'Test::Api::Hoge','get registered instance';


done_testing();
