#!/usr/bin/perl -w

# check-create-certificate.pl
#     Check and create a self-signed 2048 bit RSA SSL certificate.
#     Target issue: non-interactively create a certificate for any kind of a webservice or webserver.
#
# Author:   J. Daniel Schmidt <jdsn@suse.de>
# License:  GPLv2
#
# Copyright (c) 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.
#


use strict;
use Getopt::Long qw(:config no_ignore_case);;
use File::Basename;


sub usage
{
    print STDERR "\n";
    print STDERR "usage: $0 [--create] [--force] [--path <path>] [--hostname <name>]\n";
    print STDERR "       $0 --help\n";
    print STDERR "\n";
    print STDERR "  Check for and create a 2048 bit rsa SSL certificate, key file and optionally a combined file.\n";
    print STDERR "  Target issue: non-interactively create a certificate for any kind of a webservice or webserver.\n";
    print STDERR "\n";
    print STDERR "Options:\n";
    print STDERR "  -c [--create]               create certificate unless it exists\n";
    print STDERR "                              if omitted exitance of certificate files will only be checked\n";
    print STDERR "  -f [--force]                force to overwrite certificate\n";
    print STDERR "  -h [--help]                 this help\n";
    print STDERR "  -H [--hostname]     <name>  define hostname to use for certificate\n";
    print STDERR "                              if omitted defaults to 'hostname --fqdn'\n";
    print STDERR "  -C [--certfile]     <file>  define certificate file\n";
    print STDERR "                              if omitted defaults to /etc/ssl/certs/self-signed-certificate.pem\n";
    print STDERR "  -K [--keyfile]      <file>  define key file\n";
    print STDERR "                              if omitted defaults to /etc/ssl/private/self-signed-certificate.key\n";
    print STDERR "  -B [--combinedfile] <file>  define combination file of key and certificate\n";
    print STDERR "                              will not be created or checked if omitted\n";
    print STDERR "\n";
}


sub create_certificate($$$$)
{
    my $fqdn         = shift || return undef;
    my $CERTFILE     = shift || return undef;
    my $KEYFILE      = shift || return undef;
    my $COMBINEDFILE = shift || undef;
    chomp $fqdn;
    chomp $CERTFILE;
    chomp $KEYFILE;
    chomp $COMBINEDFILE if defined $COMBINEDFILE;

    my $config="
[req]
distinguished_name = user_dn
# x509_extensions = v3_ca
prompt=no

[user_dn]
commonName = $fqdn
emailAddress = root\@$fqdn
";

    my $CNF  = `mktemp /tmp/create-ssl-config-XXXXX`;
    my $CERT = `mktemp /tmp/create-ssl-cert-XXXXX`;
    my $KEY  = `mktemp /tmp/create-ssl-key-XXXXX`;
    chomp $CNF;
    chomp $CERT;
    chomp $KEY;
    if ( not defined $CNF  || $CNF   =~ /^$/  || 
         not defined $CERT || $CERT  =~ /^$/  ||
         not defined $KEY  || $KEY   =~ /^$/     )
    {
        print STDERR "Could not create temporary files. Aborting.\n";
        return 0;
    }

    my @chmodcmdcnf  = ("chmod", "644", "$CNF");
    my @chmodcmdkey  = ("chmod", "600", "$KEY");
    my @chmodcmdcert = ("chmod", "644", "$CERT");
    system( @chmodcmdcnf );
    system( @chmodcmdkey );
    system( @chmodcmdcert );

    open(CONF, ">$CNF");
    print CONF $config;
    close CONF;

    my @OPENSSLCMD = ("openssl", "req", "-newkey", "rsa:2048", "-x509", "-nodes", "-days", "1095", "-batch", "-config", "$CNF", "-out", "$CERT", "-keyout", "$KEY");
    if ( system(@OPENSSLCMD) == 0 )
    {
        my $COMBINEDPATH = "";
        # copy certificate and key to target location
        my @copycert = ("cp", "-a", "$CERT", "$CERTFILE");
        my @copykey  = ("cp", "-a", "$KEY", "$KEYFILE");
        system(@copycert);
        system(@copykey);

        # create combined file if requested
        if ( defined $COMBINEDFILE )
        {
            my @touchcom = ("touch", "$COMBINEDFILE");
            my @chmodcom = ("chmod", "600", "$COMBINEDFILE");
            my $combine  = "cat $KEY $CERT > $COMBINEDFILE";
            system(@touchcom);
            system(@chmodcom);
            system($combine);
            $COMBINEDPATH = dirname($COMBINEDFILE);
        }

        # remove temporary files
        my $rmtemp   = "rm -f $CNF $CERT $KEY";
        system($rmtemp);

        # run c_rehash in the certificate directories
        my $CERTPATH     = dirname($CERTFILE); 
        system("c_rehash $COMBINEDPATH >/dev/null 2>&1") if defined $COMBINEDFILE;
        system("c_rehash $CERTPATH >/dev/null 2>&1") if ( defined $CERTPATH  &&  $COMBINEDPATH ne $CERTPATH );
    }
    else
    {
        print STDERR "Can not create certificate.\n";
        return 0;
    }

    return 1;
}


################################# MAIN ########################################

my ($create, $force, $hostname, $certfile, $keyfile, $combinedfile, $help);
my $result = GetOptions ("create|c"         => \$create,
                         "force|f"          => \$force,
                         "hostname|H=s"     => \$hostname,
                         "certfile|C=s"     => \$certfile,
                         "keyfile|K=s"      => \$keyfile,
                         "combinedfile|B=s" => \$combinedfile,
                         "help|h"           => \$help
                        );

if ( $help )
{
    usage();
    exit 0;
}

$certfile     = "/etc/ssl/certs/self-signed-certificate.pem"    unless defined $certfile;
$keyfile      = "/etc/ssl/private/self-signed-certificate.key"  unless defined $keyfile;
chomp $certfile;
chomp $keyfile;
chomp $combinedfile if defined $combinedfile;



if (defined $create)
{
    unless (defined $force)
    {
        my $ok = 1;
        foreach my $F (($certfile, $keyfile, $combinedfile))
        {
            if ( -e $F )
            {
                print STDERR "File already exists: $F\n";
                $ok = 0; 
            }
        }
        unless ( $ok == 1 )
        {
            print STDERR "Please use --force to overwrite.\n";
            exit 1;
        }
    }

    $hostname = `hostname --fqdn` unless defined $hostname;
    chomp $hostname if defined $hostname;
    unless (defined $hostname)
    {
        print STDERR "Hostname missing or invalid. Aborting.\n";
        exit 1;
    }

    if ( create_certificate( $hostname, $certfile, $keyfile, $combinedfile ) )
    {
        print "Successfully created certificate.\n";
        exit 0;
    }
    else
    {
        print STDERR "Error when creating the certificate.\n";
        exit 1;
    }

}
else
{
    my $exitcode = 0;
    foreach my $F (($certfile, $keyfile, $combinedfile))
    {
        if (defined $F)
        {
            if ( -e $F )
            {
                next;
            }
            else
            {
                print STDERR "File does not exist: $F\n";
                $exitcode = 1;
            }
        }
    }
    exit $exitcode;
}

