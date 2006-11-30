use ExtUtils::MakeMaker;

my ($define, $ccfl);

# special flag for AIX
($^O =~ m/AIX/i) ? ($ccfl = '-qcpluscmt') : ($ccfl = '');

# path to libsmbclient.h
my $include = '/usr/include';

# path to libsmbclient.so
my $lib = '/usr/lib';

# Create config.h for alloca via configure
system("./configure") == 0 or die "Can't run configure:$!\n";

$define = "-DVERBOSE" if $ENV{'DH_VERBOSE'};

# Create makefile
WriteMakefile
  (
   'NAME'         => 'Filesys::SmbClient',
   'VERSION_FROM' => 'SmbClient.pm',
   'INC'          => "-I$include",
   'DEFINE'       => $define,
   'LIBS'         => ["-L$lib -lsmbclient"],
   'OBJECT'       => 'libauthSamba.o SmbClient.o',
   'CCFLAGS'      => $ccfl,
   'PREREQ_PM'    => { Test::More => 0},
   'clean' => { FILES => "*~ config.status config.log config.h config.cache .c"},
   ($] ge '5.005') ?
   (
    'AUTHOR' => 'Alain BARBET (alian@alianwebserver.com)',
    'ABSTRACT' => 'Filesys::SmbClient - Interface for access Samba filesystem with libsmclient.so'
   )
   : ()
  );
