# Viper Internationalization

## Improving Translations

Initial translations are performed by Google Translate. If you are a native language speaker that can improve the existing translations, please change them in the source code and make a Github pull request with your changes.

Translations are stored in JavaScript files. Text used on many pages can be found in [`main.js`](../www/main.js). Text used only on a specific page can be translated in the JavaScript file specific to that page ([`index.js`](../www/index.js) for the home page for example.)

Variables in translation strings are formatted like `_VARNAME_`.  The variable names themselves should not be translated. See [`scout.js`](../www/scout.js) for examples of variables used in translations.

## Adding a New Language

To add a new language to Viper, you would need to:

1. Add the language to the drop down menu in [`main-menu.html`](../www/main-menu.html)
1. Add translations for that language to all the JavaScript files.
1. Add translated copies for all help documentation in markdown format.
eg [`scouting-select-match-instructions.pt.md`](../www/scouting-select-match-instructions.pt.md)

Regional language flavors are supported.  For example, if there are British English spellings that should different from the existing American English spellings, add `en_gb: English (British)` as a language option. Not every translation key would need to be duplicated, only the ones that have a difference from the existing `en` translations.

If you want to use Google translate or other machine translation, there are some scripts to help. [`translations-extract.pl`](../script/translations-extract.pl) can pull the strings that need to be translated from a JavaScript file and [`translations-import.pl`](../script/translations-import.pl) can insert the machine translations back into the JavaScript file. Usage instructions are in a comment at the top of the script files.

## Other documentation

 - [README](../README.md)
 - [Recommended hardware](hardware.md)
 - [Installing on Linux (Like a Raspberry Pi)](linux-install.md)
 - [Installing on Windows with XAMPP](windows-install.md)
 - [Development Environment with Docker](docker-install.md)
