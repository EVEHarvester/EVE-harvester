# EVE-harvester
Multifunctional bot for EVE Online

**Custom build instruction**

*Instruments*
Autoit3 - https://www.autoitscript.com/site/autoit/
Inno Setup 5 - http://www.jrsoftware.org/isinfo.php
NodeJS - https://nodejs.org/
Grunt - http://gruntjs.com/
  with modules:
  https://github.com/sindresorhus/grunt-shell
  https://github.com/davidtucker/grunt-line-remover
  https://github.com/erickrdch/grunt-string-replace

*Steps*
1. Install instruments.
2. Goto "_build" folder.
3. Edit Gruntfile.js - > set paths in cfg variable, use version and revision from latest original file.
4. Run from command line "grunt release-local".
5. Wait until compilation finish and use files from folder "_build/compiled".