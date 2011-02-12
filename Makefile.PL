use inc::Module::Install;
name 'Object-Container-Namespace';
all_from 'lib/Object/Container/Namespace.pm';
readme_pod_from 'lib/Object/Container/Namespace.pm';
githubmeta;

# requires '';
requires 'String::CamelCase';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
auto_install;
WriteAll;
