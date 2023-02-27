# Installing on Windows

## Download and install software

1. [GitHub Desktop](https://desktop.github.com/) -- Use it for checking out the code.
2. [Git for Windows](https://gitforwindows.org/) -- Bash is needed including all Linux compatibility options (check the box for replacing "find".)
3. [XAMPP](https://www.apachefriends.org/download.html) -- Make sure to include the "Perl" option during the install, all the other check marks are optional. It **must** be installed into `C:\XAMPP` to work, do not change this default setting.

## Instructions

1. Use GitHub Desktop to clone `https://github.com/FRCTeam1073-TheForceTeam/webscout.git`. By default it goes in `Documents\GitHub\webscout`, which is a fine location.
2. Open Git Bash to get a bash command line.
   1. Change to the webscout directory: `cd Documents/GitHub/webscout`
   1. Run the installation script: `./script/install.sh`
      - It will start by installing software dependencies (like Apache).
      - Then it will create a configuration file: `local.conf`.
      - See the [example configuration file](../script/example.conf) for a preview.
   1. Edit the file: `edit local.conf`
      - Most of the defaults are probably fine to start with.
      - Use the documentation comments for guidance about any setting you want to change.
      - Static IP and DHCP settings aren't supported on Windows, so don't try to enable them.
1. Run the installation script again to finish up the installation: `./script/install.sh`

## Limitations

Almost everything works on Windows with a few exceptions:

- Bot photo scouting does not work. It uses Image Magick for photo resizing and format conversion. Installation of that isn't yet in these instructions for Windows.
- CGI scripts on Windows have to start with a different first line than on Linux. Because of this, they get copied into place with that alteration. Every time you update a CGI script (or get an updated CGI script from git), you will need to re-run the installation script (or at least `./script/cgi-setup.sh`)
