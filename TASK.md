# Assignment: Intrusion Detection with Snort and Velociraptor

## Overview

In this assignment, you will set up two intrusion detection tools — Snort and Velociraptor — and use them to detect and analyse malicious activity. You will submit a combined written report including screenshots, configuration files, and analysis.

## Part 1: Snort IDS

### 1.1 Installation

Install Snort 2.9 from source on your machine or virtual machine. When configuring the build, include the following flag to enable reading from any network interface (including captured PCAP files):

``` sh
./configure --enable-non-ether-decoder
```

Document each major step of the installation process with screenshots.

### 1.2 Rule Configuration

Download and configure a publicly available ruleset (e.g., the Snort Community Rules or the registered Snort ruleset from snort.org). Configure Snort to load these rules and verify that it starts without errors. Include your `snort.conf` (or relevant sections of it) in your report.

### 1.3 Install DVWA

erable Web Application) on the same machine. Ensure it is accessible via a browser and that Snort is monitoring the relevant network interface.

### 1.4 Live Detection

Start Snort in live monitoring mode on the appropriate interface. Perform web-based attacks against DVWA, including at minimum:

* SQL Injection (SQLi)
* Cross-Site Scripting (XSS)
* Local/Remote File Inclusion (LFI/RFI)
You may use any tools or methods you prefer to carry out the attacks.

### 1.5 PCAP-Based Detection

Capture your attack traffic as a PCAP file, then replay it through Snort using the "any" interface option enabled during compilation. Verify that Snort produces the same alerts as in live mode.

### 1.6 Analysis

For each attack type, document and explain:

* Whether Snort detected the attack and what alert(s) were generated
* Why you think certain attacks were detected or missed, based on how signature-based detection works

## Part 2: Velociraptor

### 2.1 Installation

Install Instant Velociraptor using the single all-in-one binary on your virtual machine. Document the setup process with screenshots.

### 2.2 Malware Sample Analysis

You have been provided with malware samples from the previous assignment. Extract and execute each sample within the VM while Velociraptor is running.
⚠️ Execute all samples inside your VM only. Never run them on a physical host machine.

### 2.3 Detection & Forensic Analysis

Using Velociraptor's interface, investigate the results for each sample. Your analysis should include:

* Which samples were flagged as malicious
* The specific artifacts or indicators Velociraptor collected (e.g., process activity, file system changes, network connections)
* Your interpretation of what each detected sample was doing on the system