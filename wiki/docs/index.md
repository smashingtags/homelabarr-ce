# **HomelabARR**

<p align="center">
    <a href="https://github.com/smashingtags/homelabarr-cli">
      <img src="img/dockservee_animated.gif" alt="Join HomelabARR community">
    </a>
</p>

----- 

<p align="center">
    </br>
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/830478558995415100/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR on Discord">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-cli/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-cli?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    </br>
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=mit" alt="MIT License">
    </a>
    </br>
    <a href="https://ko-fi.com/homelabarr">
        <img src="https://img.shields.io/badge/Ko--fi-Support%20Development-FF5E5B?logo=kofi&logoColor=white" alt="Support Development on Ko-fi">
    </a>
    </br>
</p>

_Docker + Traefik with Authelia and Cloudflare Protection_

---

## Migration

If you currently have a server with PG/MHS/PTS, have a look here before you start the installation: [Migration Guide](migration.md)

---

## Minimum Specs and Requirements

- Stable: Ubuntu 22

- CPU 2 Cores or 2 VCores (x86/x64)
    - **No** ARM Support
- 4GB Ram
- 20GB Disk Space

- A VPS/VM or Dedicated Server
- your Domain or buy a new [namecheap](https://www.namecheap.com/)
- [Cloudflare](https://dash.cloudflare.com/sign-up) account free tier

---

## For Testing

- [Hetzner Cloud](https://www.hetzner.com/de/cloud)
- [Digital Ocean](https://www.digitalocean.com/)
- [Vault](https://www.vultr.com/)

---

## Pre-Install

1. Login to your Cloudflare Account & goto DNS click on Add record.
1. Add 1 **A-Record** pointed to your server's ip.
1. Copy your [CloudFlare-Global-Key](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys) and [CloudFlare-Zone-ID](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys).

---

## Set the following on Cloudflare

1. `SSL = FULL` **( not FULL/STRICT )**
1. `Always on = YES`
1. `HTTP to HTTPS = YES`
1. `RocketLoader and Broli / Onion Routing = NO`
1. `TLS min = 1.2`
1. `TLS = v1.3`

---

### Easy Mode install

Follow our install instructions: [Install Guide](install/install.md)

---

## 📚 Documentation & Guides

### Getting Started
- **[Installation Guide](install/install.md)** - Complete setup instructions
- **[Quick Start Guide](guides/quick-start.md)** - Get up and running fast
- **[Local Mode Setup](install/local-mode.md)** - Testing and development setup

### Advanced Topics
- **[Repository Structure](guides/repository-structure.md)** - Understanding the organized codebase
- **[Contributing Guidelines](guides/contributing.md)** - How to contribute to the project
- **[Architecture Overview](guides/architecture.md)** - Technical system design

### Release Information
- **[Changelog](install/changelog.md)** - Latest updates and improvements
- **[Release Notes](releases/)** - Detailed version information
- **[YAML Standardization](releases/yaml-standardization-v2.1.md)** - Infrastructure improvements
- **[Repository Cleanup](releases/repository-cleanup-v2.2.md)** - Organization and cleanup details

---

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

**☕ [Support Development](https://ko-fi.com/homelabarr)** - Help keep HomelabARR CLI growing!

---

## Code and Permissions

```sh
Copyright 2021 @homelabarr
Code owner @homelabarr
Dev Code @homelabarr
Co-Dev -APPS- @CONTRIBUTORS-LIST
```

---

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

### Contributors

<table>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/REMOVED_USER>
            <img src=https://avatars.githubusercontent.com/u/60312740?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=REMOVED_USER/>
            <br />
            <sub style="font-size:14px"><b>REMOVED_USER</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/fscorrupt>
            <img src=https://avatars.githubusercontent.com/u/45659314?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=FSCorrupt/>
            <br />
            <sub style="font-size:14px"><b>FSCorrupt</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/drag0n141>
            <img src=https://avatars.githubusercontent.com/u/44865095?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DrAg0n141/>
            <br />
            <sub style="font-size:14px"><b>DrAg0n141</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/smashingtags>
            <img src=https://avatars.githubusercontent.com/u/48292010?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=smashingtags/>
            <br />
            <sub style="font-size:14px"><b>smashingtags</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/aelfa>
            <img src=https://avatars.githubusercontent.com/u/60222501?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Aelfa/>
            <br />
            <sub style="font-size:14px"><b>Aelfa</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/cyb3rgh05t>
            <img src=https://avatars.githubusercontent.com/u/5200101?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=cyb3rgh05t/>
            <br />
            <sub style="font-size:14px"><b>cyb3rgh05t</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/justinglock40>
            <img src=https://avatars.githubusercontent.com/u/23133649?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=justinglock40/>
            <br />
            <sub style="font-size:14px"><b>justinglock40</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/mrfret>
            <img src=https://avatars.githubusercontent.com/u/72273384?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=mrfret/>
            <br />
            <sub style="font-size:14px"><b>mrfret</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/dan3805>
            <img src=https://avatars.githubusercontent.com/u/35934387?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DoCtEuR3805 | FRENCH-QC/>
            <br />
            <sub style="font-size:14px"><b>DoCtEuR3805 | FRENCH-QC</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/brtbach>
            <img src=https://avatars.githubusercontent.com/u/24246495?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=brtbach/>
            <br />
            <sub style="font-size:14px"><b>brtbach</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/renovate-bot>
            <img src=https://avatars.githubusercontent.com/u/25180681?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Mend Renovate/>
            <br />
            <sub style="font-size:14px"><b>Mend Renovate</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ramsaytc>
            <img src=https://avatars.githubusercontent.com/u/16809662?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=ramsaytc/>
            <br />
            <sub style="font-size:14px"><b>ramsaytc</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/Shayne55434>
            <img src=https://avatars.githubusercontent.com/u/37595910?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Shayne/>
            <br />
            <sub style="font-size:14px"><b>Shayne</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/Nossersvinet>
            <img src=https://avatars.githubusercontent.com/u/83166809?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Nossersvinet/>
            <br />
            <sub style="font-size:14px"><b>Nossersvinet</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ookla-ariel-ride>
            <img src=https://avatars.githubusercontent.com/u/42082417?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Ookla, Ariel, Ride!/>
            <br />
            <sub style="font-size:14px"><b>Ookla, Ariel, Ride!</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/actions-user>
            <img src=https://avatars.githubusercontent.com/u/65916846?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=actions-user/>
            <br />
            <sub style="font-size:14px"><b>actions-user</b></sub>
        </a>
    </td>
</tr>
<tr>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/ImgBotApp>
            <img src=https://avatars.githubusercontent.com/u/31427850?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Imgbot/>
            <br />
            <sub style="font-size:14px"><b>Imgbot</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/townsmcp>
            <img src=https://avatars.githubusercontent.com/u/14061617?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=James Townsend/>
            <br />
            <sub style="font-size:14px"><b>James Townsend</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/red-daut>
            <img src=https://avatars.githubusercontent.com/u/78737369?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=Red Daut/>
            <br />
            <sub style="font-size:14px"><b>Red Daut</b></sub>
        </a>
    </td>
    <td align="center" style="word-wrap: break-word; width: 75.0; height: 75.0">
        <a href=https://github.com/DomesticWarlord>
            <img src=https://avatars.githubusercontent.com/u/57776315?v=4 width="50;"  style="border-radius:50%;align-items:center;justify-content:center;overflow:hidden;padding-top:10px" alt=DomesticWarlord/>
            <br />
            <sub style="font-size:14px"><b>DomesticWarlord</b></sub>
        </a>
    </td>
</tr>
</table>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
