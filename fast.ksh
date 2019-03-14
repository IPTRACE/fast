#!/bin/ksh
#
# SCRIPT: Fast Administration Script Template (FAST)
# AUTHOR: Arkadiusz Majewski
# WEB: www.iptrace.pl
# E-MAIL: arkadiusz.majewski@iptrace.pl
# LICENCE: Simplified BSD Licence
# DATE: 2017-07-01 (1st of July 2017)
# REV: 0.0.A    (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM:     Platform independent (Unix, Unix-like, Linux)
#
# PURPOSE:      FAST is an administrative utility to improve super-users maintenance the OS (Unix, Unix-like and Linux).
#               It's intended to easily shows the system status, user's activity or even small system changes for security reason.
#######################################################################################################################################
# REV LIST:
#
#       - FAST 0.0.A
#               DATE: 2017-07-01
#               BY: Arkadiusz Majewski
#               MODIFICATIONS:
#                               1) Created script and written the description. FAST 0.0.A
#######################################################################################################################################
#
# set -n        # Uncomment to check your syntax, without execution.
#               # NOTE: Do not forget to put the comment back in or
#               #       the shell script will not execute!
# set -x        # Uncomment to debug this shell script (Korn shell only)
#

clear                                                           # Clear the screen
typeset -l log                                                  # Variables to lowercase prevents users' typos
typeset -l calendar
typeset -l time
trap 'echo "\nEXITING on a TRAPPED SIGNAL";exit' 1 2 3 15       # Uncomment to trap the signal on exit and do some cleanup things

##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
rev="0.0.D"                     # Script revison. Information for logging data
log="yes"                       # Set 'yes' for logging or 'no' to disable it
logFile="/var/log/fast.log"     # The local system path where the log file is placed

calendar="YES"                  # Set 'yes' for showing system calendar or 'no' to hide it
calendarFile="/usr/bin/cal"     # The local system path where the calendar app is placed

time="yes"                      # Set 'yes' for showing system time or 'no' to hide it

fcs="/usr/sbin/* /usr/bin/*"    # Set path directories where significant files are placed to check the hash function

##########################################################
############ OPERATING SYSTEM DEPENDENCIES ###############
##########################################################
                alias echo='echo -e'
                dist=$(uname -a | awk '{print $3}')
                processes=`expr $(ps aux | tail +2 | wc -l)`
                users=`expr $(who | wc -l)`
                conn=`expr $(netstat | grep ESTABLISHED | wc -l)`
                processor=$(sysctl hw.model | awk 'BEGIN { FS = ": |=" } ; {print $2}')
                cpuX=$(sysctl hw.ncpu | awk 'BEGIN { FS = ": |=" } ; {print $2}')
                ramFree=$(vmstat | tail -1 | awk '{print $5}')
                ramTotal=$(sysctl hw.usermem | awk 'BEGIN { FS = ": |=" } ; {print $2}'); ramTotal=`expr $ramTotal / 1024`
##########################################################
############### DEFINE FUNCTIONS HERE ####################
##########################################################

startLog ()                             # Check if log is set to 'yes' and whether a log file exists
{
        if [ $log = yes ]; then
                [ -f $logFile ] && logFileExists=yes || logFileExists=no
                if [ -f $logFile ]; then
                        echo "$(date "+%Y-%m-%d %H:%M:%S")-> Log file \"$logFile\" does exist. Will append..." >> $logFile
                        echo "$(date "+%Y-%m-%d %H:%M:%S")-> Script FAST rev. $rev started..." >> $logFile
                fi
                if [ $logFileExists = no ]; then
                        echo "Warning: log file \"$logFile\" does NOT exist. Maybe deleted... Create anyway?[y/n]: \c"; read logFileApproved
                        if [ $logFileApproved = y ]; then
                                clear
                                echo "$(date "+%Y-%m-%d %H:%M:%S")-> Warning: log file \"$logFile\" does NOT exist. Maybe deleted... Create anyway?[y/n]: y" >> $logFile
                                echo "$(date "+%Y-%m-%d %H:%M:%S")-> Script FAST rev. $rev started..." >> $logFile
                                log="yes"
                        else
                                clear
                                log="no"
                        fi
                fi
        fi
}

showCalendar ()                         # Show the calendar
{
        [ -f $calendarFile ] && logCalendar=yes || logCalendar=no
        if [[ $logCalendar = no && $log = yes ]]; then echo "$(date "+%Y-%m-%d %H:%M:%S")-> Info: calendar file \"$calendarFile\" does NOT exist. ..." >> $logFile; fi
        if [[ $logCalendar = yes && $calendar = yes ]]; then cal; fi
}

showTime ()
{
        if [ $time = yes ]; then echo "\t\t\t\t\t\t\t\t\t\t\c"; tput smso; echo "$(date "+%Y-%m-%d %H:%M")\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\n"; tput rmso; fi
}

systemInfo ()                           # Show the basic system information in the header of the FAST
{
        echo "--------------------------------------------------"
        echo " OS: $(uname) ($dist)"
        echo " Hostname: $(hostname)"
        echo " Uptime: $(uptime | awk '{print $3, $4, $5}' | tr -d ',')"
        echo " Run processes: $processes"
        echo " Logged users: $users"
        echo " Established connections: $conn"
        echo " You are logged as: $(whoami)"
        echo " CPU: $processor x$cpuX"
        echo " RAM free/total [kB]: $ramFree/$ramTotal"
        echo "--------------------------------------------------"
}

header ()                               # All loaded and run funcations at menu
{
        clear
        showTime
        showCalendar
        systemInfo
}

menu ()
{
        header
        echo "\n\n\t\t\t\tSYSTEM INFORMATION MENU (FAST rev. $rev)\n"
}
##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
# Backbone of the FAST
startLog
menu
# End of the backbone
tput rmso
clear
# End of script
