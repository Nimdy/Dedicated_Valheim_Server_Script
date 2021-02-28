<!--add later
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
-->



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script">
    <img src="https://user-images.githubusercontent.com/16698453/108028539-4f863700-702c-11eb-82b8-c40c9644da18.jpg" alt="Logo" width="300" height="250">
  </a>

  <h3 align="center">ZeroBandwidth's Original Easy Valheim Installer</h3>

  <p align="center">
    So easy a Viking can do it!
    <br />
    <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.youtube.com/watch?v=eW6Zi76Qymw">View Demo</a>   
    ·
    <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/How-to-Update-Your-Valheim-Server">How to Update your Server</a>
    .
    <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/Top-10-Reason-your-Server-is-not-working-and-how-to-fix">Top 10 Server Issue Fixes</a>
    .
    <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/issues">Report Bug</a>
    ·
    <a href="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/issues">Request Feature</a>
  </p>
</p>

Using my DigitalOcean Referral Link:
* Unsure you want a dedicated server?
* Using my code gives you 100USD credit for 60 days on DigitalOcean :smile:
* This is a great way to test your Valheim server without a commitment!
* I pay for the 40USD a month 4CPU and 8GB RAM Droplet Server
* My Referral Link https://m.do.co/c/9d2217a2725c

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#installationold">Installation Old Method</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

[![Thumbnail](https://img.youtube.com/vi/eW6Zi76Qymw/0.jpg)](https://www.youtube.com/watch?v=eW6Zi76Qymw)


* Added new EASY to use menu system for new and old users of the script - Enjoy
* This Menu will also install your Server and do many many other things! Enjoy!
* How to use: https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/How-to-use-the-Menu-Script
* Old install process works just fine. (Until Loki Kills it)

I started this to help out the community and I did not think for a moment it would have taken off so quickly.
Should you need any help troubleshooting your Valheim Server visit me on Twitch or Discord.

* My production server is 6 days solid as of 18FEB2021)
* In game time is 430+ days |* Zero issues, zero crashes, zero cases of corrupted data. 

* If you wish to Tip: https://www.patreon.com/zerobandwidth 

* Twitch Channel: https://www.twitch.tv/zerobandwidth | * Discord for Tech Support https://discord.gg/ejgQUfc




### Built With

* [BASH](https://www.gnu.org/software/bash/)
* [UBUNTU](https://ubuntu.com/)
* [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD)



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

* Cloud Hosting or Virtualization Service
  ```sh
  Digital Ocean (Highly Recommended)
  AWS
  Azure
  Google Cloud Platform
  ```
* Ubuntu Install
  ```sh
  Ubuntu 18.04 LTS 64bit and Ubuntu 20.04 LTS (tested 10 FEB 2021)
  ```
* Putty 64bit for Windows User
  ```sh
  https://www.chiark.greenend.org.uk/~sgtatham/putty/
  ```
* WinSCP 64bit for Windows User
  ```sh
  https://winscp.net/eng/download.php
  ```
### Installation

* Many have asked for it and now here it is!!!
* I can not make this any easier. 

* SSH into your newly Created VM
  ```sh
  From your home computer, connect to your Ubuntu VM via SSH
  Using putty or another terminal is recommended
  If you can connect via Putty/Terminal, then you have setup firewall rules correctly
  ```
* Minimal Requirements:
  ```sh
  2CPU and 4GB RAM
  You might be able to get it work with less but its a dice roll with any Cloud Services.  
  Also, once your world starts becoming explored and you start building stuff... You will wish you had the minimal requirements.
  Think about this like a Minecraft Server.... Your database will grow as you continue to play.
  Your need for CPU and RAM resources will continue to grow.
  ```
1. Verify GIT and Net Tools is installed
=
```sh
sudo apt-get install -y git net-tools
```
2. Change directory to OPT for installation script
=
```sh
cd /opt
```
3. Download Easy Installer from Github - Nimdy (Zero Bandwidth)
=
```sh
git clone https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git
```
4. Change directory to Dedicated_Valheim_Server_Script
=
```sh
cd Dedicated_Valheim_Server_Script/
```
5. Give the script to execution permissions
=
```sh
sudo chmod +x menu.sh
```
6. Launch the Menu System
=
```sh
sudo ./menu.sh
```
![Main Menu](https://user-images.githubusercontent.com/16698453/108992554-be513900-7699-11eb-9bc1-877f7db072e8.PNG?raw=true "Main Menu")

7. Select Option 4 - Install Valheim Server

![Valheim Server](https://user-images.githubusercontent.com/16698453/108992557-bee9cf80-7699-11eb-9659-7c67165ee408.PNG?raw=true "Install Valheim Server")

8. Confirm you want to continue with the Valheim Install

![Confirm Install](https://user-images.githubusercontent.com/16698453/108992559-bf826600-7699-11eb-947a-1f2f24dfedd9.PNG?raw=true "Confirm Valheim Server")

9. Accept Default Action on Resolv Update. 

![Accept Default](https://user-images.githubusercontent.com/16698453/108992560-c01afc80-7699-11eb-82d8-8b80c71832f5.PNG?raw=true "Accept Default")

10. Enter a Password for the newly created NONROOT local Steam account (This is not your Steam account, just a local account to run the Valheim Server)

![Steam Password](https://user-images.githubusercontent.com/16698453/108992565-c01afc80-7699-11eb-95d3-87f9c15df1de.PNG?raw=true "Password Local Steam")

11. Enter what you wish your Public Valheim Server display will be called

![Public Server Name](https://user-images.githubusercontent.com/16698453/108992566-c0b39300-7699-11eb-91ad-b085e5a0d1bc.PNG?raw=true "Public Server Name")

12. Enter your local world name. This is the name your map data files will be called and what your World is called for those who play in it.

![Map Data Name](https://user-images.githubusercontent.com/16698453/108992570-c0b39300-7699-11eb-87fd-c135bfd5b4f8.PNG?raw=true "Map Data World Name")

13. Enter the password required to connect to your server. This is required.

![Server Password](https://user-images.githubusercontent.com/16698453/108992571-c14c2980-7699-11eb-925a-fb6d5bb5ce07.PNG?raw=true "Server Password")

14. Your information is now saved for you later. A lot of people seem to forget this, so we added a little reminder. Keep this safe.

![Server Configs](https://user-images.githubusercontent.com/16698453/108992573-c1e4c000-7699-11eb-8694-270431fa48d7.PNG?raw=true "Server Configs")

15. That's it! All done! 

![Server Configs](https://user-images.githubusercontent.com/16698453/108993432-d8d7e200-769a-11eb-9a67-b8341d056d2f.PNG?raw=true "Server Configs")

16. Now configure your firewalls to allow the game to connect.
Allow ports 2456,2457,2458 (TCP/UDP) on your server This might take you a while, if you never done it before. Don't worry, members in my discord and myself can help troubleshoot later =
**(DO NOT OVER LOOK THIS STEP)**

If running in a Cloud Server, please check the WIKI for configuration steps.
* [CLICK - Port Configuration WIKI](https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/AWS-Azure-GCP-and-DigitalOcean-Valheim-Port-Configuration)
* Oh LOKI!!! Did you skip the link above? 



* For all the features of the Menu System visit:

https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/How-to-use-the-Menu-Script


* Did this help you?  Please star it!
* Do you want to add to this? Please fork it!

<!-- USAGE EXAMPLES -->
## Usage

Here is the complete walk through using DigitalOcean Services.

_For more examples, please refer to the [Documentation](https://www.youtube.com/watch?v=0YPLf7Bw5W4)_

[![Thumbnail](https://img.youtube.com/vi/eW6Zi76Qymw/0.jpg)](https://www.youtube.com/watch?v=eW6Zi76Qymw)

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/Nimdy/Dedicated_Valheim_Server_Script/issues) for a list of proposed features (and known issues).




<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingIdea`)
3. Commit your Changes (`git commit -m 'Add some AmazingIdea'`)
4. Push to the Branch (`git push origin feature/AmazingIdea`)
5. Open a Pull Request






<!-- CONTACT -->
## Contact

[@zerobandwidth](https://twitter.com/zerobandwidth) - mrzerobandwidth@gmail.com

Project Link: [https://github.com/Nimdy/Dedicated_Valheim_Server_Script](https://github.com/Nimdy/Dedicated_Valheim_Server_Script)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [GeekHead on YouTube](https://www.youtube.com/user/DesertMoose7)
* [Nicolas-Martin for Variable Assignment](https://github.com/nicolas-martin)
* [madmozg - Pointing out my Typos](https://github.com/madmozg)
* [bherbruck - Correct Profile Creation](https://github.com/bherbruck)
* [Kurt - Debugging and Testing](#)
* [LachlanMaco - Backup and Restore Functions](https://github.com/LachlanMac)
* [beko - Correct KillSignal for Valheim Server](#)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links 
[contributors-shield]: #
[contributors-url]: https://github.com/Nimdy/Dedicated_Valheim_Server_Script/graphs/contributors
[forks-shield]: #
[forks-url]: https://github.com/Nimdy/Dedicated_Valheim_Server_Script/network/members
[stars-shield]: #
[stars-url]: https://github.com/Nimdy/Dedicated_Valheim_Server_Script/stargazers
[issues-shield]: #
[issues-url]: https://github.com/Nimdy/Dedicated_Valheim_Server_Script/issues
[product-screenshot]: images/screenshot.png-->
