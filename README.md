Sonic Coin (ticker symbol SSD) Release

Sonic Coin provides a complete anonymity solution for cryptocurrencies. It combines the network analysis resistance of Tor with the blockchain analysis resistance of stealth send. Sonic Screwdriver has a fair distribution with nearly four hours of low reward blocks, a small premine of 1%, and the long-term energy efficiency of proof-of-stake minting.

This wallet supports the stake=0 option in the SonicScrewdriver.conf file to disable the stake miner thread for pool and exchange operators.


Money supply
============

Algorithm: SHA-256d
Premine: 0
First Subsidy 8,000 SSD
Halving every 1440 blocks (about 1 day)
Last PoW block: 20,420
Total PoW Money: 23,037,120 SSD
PoS Interest: 20%

Ports
=====
P2P: 4450
Test P2P: 4451
RPC: 46512
Test RPC: 46513

Application
===========

Daemon Name: Sonicd
Conf File (Case Sensitive): SonicScrewdriver.conf
Addresses: Start with "s"

Application Directories
=======================

Windows < Vista: C:\Documents and Settings\Username\Application Data\SonicScrewdriver
Windows >= Vista: C:\Users\Username\AppData\Roaming\SonicScrewdriver
Mac: ~/Library/Application Support/SonicScrewdriver
Unix: ~/.SonicScrewdriver

Abnormal Dependencies
=====================
Most daemons and qt's use the same dependencies, SSD is different in so much as it uses TOR, and this requires libevent. you can either build with mingw for windows, make/make install with linux, apt-get install libevent-dev with ubuntu or build from source with OSX.
   


