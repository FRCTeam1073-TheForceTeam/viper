# Viper Docker Development environment

The scouting server can be run for development on pretty much any Windows, Mac, or Linux computer using Docker.

1. Install docker from [docs.docker.com/compose/install/](https://docs.docker.com/compose/install/)
1. Use git to clone the code: `git clone https://github.com/FRCTeam1073-TheForceTeam/viper.git`
1. Open a command line in the directory where you cloned the code
1. Run `./script/cgi-setup.sh`
1. Run `docker compose up`
1. Visit http://localhost:1073/
1. Make code changes.
1. Save code files.
1. Refresh web browser.

When you are done, run `docker compose down` to stop the server.

## Other documentation

 - [README](../README.md)
 - [Recommended hardware](hardware.md)
 - [Installing on Linux (Like a Raspberry Pi)](linux-install.md)
 - [Installing on Windows with XAMPP](windows-install.md)
 - [Translation and Internationalization](translation.md)
