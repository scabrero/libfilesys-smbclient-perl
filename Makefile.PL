use ExtUtils::MakeMaker;

my ($define, $ccfl);

# special flag for AIX
($^O =~ m/AIX/i) ? ($ccfl = '-qcpluscmt') : ($ccfl = '');

# path libsmbclient.h
my $include = try_to_find("libsmbclient.h");
$include = prompt("Where can I find libsmbclient.h ?", $include);
warn_user("$include/libsmbclient.h") if (!-r "$include/libsmbclient.h");

# path libsmbclient.so
my $lib = try_to_find("libsmbclient.so");
$lib = prompt("Where can I find libsmbclient.so ?",$lib);
warn_user("libsmbclient.so") if (!-r "$lib/libsmbclient.so");

# tests demande ?
my $ans = 
  prompt("Do you want make tests ?(you will be prompted for server / \n".
	   "worgroup / share / user / password to make read write access.",
	   "yes");
if ($ans =~ /^y(es)?$/i) 
  {
    my $server = prompt("Server ?","localhost");
    my $share = prompt("Share ?","homes");
    my $workgroup = prompt("Workgroup/Domain ?","");
    my $user = prompt("Smb user ?",$ENV{'USER'});
    my $pass = prompt("Smb password ?");
    open(FILE,">.c") || warn "Can't create .c for test: $!\n";
    print FILE $server,"\t",$share,"\t",$workgroup,"\t",$user,"\t",$pass;
    close FILE;
  }

# Trace for debug
$ans = prompt("Compile module with trace to STDERR ?", "no");
if ($ans =~ /^y(es)?$/i) { $define = "-DVERBOSE"; }

# Create config.h for alloca via configure
my $prefix = $include;
$prefix=$1 = $1 if $include=~m!(.*)include$!;
system("./configure --with-samba-prefix=$prefix") == 0
  or die "Can't run configure:$!\n";

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

sub warn_user
  {
    my $file = $_[0];
    warn <<EOF;
*************************************************************
** WHAT !!!!
** I Can't find $file : $!. 
*************************************************************
If you don't have this file you can download last version
of Samba on www.samba.org and do:

\$ tar zxvf samba-2.2.x.tar.gz
\$ cd samba-2.2.x/source
\$ ./configure
\$ make bin/libsmbclient.so

Then you can find libsmbclient.h in source/include directory and
libsmbclient.so in source/bin directory. You can then put them in
/usr/include and /usr/lib (or /usr/local/include and 
/usr/local/lib)

EOF

  }

sub try_to_find {
  my $name = shift;
  my @path = find_path($name);
  foreach my $d (@path) {
    if (-e "$d/$name") { return $d; }
  }
}

sub find_path {
  my $ext = ($_[0]=~m!\.h$! ? "include" : ( $ENV{HOSTTYPE}=~m!x86_64! ? "lib64" : "lib"));
  my $defaultsDir = { "/usr" => 1,
		      "/usr/local" => 1,
		      "/usr/local/samba" => 1,
		      "/usr/local/samba3" => 1 };
  my @pa = split(/:/, $ENV{PATH});
  my @path;
  foreach (@pa) {
    s/bin//;
    s!//!/!g;
    s!/$!!g;
    push(@path, $_."/$ext") if !$defaultsDir->{$_};
  }
  foreach (keys %$defaultsDir) { push(@path, $_."/$ext"); }
  print "I search in: ",(join "\n", @path),"\n";
  return @path;
}
