# LXC template scripts

# Building ubuntu

```bash
sudo apt update
sudo apt install debootstrap
```

If running directly on Debian Bookworm:
```bash
echo "deb http://deb.debian.org/debian bookworm-backports main" \
  > /etc/apt/sources.list.d/backports.list

apt update
apt install -y -t bookworm-backports debootstrap
```
