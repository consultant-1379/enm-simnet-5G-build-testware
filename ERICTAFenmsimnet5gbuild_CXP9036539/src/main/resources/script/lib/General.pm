#!/usr/bin/perl
#############################################################################
#    START LIB MODULE HEADER
#############################################################################
#
#     Name :  General
#
#     Description : Contains all general/netsim functions.
#
#     Functions : getENVfilevalue("TEST.env","SIMTYPE")
#                 makeMMLscript($MOSCRIPT,@MOCmds)
#                 makeMOscript($MMLSCRIPT,@MMLCmds);
#                 CheckMIM(SimName);        
#
#############################################################################
#    END LIB MODULE HEADER
#############################################################################
##########################################
#  Environment
##########################################
package General;
require Exporter;
@ISA = qw(Exporter);

# NOTE: NEED TO ADD NEW MODULE FUNCTIONS HERE
@EXPORT = qw(getENVfilevalue makeMOscript makeMMLscript CheckMIM);
use Cwd;
##########################################
# funcs
##########################################
#-----------------------------------------
#  Name : getEnvfilevalue
#  Description : returns a value for the
#  /dat/$LTE_name.env file which contains
#  preassigned values.
#  Params : $LTE_ENV_Filename &
#           $Value ie. SIMTYPE=ST where
#  $Value=SIMTYPTE and return value is ST
#  Example : @getENVfilevalue("TEST.env","SIMTYPE")
#  Return : ST where SIMTYPE=ST
#-----------------------------------------
sub getENVfilevalue {
    local ( $env_file_name, $env_file_constant ) = @_;
    local @envfiledata    = ();
    local $env_file_value = "ERROR";
    local $dir            = cwd, $currentdir = $dir . "/";
    local $scriptpath     = "$currentdir";
    local $envdir;

    # navigate to dat directory
    $scriptpath =~ s/lib.*//;
    $scriptpath =~ s/bin.*//;
    $envdir = $scriptpath . "dat/$env_file_name";
    if ( !-e "$envdir" ) {
        print "ERROR : $envdir does not exist\n";
        return ($env_file_value);
    }

    open FH, "$envdir" or die $!;
    @envfiledata = <FH>;
    close(FH);
    foreach $element (@envfiledata) {
        if ( $element =~ /\#/ )      { next; }    # end if
        if ( !( $element =~ /\=/ ) ) { next; }    # end if

        $tempelement = $element;
        $tempelement =~ s/=.*//;
        $tempelement =~ s/\n//;

        $env_file_constant =~ s/\n//;

        if ( "$env_file_constant" eq "$tempelement" ) {
            $env_file_value = $element;
            $env_file_value =~ s/^\s+//;
            $env_file_value =~ s/^.*=//;
            $env_file_value =~ s/\s+$//;
        }    # end if

    }    # end foreach
    return ($env_file_value);
}    # end getENVfilevalue
     #-----------------------------------------
     #  Name : makedMOscript
     #  Description : builds a netsim mo script
     #  Params : $mmlscriptname,
     #  Example :&makeMOscript($fileaction,$MOSCRIPT,@MOCmds);
     #  Return : populated netsim mo script
     #-----------------------------------------

sub makeMOscript {
    local ( $fileaction, $moscriptname, @cmds ) = @_;
    $moscriptname =~ s/\.\///;
    if ( $fileaction eq "write" ) {
        if ( -e "$moscriptname" ) {
            unlink "$moscriptname";
        }    #end if
        open FH1, ">$moscriptname" or die $!;
    }    # end write
    if ( $fileaction eq "append" ) {
        open FH1, ">>$moscriptname" or die $!;
    }    # end append
    foreach $_ (@cmds) { print FH1 "$_\n"; }
    close(FH1);
    system("chmod 744 $moscriptname");
    return ($moscriptname);
}    # end makeMOscript
     #-----------------------------------------
     #  Name : makedMMLscript
     #  Description : builds a netsim mml script
     #  Params : $mmlscriptname,
     #  Example :&makeMMLscript($fileaction,$MMLSCRIPT,@MMLCmds);
     #  Return : populated netsim mml script
     #-----------------------------------------

sub makeMMLscript {
    local ( $fileaction, $mmlscriptname, @cmds ) = @_;
    $mmlscriptname =~ s/\.\///;
    if ( $fileaction eq "write" ) {
        if ( -e "$mmlscriptname" ) {
            unlink "$mmlscriptname";
        }    #end if
        open FH, ">$mmlscriptname" or die $!;
    }    # end write
    if ( $fileaction eq "append" ) {
        open FH, ">>$mmlscriptname" or die $!;
    }    # end append
    print FH "#!/bin/sh\n";

    foreach $_ (@cmds) { print FH "$_\n"; }
    close(FH);
    system("chmod 744 $mmlscriptname");
    return ($mmlscriptname);
}    # end makeMMLscript
     #-----------------------------------------
	 
sub CheckMIM {
    local ($simname,$nodeCount)=@_;
    local $mimversion="ERROR-unable to determine MIM version";
    my $mim=$simname;
    $mim=~s/LTE//;
    #print "\n\nMim 1=$mim\n\n";
    if ($mim=~m/^[a-zA-Z]/) {
        $mim=~s/-.*//;
        #print "\n\nMim 2=$mim\n\n";
    }
    $mim=~s/x.*//;
    #print "\n\nMim 3=$mim\n\n";
    $mimversion=$mim;
    #print "MimVersion 1=$mimversion";
    $mimversion=~s/^\s+//;$mimversion=~s/\s+$//;
    #print "MimVersion 2=$mimversion";
	if ($simname =~ /PICO/)
    {
     $mimversion=$mimversion.'-PICO';
    }

    return($mimversion);
}# end sub CheckMIM 
########################
# END LIB MODULE
########################
