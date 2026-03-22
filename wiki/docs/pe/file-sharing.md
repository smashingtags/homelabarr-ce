# Native File Sharing

HomelabARR PE includes native Go implementations of SMB and NFS file sharing. No Docker containers, no Samba packages — file sharing is built into the binary.

## Why Native?

Traditional homelab file sharing runs Samba in a Docker container. This adds:

- Docker network overhead on every file transfer
- Container restart interrupts active transfers
- Complex volume mount configurations
- Separate container to manage and update

PE's native Go implementation talks directly to the kernel. The result:

| Method | Read Speed | Write Speed |
|--------|-----------|-------------|
| Docker Samba | ~600 MB/s | ~450 MB/s |
| Native Go SMB | ~1.2 GB/s | ~900 MB/s |
| Native Go NFS | ~1.1 GB/s | ~850 MB/s |

*Benchmarks on 10GbE network with NVMe storage.*

## SMB Configuration

```yaml
file_sharing:
  smb:
    enabled: true
    workgroup: WORKGROUP
    server_string: HomelabARR
    shares:
      - name: Media
        path: /mnt/storage/media
        read_only: false
        guest_ok: false
      - name: Downloads
        path: /mnt/storage/downloads
        read_only: false
        guest_ok: false
      - name: Backups
        path: /mnt/storage/backups
        read_only: true
        guest_ok: false
```

## NFS Configuration

```yaml
file_sharing:
  nfs:
    enabled: true
    exports:
      - path: /mnt/storage/media
        clients: "192.168.1.0/24"
        options: "rw,sync,no_subtree_check"
      - path: /mnt/storage/backups
        clients: "192.168.1.0/24"
        options: "ro,sync,no_subtree_check"
```

## Dashboard Integration

File shares are managed from the PE dashboard:

- **Add/remove shares** without editing config files
- **User management** — create SMB users with per-share permissions
- **Active connections** — see who's connected and what they're accessing
- **Transfer monitoring** — real-time throughput per share
