// wrap
module.exports = function(grunt) {
    // params
    var cfg = {
		AutoIt3Wrapper: "c:/Program Files (x86)/AutoIt3/SciTE/AutoIt3Wrapper/AutoIt3Wrapper.exe",
		UPX: "c:/Program Files (x86)/AutoIt3/Aut2Exe/upx.exe",
		ISCC: "c:/Program Files (x86)/Inno Setup 5/ISCC.exe",
		EVEOnlineVersion: "Scylla 1.0",
		version: "1.98.9",
		revision: "333"
    };
    
    // tasks
    grunt.initConfig({
        cfg: cfg,
		
		// string replace
		'string-replace': {
			// replace version in files
			version: {
				files: {
					'../Bot.au3': '../Bot.au3',
					'../../_SERVER/www/api/config.inc.php': '../../_SERVER/www/api/config.inc.php',
					'../Bot_GUI_AboutWindow.au3': '../Bot_GUI_AboutWindow.au3'
				},
				options: {
					replacements: [{
						pattern: /#AutoIt3Wrapper_Res_Fileversion=*.*.*.*/g,
						replacement: "#AutoIt3Wrapper_Res_Fileversion=<%= cfg.version %>.<%= grunt.file.read('compiled/revision.txt') %>"
					},
					{
						pattern: /#AutoIt3Wrapper_Res_ProductVersion=*.*.*.*/g,
						replacement: "#AutoIt3Wrapper_Res_ProductVersion=<%= cfg.version %>.<%= grunt.file.read('compiled/revision.txt') %>"
					},
					{
						pattern: /\$global_bot_supported_version = \d*;/g,
						replacement: "$global_bot_supported_version = "+cfg.version.replace(/\./g, '')+"<%= grunt.file.read('compiled/revision.txt') %>;"
					},
					{
						pattern: /Global \$GLB_eveOnlineVersion = "[a-zA-Z0-9. ]*"/g,
						replacement: 'Global $GLB_eveOnlineVersion = "<%= cfg.EVEOnlineVersion %>"'
					}]
				}
			},
			versionLocal: {
				files: {
					'../Bot.au3': '../Bot.au3',
					'../Bot_GUI_AboutWindow.au3': '../Bot_GUI_AboutWindow.au3'
				},
				options: {
					replacements: [{
						pattern: /#AutoIt3Wrapper_Res_Fileversion=*.*.*.*/g,
						replacement: "#AutoIt3Wrapper_Res_Fileversion=<%= cfg.version %>.<%= grunt.file.read('compiled/revision.txt') %>"
					},
					{
						pattern: /#AutoIt3Wrapper_Res_ProductVersion=*.*.*.*/g,
						replacement: "#AutoIt3Wrapper_Res_ProductVersion=<%= cfg.version %>.<%= grunt.file.read('compiled/revision.txt') %>"
					},
					{
						pattern: /Global \$GLB_eveOnlineVersion = "[a-zA-Z0-9. ]*"/g,
						replacement: 'Global $GLB_eveOnlineVersion = "<%= cfg.EVEOnlineVersion %>"'
					}]
				}
			},
			// replace M in revision and line breaks
			revision: {
				files: {
					'compiled/revision.txt': 'compiled/revision.txt',
				},
				options: {
					replacements: [{
						pattern: /(M|\r\n|\n|\r)/g,
						replacement: ''
					}]
				}
			}			
		},
		
        // shell commands
        shell: {
			wrap: {
                command: ['cd ..',
				'"<%= cfg.AutoIt3Wrapper %>" /in Bot.au3',
				'move EVEharvester_compiled.exe _build\\compiled\\EVEharvester_compiled.exe',
				'cd _build'
				].join('&&')
            },
			pack: {
                command: [
					'cd compiled',
					'"<%= cfg.UPX %>" --best -o EVEHarvester.exe EVEharvester_compiled.exe',
					'cd ..'
				].join('&&')
            },
			build: {
                command: [
					'copy ..\\conf\\EXAMPLE-config-*.ini compiled',
					'copy ..\\license\\EULA.txt compiled',
					'mkdir compiled\\utils\\speech',
					'copy ..\\utils\\speech\\*.* compiled\\utils\\speech',
					'"<%= cfg.ISCC %>" EVEharvester.iss'
				].join('&&')
            },
			cleanPreBuild: {
                command: [
					'del /Q compiled\\*.*'
				].join('&&')
            },
			cleanPostBuild: {
                command: [
					'del /Q compiled\\*.ini',
					'rmdir /S /Q compiled\\utils'
				].join('&&')
            },			
			createRevisionFile:{
                command: [
					'cd ..',
					'svn update',
					'svnversion >> _build/compiled/revision.txt',
					'cd _build'
				].join('&&')
            },	
			createRevisionFileLocal:{
                command: [
					'@echo ' + cfg.revision + ' >> compiled/revision.txt'
				].join('&&')
            }
        }
    });

    // load plugins
    grunt.loadNpmTasks('grunt-shell'); 
	grunt.loadNpmTasks('grunt-line-remover');
	grunt.loadNpmTasks('grunt-string-replace');

    // register tasks
    grunt.registerTask('default', ['release-local']);
	
	// build non-official local release
    grunt.registerTask('release-local', [
		'shell:cleanPreBuild', 
		'shell:createRevisionFileLocal',
		'string-replace:revision',
		'string-replace:versionLocal',
		'shell:wrap',
		'shell:pack',
		'shell:build',
		'shell:cleanPostBuild'
	]);
	
	// build official release
    grunt.registerTask('release', [
		'shell:cleanPreBuild', 
		'shell:createRevisionFile',
		'string-replace:revision',
		'string-replace:version',	
		'shell:wrap',
		'shell:pack',
		'shell:build',
		'shell:cleanPostBuild'
	]);	
	
	// build development version
	grunt.registerTask('dev', [
		'shell:cleanPreBuild',	
		'shell:wrap',
		'shell:pack'
	]);
	
	// test task
    grunt.registerTask('test', ['shell:build']); 
		
};