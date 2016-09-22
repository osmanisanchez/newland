import smtplib
import httplib
import socket, urllib
import re

from smtplib import SMTPException
from httplib import HTTPException

from settings import username, password, fromaddr, toaddrs


def sendmail(msg):
    ret = True
    
    subject = "[Monitor]: Newland web site failed report"
    message = """\
From: %s
To: %s
Subject: %s

%s
""" % (fromaddr, toaddrs, subject, msg)
    
    try:
        server = smtplib.SMTP('smtp.gmail.com:587')
        server.ehlo()
        server.starttls()
        server.login(username,password)
        server.sendmail(fromaddr, toaddrs, message)
    except smtplib.SMTPException as e:
        ret = False
    finally:
        server.quit()
    
    return ret

def test_sock(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ret = True
    try:
        sock.connect((host, port))
    except socket.error as e:
        ret = False
    sock.close()
    
    return ret
    
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
        status = "DOWN"
        
    return (status, response_str)

    
