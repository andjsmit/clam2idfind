# clam2idfind

This script is meant to be used to copy files identified by a ClamAV DLP (Data Loss Prevention) scan as possibly having sensitive information. These files can then be mounted and then inspected with Identity Finder.

Two options are availabe:
1. Copying or Listing all files identified by a single scan.
1. Copying or Listing all new files identified between two scans.

Files will be listed unless a destination is given.

Script expects `clamscan` to include the setting `--detect-structured=yes`.
