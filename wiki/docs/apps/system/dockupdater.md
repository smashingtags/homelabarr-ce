![Image of HomelabARR CE](/img/container_images/docker-dockupdate.png)

<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/1334411584927301682/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CE on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-ce/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-ce/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-ce?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-ce/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-ce?label=License&logo=mit" alt="MIT License">
    </a>
</p>

# Docker + Updater = Dockupdater

[![Release](https://img.shields.io/github/release/dockupdater/dockupdater.svg?style=flat-square)](https://hub.docker.com/r/dockupdater/dockupdater/)
[![Travis](https://img.shields.io/travis/dockupdater/dockupdater/master.svg)](https://travis-ci.org/dockupdater/dockupdater/)
[![Codecov](https://img.shields.io/codecov/c/github/dockupdater/dockupdater/master.svg)](https://codecov.io/gh/dockupdater/dockupdater)
[![Python Version](https://img.shields.io/pypi/pyversions/dockupdater.svg?style=flat-square)](https://pypi.org/project/dockupdater/)
[![Pypi Version](https://img.shields.io/pypi/v/dockupdater.svg?style=flat-square)](https://pypi.org/project/dockupdater/)
[![Latest version](https://images.microbadger.com/badges/version/dockupdater/dockupdater.svg)](https://microbadger.com/images/dockupdater/dockupdater)
[![Docker Pulls](https://img.shields.io/docker/pulls/dockupdater/dockupdater.svg?style=flat-square)](https://hub.docker.com/r/dockupdater/dockupdater/)
[![Layers](https://images.microbadger.com/badges/image/dockupdater/dockupdater.svg)](https://microbadger.com/images/dockupdater/dockupdater)

Automatically keep your docker services and your docker containers up-to-date with the latest version.

## Overview

**Dockupdater** will monitor (all or specified by a label) running docker containers and running service (in Docker swarm) and update them to the (latest or tagged) available image in the remote registry.

- Push your image to your registry and simply wait your defined interval for dockupdater to find the new image and redeploy your container autonomously.
- Notify you via many platforms courtesy of [Apprise](https://github.com/caronc/apprise)
- Use with Docker swarm to update services on the latest available version
- Limit your server SSH access
- Useful to keep 3rd party container up-to-date

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
