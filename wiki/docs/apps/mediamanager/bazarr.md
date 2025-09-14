![Image of HomelabARR CLI](/img/container_images/docker-bazarr.png)

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
    <a href="https://github.com/smashingtags/homelabarr-cli/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/smashingtags/homelabarr-cli?label=License&logo=gnu" alt="GNU General Public License">
    </a>
</p>

# Bazarr

A good client for finding subtitles for your stuff.

This needs to be configured from bottom up, and an anti-captcha account is recommended but not mandatory

In order to get autoscan on picking up subs you can use this under "Custom post processing"

`curl -sG -X POST -u username:password --data-urlencode "dir={{directory}}" http://autoscan:3030/triggers/manual`

Here is a [heatmap](https://wiki.bazarr.media/bazarr-stats/ "heatmap") that the devs on bazarr made. Great inspiration if you're looking into which indexers to choose

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-cli/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
