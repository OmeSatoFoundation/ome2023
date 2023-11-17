# JuliusMisc
## Subdirectory Explanation
JuliusMisc contains interfaces, wrappers and configurations for lecture students to use julius.
The aim of this subdirectory is to provide required files to provide default configuration, default tools and default starup scripts.
These files would encupslate complex interface of julius (e.g. command line arguments, strict rules of configuration file format) from lecture students.
The contents in this subdirectory should not include files from the original Dictationkit repositry.
`convert_yomi.sh`, for example, take reading newline which breaks a format rule of `.yomi` files off the lecture students who use leafpad (or mousepad). Leafpad (or mousepad) automatically appends the leading newline.

JuliusMisc should contain

- julius wrapper, expected to be called from shell.
- another julius wrapper, expected to be called from HSP.
- tool that relaxes the strict rules of `.yomi` files.
- default configuration, read by the julius wrappers.
- install scripts

JuliusMisc should exclude

- phonetic model, which should be installed from the Dictationkit repository.

## TODO
Data files (default.jconf) should be under $(datadir) such as `/usr/local/share/`.
The hardcoded pathes that refers `default.jconf` and phonetic model files in `julius.sh`, `julius_daemon.sh` etc. and `default.jconf` etc. must be `sed`-ed in install scripts.

The current workaround is to put all data files into subdirectories of $(bindir) such as `/usr/local/bin/`.
