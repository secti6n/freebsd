!/bin/sh
#-
# Copyright (c) 2016 The FreeBSD Foundation
# All rights reserved.
#
# This software was developed by Björn Zeeb under
# the sponsorship from the FreeBSD Foundation.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $FreeBSD$
#

#set -x

epair_base()
{
        local ep

        ep=`ifconfig epair create`
        expr ${ep} : '\(.*\).'
}

ep=$(epair_base)
jid=`jail -i -c -n test$$ host.hostname=test$$.example.net vnet persist`

echo "Move interface in and out."
/sbin/ifconfig ${ep}b vnet ${jid}
/sbin/ifconfig ${ep}b -vnet ${jid}

#sleep 1

echo "Test just IPv4 up."
/sbin/ifconfig ${ep}b vnet ${jid}
jexec ${jid} /sbin/ifconfig ${ep}b up
jexec ${jid} /sbin/ifconfig ${ep}b inet 192.0.0.2/24 alias
#echo .
/sbin/ifconfig ${ep}b -vnet ${jid}

#sleep 1

echo "Test just IPv6 up"
/sbin/ifconfig ${ep}b vnet ${jid}
jexec ${jid} /sbin/ifconfig ${ep}b up
jexec ${jid} /sbin/ifconfig ${ep}b inet6 2001:db8::1/64 alias
jexec ${jid} /sbin/ifconfig ${ep}b inet6 -ifdisabled
#jexec ${jid} /usr/bin/netstat -rn
/sbin/ifconfig ${ep}b -vnet ${jid}
#jexec ${jid} /usr/bin/netstat -rn

#sleep 1

echo "Teardown"
jail -r ${jid}
ifconfig ${ep}a destroy

# end
