#!/usr/bin/python
# compatible python 2.7.x

import shlex, subprocess
import httplib, urllib
import re

ip_reg = r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
ip_patt = re.compile(ip_reg, re.VERBOSE)

query_host = 'www.imujer.com'
my_email = 'osmanisanchez@gmail.com'
        
def query_dns_a_records(host):
    command_line  = 'dig ' + host + ' A +short'
    proc = subprocess.Popen(shlex.split(command_line), stdout=subprocess.PIPE)
    out, err = proc.communicate()
    print ('out:' + out)
    out_list = out.splitlines()
    ip_list = [ip for ip in out_list if ip_patt.match(ip)]
    
    print(ip_list)
    return ip_list

def request_site(method, ip, port, path, query):
    response_str = ""
    try:
        http_req = httplib.HTTPConnection(ip, port)
        http_req.connect()

        http_req.request(method, path + query)
        response = http_req.getresponse()
        
        if response.status == httplib.OK:
            response_str = response.read()
            
        status = response.status
        
    except Exception as e:
        status = "FAIL"
        
    return (status, response_str)


def print_output(txt):
    lines = txt.split('\n')
    for line in lines:
        print line.strip()

def main():
    ips = query_dns_a_records(query_host)
    
    for ip in ips:
        fields = {'email' : my_email, 'record' : ip}
        querystring = urllib.urlencode(fields)
        print 'Visiting webpage http://' + ip + '/test?' + querystring + ' ...'
        status,response_str  = request_site('GET', ip, 80, '/test', querystring)

        if status == httplib.OK:
            print response_str
        else:
            print 'ERROR - ' + str(status)
    
if __name__ == '__main__':
    main()  


