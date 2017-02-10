# EVE-harvester
Multifunctional bot for EVE Online

**Custom build instruction**

*Instruments*
* Autoit3 - https://www.autoitscript.com/site/autoit/
* Inno Setup 5 - http://www.jrsoftware.org/isinfo.php
* NodeJS - https://nodejs.org/
* Grunt - http://gruntjs.com/
  
Grunt modules:
* https://github.com/sindresorhus/grunt-shell
* https://github.com/davidtucker/grunt-line-remover
* https://github.com/erickrdch/grunt-string-replace
  
*Steps*
* Install instruments
* Goto "_build" folder
* Edit Gruntfile.js - > set paths in cfg variable, use version and revision from latest original file
* Run from command line "grunt release-local"
* Wait until compilation finish and use files from folder "_build/compiled"

*Videos*
https://www.youtube.com/user/eveharvestercom
