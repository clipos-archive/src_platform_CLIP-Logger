# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2008-2018 ANSSI. All Rights Reserved.
package CLIP::Logger;

use 5.008008;
use strict;
use warnings;

use Sys::Syslog qw(:standard :macros :extended);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
clip_logger_init
clip_warn
clip_log
clip_debug
$g_log_debug
$g_log_prefix
$g_log_options
$g_log_syslog
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '1.00';

=head1 NAME

CLIP::Logger - Perl extension for log output in CLIP perl modules

=head1 VERSION

Version 1.00

=head1 SYNOPSIS

  use CLIP::Logger;

=head1 DESCRIPTION

CLIP::Logger gives access to a configurable interface to log messages to the standard output, syslog, 
or both. It currently supports three symbolic levels for log messages:

=over 4

=item *

C<warn>

Warning messages.

=item *

C<log>

Standard messages.

=item *

C<debug>

Debug messages. These are by default not logged at all, unless B<CLIP::Logger::$g_log_debug> 
is set to a non-null value.

=back

Each of these levels can be assigned individual syslog facilities and priorities, through the 
B<CLIP::Logger::$g_facilities> and B<CLIP::Logger::$g_priorities> hashes.


=head1 EXPORT

The following functions are exported :

=over 4

=item *

B<clip_logger_init()>

=item *

B<clip_logger_exit()>

=item *

B<clip_warn()>

=item *

B<clip_log()>

=item *

B<clip_debug()>

=item *

B<$g_log_debug>

=item *

B<$g_log_prefix>

=item *

B<$g_log_options>

=item *

B<$g_log_syslog>

=back

=cut



###############################################################
#                        Config                               #
###############################################################

=head1 Variables

CLIP::Logger can be configured through the following variables.

=over 4

=item B<CLIP::Logger::$g_facilities>

Hash matching a logging level to a syslog facility. Modifiable by
the caller, to e.g. log warnings to daemon.log and debug to user.log.
By default, all levels are logged to user.log

=cut

our $g_facilities = {
	"warn"	=>	LOG_USER,
	"log"	=>	LOG_USER,
	"debug"	=>	LOG_USER,
};

=item B<CLIP::Logger::$g_priorities>

Hash matching a logging level to a syslog priority. Modifiable by the 
caller to set her own priorities.

=cut

our $g_priorities = {
	"warn"	=>	LOG_WARNING,
	"log"	=>	LOG_INFO,
	"debug" =>	LOG_DEBUG,
};

=item B<$g_log_debug>

Boolean. Set to 1 to log 'debug' level messages. By default (0),
those are not logged.

=cut

our $g_log_debug = 0;

=item B<$g_log_prefix>

String used to prefix every log message generated by the current script.
Defaults to an empty string.

=cut 

our $g_log_prefix = "";

=item B<$g_log_options>

Syslog options. Defaults should be fine for most uses.

=cut

our $g_log_options = "nofatal,ndelay,pid";

=item B<$g_log_syslog>

Syslog use switch. Set to 1 to log all messages to syslog, or to 0 (default)
to log them to the current STDOUT. Set to 2 to log both to syslog and STDOUT.

=cut

our $g_log_syslog = 0;

=back

=cut

###############################################################
#                        Subs                                 #
###############################################################

=head1 FUNCTIONS

CLIP::Logger defines the following functions.

=over 4

=item B<clip_logger_init()>

Initialize the logging backend, by setting up syslog options and opening
the syslog socket. This is a NOP when logging to STDOUT.

=cut

sub clip_logger_init() {
	if ($g_log_syslog) {
		setlogsock("unix");
		openlog($g_log_prefix, $g_log_options, $g_facilities->{"log"});
	}
}

=item B<clip_logger_exit()>

Close the log socket, if any.

=cut

sub clip_logger_exit() {
	closelog() if ($g_log_syslog);
}

=item I<CLIP::Logger::do_log($msg, $level)> 

Internal use only. Log a message $msg at a given level $level.

=cut

sub do_log($$) {
	my ($msg, $level) = @_;
	chomp $msg;

	if ($g_log_syslog) {
		my $prio = "$g_facilities->{$level}|$g_priorities->{$level}";
		syslog($prio, $msg);
	} 
	if (not $g_log_syslog or $g_log_syslog > 1) {
		if ($level eq "warn") {
			print STDERR "$g_log_prefix"."[$$]: $msg\n";
		} else {
			print STDOUT "$g_log_prefix"."[$$]: $msg\n";
		}
	}
}

=item B<clip_warn($msg)>

Log a message $msg at the C<warn> level.

=cut

sub clip_warn($) {
	do_log(shift, "warn");
}

=item B<clip_log($msg)> 

Log a message $msg at the C<log> level.

=cut

sub clip_log($) {
	do_log(shift, "log");
}	

=item B<clip_debug($msg)> 

Log a message $msg at the C<debug> level.

=cut

sub clip_debug($) {
	do_log (shift, "debug") if ($g_log_debug);
}

1;
__END__

=head1 SEE ALSO

Sys::Syslog(3)

=head1 AUTHOR

Vincent Strubel, E<lt>clip@ssi.gouv.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 SGDN

All rights reserved.


