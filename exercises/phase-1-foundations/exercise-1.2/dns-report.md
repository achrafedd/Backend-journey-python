1. Find their IPv4 address (A record)
```bash
$ dig google.com

; <<>> DiG 9.20.22 <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 60440
;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		220	IN	A	192.178.183.101
google.com.		220	IN	A	192.178.183.113
google.com.		220	IN	A	192.178.183.139
google.com.		220	IN	A	192.178.183.102
google.com.		220	IN	A	192.178.183.138
google.com.		220	IN	A	192.178.183.100

;; Query time: 52 msec
;; SERVER: 1.1.1.3#53(1.1.1.3) (UDP)
;; WHEN: Wed May 06 10:11:20 +01 2026
;; MSG SIZE  rcvd: 135
```
2. Find their nameservers (NS record)

```bash
$ dig google.com NS

; <<>> DiG 9.20.22 <<>> google.com NS
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24293
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.			IN	NS

;; ANSWER SECTION:
google.com.		341205	IN	NS	ns2.google.com.
google.com.		341205	IN	NS	ns3.google.com.
google.com.		341205	IN	NS	ns1.google.com.
google.com.		341205	IN	NS	ns4.google.com.

;; Query time: 58 msec
;; SERVER: 1.1.1.3#53(1.1.1.3) (UDP)
;; WHEN: Wed May 06 10:44:04 +01 2026
;; MSG SIZE  rcvd: 111
```

3. Find their mail servers (MX record)

```bash
$ dig google.com MX

; <<>> DiG 9.20.22 <<>> google.com MX
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8315
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.			IN	MX

;; ANSWER SECTION:
google.com.		120	IN	MX	10 smtp.google.com.

;; Query time: 62 msec
;; SERVER: 1.1.1.3#53(1.1.1.3) (UDP)
;; WHEN: Wed May 06 10:45:31 +01 2026
;; MSG SIZE  rcvd: 60
```
4. Use traceroute (or tracert on Windows) on one of them and count the hops

```bash
$ traceroute google.com

traceroute to google.com (142.251.20.138), 30 hops max, 60 byte packets
 1  _gateway (10.152.80.1)  3.321 ms  3.541 ms  3.306 ms
 2  172.17.0.164 (172.17.0.164)  4.308 ms  4.359 ms  3.525 ms
 3  196.200.150.193 (196.200.150.193)  5.353 ms  4.898 ms  4.782 ms
 4  192.168.105.1 (192.168.105.1)  6.062 ms  6.373 ms  6.807 ms
 5  105.73.33.160 (105.73.33.160)  9.619 ms  9.591 ms  9.564 ms
 6  172.20.10.210 (172.20.10.210)  19.882 ms  23.368 ms  23.268 ms
 7  142.250.174.134 (142.250.174.134)  23.231 ms  23.202 ms  24.272 ms
 8  108.170.252.213 (108.170.252.213)  20.787 ms 192.178.110.71 (192.178.110.71)  23.069 ms 192.178.110.85 (192.178.110.85)  23.647 ms
 9  192.178.110.148 (192.178.110.148)  23.559 ms 108.170.226.234 (108.170.226.234)  28.840 ms 192.178.110.134 (192.178.110.134)  23.403 ms
10  108.170.241.141 (108.170.241.141)  23.258 ms 108.170.241.87 (108.170.241.87)  23.588 ms 108.170.241.91 (108.170.241.91)  23.073 ms
11  172.253.76.35 (172.253.76.35)  39.656 ms  46.989 ms 172.253.76.33 (172.253.76.33)  39.501 ms
12  142.251.249.32 (142.251.249.32)  49.906 ms 172.253.66.2 (172.253.66.2)  47.376 ms 172.253.73.212 (172.253.73.212)  47.297 ms
13  209.85.255.204 (209.85.255.204)  46.521 ms 209.85.240.112 (209.85.240.112)  48.988 ms 192.178.73.110 (192.178.73.110)  61.685 ms
14  108.170.238.3 (108.170.238.3)  51.275 ms 192.178.87.233 (192.178.87.233)  50.818 ms  51.048 ms
15  142.250.228.106 (142.250.228.106)  52.999 ms 142.250.232.222 (142.250.232.222)  52.923 ms  55.847 ms
16  * * *
17  * * *
18  * * *
19  * * *
20  * * *
21  * * *
22  * * *
23  * * *
24  bx-in-f138.1e100.net (142.251.20.138)  49.258 ms  47.420 ms  47.195 ms
```

# DNS
## What is happning when you type "google.com" + enter
- when you type "google.com" + enter the browser ask the OS if the google.com IP address is cached if the IP is not cached it send a request to the DNS recursive resolver

1. DNS resolver: usaly is ISP it see if the IP address is cached on it if not it ask the root server

2. root server: the root server knows envry TLD (Top Level domane) it sends the resover to the TLD server

3. TLD server: the TLD server knows it gives the authoritative servers like (ns1.google.com)

4. authoritative servers: the autoritative servers give back the records of the destination like A record (IP v4) AAAA record (IP v6)

# Bonus: What is the difference between HTTP and HTTPS? What does the S actually do?
- Both are protocols for tansport data the differece is that HTTPS is secure with SSL/TLS certificates that encypt data before send it and have a diffrent port numbers
