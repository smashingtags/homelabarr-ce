![Image of HomelabARR CE](/img/container_images/docker-tauticord.png)

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

# Tauticord

A Discord bot that displays live data from Tautulli

# Features

Tauticord uses the Tautulli API to pull information from Tautulli and display them in a Discord channel, including:

### Overview:

* Number of current streams
* Number of transcoding streams
* Total bandwidth
* Total LAN bandwidth
* Total remote bandwidth
* Library item counts

### For each stream:

* Stream state (playing, paused, stopped, loading)
* Media type (tv show/movie/song/photo)
* User
* Media title
* Product and player
* Quality profile
* Stream bandwidth
* If stream is transcoding
* Progress of stream
* ETA of stream completion

<img src="https://raw.githubusercontent.com/nwithan8/tauticord/master/documentation/images/embed.png">

Administrator (the bot owner) can react to Tauticord's messages to terminate a specific stream (if they have Plex Pass).

Users can also indicate what libraries they would like monitored. Tauticord will create/update a voice channel for each
library name with item counts every hour.

<img src="https://raw.githubusercontent.com/nwithan8/tauticord/master/documentation/images/libraries.png">

# Installation and setup

## Requirements

- A Plex Media Server
- Tautulli (formerly known as PlexPy)
- A Discord server
- Docker
- [A Discord bot token](https://www.digitaltrends.com/gaming/how-to-make-a-discord-bot/)
    - Permissions required:
        - Manage Channels
        - View Channels
        - Send Messages
        - Manage Messages
        - Read Message History
        - Add Reactions
        - Manage Emojis
    - **Shortcut**: Use the following link to invite your bot to your server with the above permissions:
      https://discord.com/oauth2/authorize?client_id=YOUR_APPLICATION_ID&scope=bot&permissions=1074080848
# Requirements

- A Plex Media Server
- Tautulli
- A Discord server

---

# Installation and Setup

## Setup a Discord Bot

HOW TO MAKE A DISCORD BOT: https://www.digitaltrends.com/gaming/how-to-make-a-discord-bot/

Permissions required:

- Manage Channels
- View Channels
- Send Messages
- Manage Messages
- Read Message History
- Add Reactions

## Setup Tauticord

1. Install Tauticord from Docksever Addons Menu.
2. Stop Tauticord.

    ```yaml
    sudo docker stop tauticord
    ```

3.  Download `config.yaml` to `/opt/appdata/tauticord/`

    ```yaml
    wget https://raw.githubusercontent.com/cyb3rgh05t/tauticord/master/config.yaml.example -O /opt/appdata/tauticord/config.yaml
    ```

4. Edit the config file to your needs.

    ```yaml
    nano /opt/appdata/tauticord/config.yaml
    ```

5. Start the container.

    ```yaml
    sudo docker start tauticord
    ```

Et voilà, your Bot should now be online in your Disord Server.

---

## Wiki Maintainer

[@cyb3rgh05t](https://github.com/cyb3rgh05t)

---

## Support

Kindly report any issues/broken-parts/bugs on [github](https://github.com/smashingtags/homelabarr-ce/issues) or [discord](https://discord.gg/Pc7mXX786x)

- Join our [![Discord: https://discord.gg/Pc7mXX786x](https://img.shields.io/badge/Discord-gray.svg?style=for-the-badge)](https://discord.gg/Pc7mXX786x) for Support
