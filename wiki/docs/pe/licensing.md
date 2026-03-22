# Licensing & Pricing

HomelabARR PE is commercial software with lifetime licensing. Pay once, use forever, updates included.

## Editions

| | Community Edition | Professional Edition |
|---|---|---|
| **Price** | Free (MIT License) | From $39 lifetime |
| **Container management** | Yes | Yes |
| **App templates** | 137+ | 137+ |
| **Traefik/Authelia** | Yes | Yes |
| **Web dashboard** | No | Yes |
| **Storage management** | No | Yes |
| **Native file sharing** | No | Yes |
| **Single binary** | No | Yes |
| **Source code** | Open source | Proprietary |
| **Support** | Community | Priority |

## Pricing Tiers

| Tier | Price | Includes |
|------|-------|----------|
| **Starter** | $39 | PE binary, dashboard, container management |
| **Storage** | $79 | Everything in Starter + SnapRAID, MergerFS, Cache Mover |
| **Complete** | $149 | Everything + native file sharing, priority support |

All tiers include lifetime updates and access to the PE dashboard.

## Purchase

Visit [homelabarr.com](https://homelabarr.com) to purchase a license.

## Activation

After purchase, you receive a license key via email. Activate during first run:

```bash
./homelabarr --license YOUR-LICENSE-KEY
```

Or activate from the dashboard under Settings > License.

## CE to PE Migration

Already running HomelabARR CE? PE reads your existing Docker configurations. Your containers, networks, and volumes carry over — PE just adds the dashboard, storage management, and native file sharing on top.

```bash
# Stop CE
sudo systemctl stop homelabarr-ce

# Install PE
wget https://releases.homelabarr.com/latest/homelabarr
chmod +x homelabarr
./homelabarr --license YOUR-LICENSE-KEY

# PE detects existing containers automatically
```
