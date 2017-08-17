# IDMAP for NFS4

I tried to use idmap to enable using different UIDs for the the same user on different laptops.

This is impossible without using Kerberos as discussed in http://thread.gmane.org/gmane.linux.nfsv4/7103/focus=7105

Here is two small commands to convert all files and directories from uid:gid 1000:1000 -> 1002:1002

    find / -uid 1000 -type f -exec chown 1002:1002 {} \;
    find / -uid 1000 -type d -exec chown 1002:1002 {} \;
