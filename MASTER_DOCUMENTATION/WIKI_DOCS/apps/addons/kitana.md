![Image of HomelabARR CLI](/img/container_images/docker-homelabarr-cli.png)

<p align="left">
    <a href="https://discord.gg/Pc7mXX786x">
        <img src="https://discord.com/api/guilds/830478558995415100/widget.png?label=Discord%20Server&logo=discord" alt="Join HomelabARR CLI on Discord">
    </a>
        <a href="https://github.com/smashingtags/homelabarr-cli/releases">
        <img src="https://img.shields.io/github/downloads/smashingtags/homelabarr-cli/total?label=Total%20Downloads&logo=github" alt="Total Releases Downloaded from GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/releases/latest">
        <img src="https://img.shields.io/github/v/release/smashingtags/homelabarr-cli?include_prereleases&label=Latest%20Release&logo=github" alt="Latest Official Release on GitHub">
    </a>
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# Kitana

[![](https://img.shields.io/github/release/pannal/Kitana.svg?style=flat&label=current)](https://github.com/pannal/Kitana/releases/latest) [![Maintenance](https://img.shields.io/maintenance/yes/2021.svg)]() [![Slack Status](https://szslack.fragstore.net/badge.svg)](https://szslack.fragstore.net) [![master](https://img.shields.io/badge/master-stable-green.svg?maxAge=2592000)]()

A responsive Plex plugin web frontend

## Introduction

#### What is Kitana?

Kitana exposes your Plex plugin interfaces "to the outside world". It does that by authenticating against Plex.TV, then connecting to the Plex Media Server you tell it to, and essentially proxying the plugin UI.
It has full PMS connection awareness and allows you to connect locally, remotely, or even via relay.

It does that in a responsive way, so your Plugins are easily managable from your mobile phones for example, as well.

**_Running one instance of Kitana can serve infinite amounts of servers and plugins_** - you can even expose your Kitana instance to your friends, so they can manage their plugins as well, so they don't have to run their own Kitana instance.

Kitana was built for [Sub-Zero](https://github.com/pannal/Sub-Zero.bundle) originally, but handles other plugins just as well.

#### Isn't that a security concern?

Not at all. Without a valid Plex.TV authentication, Kitana can do nothing. All authentication data is stored serverside inside the current user's session storage (which is long running), so unwanted third party access to your server is virtually impossible.

#### The Plex plugin UIs still suck, though!

Yes, they do. Kitana does little to improve that, besides adding responsiveness to the whole situation.

Also, it isn't designed to. Kitana is an intermediate solution to the recent problem posed by Plex Inc. and their plans to phase out all UI-based plugins from the Plex Media Server environment.

## Features

- small footprint by using the CherryPy framework
- heavy caching for faster plugin handling
- full PMS connection awareness and automatic fallback in case the configured connection is lost
- fully responsive (CSS3)
- made to run behind reverse proxies (it doesn't provide its own HTTPS interface)
- fully cross-platform

## Screenshots

[Imgur Gallery](https://imgur.com/a/ovzXdjt)

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
