#!/usr/bin/python
# compatible python 2.7.x

import httplib, urllib
import re

from defs import sendmail, test_sock, request_site
from settings import host_port_dict, web_port_dict, resp_reg

resp_pat = re.compile(resp_reg, re.VERBOSE)

def main ():
    msg = ''
    are_services_up = True
    for host,port in host_port_dict.items():
        result = test_sock(host, port)
        state = ""
        if result:
            state = "OK"
        else:
            state = "FAILED"
            are_services_up = False

        print_str = "Service " + host + ":" + str(port) + " -> " + state
        msg += print_str + "\n"
        print print_str

    are_responses_ok = False
    if are_services_up:
        are_responses_ok = True

        for host,port in web_port_dict.items():
            status,response_str = request_site('GET', host, port, '/index.php', "")
            state = ""
            if status == httplib.OK and resp_pat.match(response_str.strip('\r\n')):
                state = "OK"
            else:
                state = "FAILED"
                are_responses_ok = False

            print_str = "Web page response from " + host + ":" + str(port) + "/index.php -> " + state + " with status " + str(status)
            msg += print_str + "\n"
            print print_str

    if not are_responses_ok:
        print "Sending email ..."
        ok = sendmail(msg)
        if ok:
            print "email send OK"
        else:
            print "email send FAILED"

if __name__ == '__main__':
    main()  
            