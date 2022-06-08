---
layout: post
title: "Xcode CheatSheet - 작성중"
tags: []
published: false
---
{% include JB/setup %}

## Xcode Defaults

```
alias cXed='rm -rf ~/Library/Saved\ Application\ State/com.apple.dt.Xcode.savedState && xed .'
alias clearXcode='rm -rf ~/Library/Saved\ Application\ State/com.apple.dt.Xcode.savedState'
```
https://github.com/ctreffs/xcode-defaults

## Enviroment

## Simulator

```
xcrun simctl openurl booted 'file:///Users/my.user/Desktop/my.cer'
SIM_UDID=$(xcrun simctl list devices | grep Booted | awk -F'[\(\)]' '{print $2}')
```
```
xcrun simctl erase all
```
<!-- 
DYLD_ROOT_PATH
DYLD_PATHS_ROOT
DYLD_DISABLE_PREFETCH
DYLD_PRINT_LIBRARIES_POST_LAUNCH
DYLD_NEW_LOCAL_SHARED_REGIONS
DYLD_NO_FIX_PREBINDING
DYLD_PREBIND_DEBUG
DYLD_PRINT_TO_STDERR
DYLD_PRINT_WEAK_BINDINGS
DYLD_PRINT_WARNINGS
DYLD_PRINT_CS_NOTIFICATIONS
DYLD_PRINT_INTERPOSING
DYLD_PRINT_CODE_SIGNATURES
DYLD_USE_CLOSURES
DYLD_IGNORE_PREBINDING
DYLD_SKIP_MAIN
DYLD_ROOT_PATH and DYLD_PATHS_ROOT appear to be synonyms and allow you to reset the "root" for searching for libraries/frameworks/etc. This is available on macOS/iPhoneSimulator but not iOS.

DYLD_DISABLE_PREFETCH disables the pre-fetching of the content of __DATA and __LINKEDIT segments.

DYLD_PRINT_LIBRARIES_POST_LAUNCH is the same as DYLD_PRINT_LIBRARIES but prints them right after launch has finished.

DYLD_NEW_LOCAL_SHARED_REGIONS and DYLD_NO_FIX_PREBINDING are ignored and don't do anything anymore.

DYLD_PREBIND_DEBUG prints out debug information on why prebinding was not used.

DYLD_PRINT_TO_STDERR only applies to iOS and forces output to stderr (instead of stdout) to help it show up on console logs.

DYLD_PRINT_WEAK_BINDINGS prints debug information on weak bindings.

DYLD_PRINT_WARNINGS prints a bunch of warnings (mostly regards to closures and how they are being used).

DYLD_PRINT_CS_NOTIFICATIONS prints information about the core symbolicator.

DYLD_PRINT_INTERPOSING prints details about interposes that occur.

DYLD_PRINT_CODE_SIGNATURES prints details about code signatures (specifically successes and failures).

DYLD_USE_CLOSURES is a dyld3 feature, but doesn't appear to work for anybody non-internal (need CSR_ALLOW_APPLE_INTERNAL set).

DYLD_IGNORE_PREBINDING has three values ("all", "app", "nonsplit") with nonsplit being the default if a value is not supplied.

DYLD_SKIP_MAIN is an apple only feature used for testing dyld (need CSR_ALLOW_APPLE_INTERNAL set).

export DYLD_PRINT_OPTS="1"
export DYLD_PRINT_ENV="1"
export DYLD_PRINT_LIBRARIES="1"
export DYLD_PRINT_LIBRARIES_POST_LAUNCH="1"
export DYLD_PRINT_APIS="1"
export DYLD_PRINT_BINDINGS="1"
export DYLD_PRINT_INITIALIZERS="1"
export DYLD_PRINT_REBASINGS="1"
export DYLD_PRINT_SEGMENTS="1"
export DYLD_PRINT_STATISTICS="1"
export DYLD_PRINT_DOFS="1"
export DYLD_PRINT_RPATHS="1"


DYLD_FORCE_FLAT_NAMESPACE: (insert의 경우) library의 two-level namespace를 disable. 그렇지 않으면 symbol name에도 library name이 포함.
DYLD_IGNORE_PREBINDING: performance test 를 위해 prebinding을 disable.
DYLD_IMAGE_SUFFIX: 이 suffix로 library를 search. libSystem 대신에 /usr/lib/libSystem.B_debug.dylib 또는 /usr/lib/libSystem.B_profile 을 load 하려면 일반적으로 _debug 또는 ___profile로 setting.
DYLD_INSERT_LIBRARIES: program loading시 하나 이상의 library를 강제로 insertion(UN*X의 lD_PRELOAD와 동일).
DYLD_LIBRARY_PATH: UN*X의 LD_LIBRARY_PATH 와 동일.
DYLD_FALLBACK_LIBRARY_PATH: DYLD_LIBRARY_PATH 가 시래할 때 사용.
DYLD_FRAMEWORK_PATH: DYLD_LIBRARY_PATH 와 같지만 framework 용.
DYLD_FALLBACK_FRAMEWORK_PATH: DYLD_FRAMEWORK_PATH 가 실패 할 때 사용.
dyld 의 debug printing control option은 다음과 같다.

DYLD_PRINT_APIS: dyld API call dump(i.e. dlopen).
DYLD_PRINT_BINDINGS: dump symbol binding.
DYlD_PRINT_ENV: 초기 environment variable을 dump.
DYLD_PRINT_INITIALIZERS: dump library initialization(entry point) calls.
DYLD_PRINT_LIBRARIES: library가 load될 때 표시.
DYLD_PRINT_LIBRARIES_POST_LAUNCH: load 후, dynamical하게 load된 library를 표시.
DYLD_PRINT_SEGMENTS: dump segment mapping.
DYLD_PRINT_STATISTICS: runtime statistics를 표시.


https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/LoggingDynamicLoaderEvents.html

https://opensource.apple.com/source/dyld/dyld-551.4/doc/man/man1/dyld.1.auto.html

dyld.1   [plain text]
.TH DYLD 1 "June 1, 2017" "Apple Inc."
.SH NAME
dyld \- the dynamic linker
.SH SYNOPSIS
DYLD_FRAMEWORK_PATH
.br
DYLD_FALLBACK_FRAMEWORK_PATH
.br
DYLD_VERSIONED_FRAMEWORK_PATH
.br
DYLD_LIBRARY_PATH
.br
DYLD_FALLBACK_LIBRARY_PATH
.br
DYLD_VERSIONED_LIBRARY_PATH
.br
DYLD_PRINT_TO_FILE
.br
DYLD_SHARED_REGION
.br
DYLD_INSERT_LIBRARIES
.br
DYLD_FORCE_FLAT_NAMESPACE
.br
DYLD_IMAGE_SUFFIX
.br
DYLD_PRINT_OPTS
.br
DYLD_PRINT_ENV
.br
DYLD_PRINT_LIBRARIES
.br
DYLD_BIND_AT_LAUNCH
.br
DYLD_DISABLE_DOFS
.br
DYLD_PRINT_APIS
.br
DYLD_PRINT_BINDINGS
.br
DYLD_PRINT_INITIALIZERS
.br
DYLD_PRINT_REBASINGS
.br
DYLD_PRINT_SEGMENTS
.br
DYLD_PRINT_STATISTICS
.br
DYLD_PRINT_DOFS
.br
DYLD_PRINT_RPATHS
.br
DYLD_SHARED_CACHE_DIR
.br
DYLD_SHARED_CACHE_DONT_VALIDATE
.SH DESCRIPTION
The dynamic linker checks the following environment variables during the launch
of each process.
.br
.br
Note: If System Integrity Protection is enabled, these environment variables are ignored
when executing binaries protected by System Integrity Protection.
.TP
.B DYLD_FRAMEWORK_PATH
This is a colon separated list of directories that contain frameworks.
The dynamic linker searches these directories before it searches for the
framework by its install name.
It allows you to test new versions of existing
frameworks. (A framework is a library install name that ends in the form
XXX.framework/Versions/YYY/XXX or XXX.framework/XXX, where XXX and YYY are any
name.)
.IP
For each framework that a program uses, the dynamic linker looks for the
framework in each directory in 
.SM DYLD_FRAMEWORK_PATH
in turn. If it looks in all the directories and can't find the framework, it
searches the directories in  
.SM DYLD_LIBRARY_PATH
in turn. If it still can't find the framework, it then searches 
.SM DYLD_FALLBACK_FRAMEWORK_PATH
and
.SM DYLD_FALLBACK_LIBRARY_PATH
in turn.
.IP
Use the
.B \-L
option to 
.IR otool (1).
to discover the frameworks and shared libraries that the executable
is linked against.
.TP
.B DYLD_FALLBACK_FRAMEWORK_PATH
This is a colon separated list of directories that contain frameworks.
It is used as the default location for frameworks not found in their install
path.

By default, it is set to
/Library/Frameworks:/Network/Library/Frameworks:/System/Library/Frameworks
.TP
.B DYLD_VERSIONED_FRAMEWORK_PATH
This is a colon separated list of directories that contain potential override frameworks. 
The dynamic linker searches these directories for frameworks.  For
each framework found dyld looks at its LC_ID_DYLIB and gets the current_version 
and install name.  Dyld then looks for the framework at the install name path.
Whichever has the larger current_version value will be used in the process whenever
a framework with that install name is required.  This is similar to DYLD_FRAMEWORK_PATH
except instead of always overriding, it only overrides is the supplied framework is newer.
Note: dyld does not check the framework's Info.plist to find its version.  Dyld only
checks the -currrent_version number supplied when the framework was created.
.TP
.B DYLD_LIBRARY_PATH
This is a colon separated list of directories that contain libraries. The
dynamic linker searches these directories before it searches the default
locations for libraries. It allows you to test new versions of existing
libraries. 
.IP
For each library that a program uses, the dynamic linker looks for it in each
directory in 
.SM DYLD_LIBRARY_PATH
in turn. If it still can't find the library, it then searches 
.SM DYLD_FALLBACK_FRAMEWORK_PATH
and
.SM DYLD_FALLBACK_LIBRARY_PATH
in turn.
.IP
Use the
.B \-L
option to 
.IR otool (1).
to discover the frameworks and shared libraries that the executable
is linked against.
.TP
.B DYLD_FALLBACK_LIBRARY_PATH
This is a colon separated list of directories that contain libraries.
It is used as the default location for libraries not found in their install
path.
By default, it is set
to $(HOME)/lib:/usr/local/lib:/lib:/usr/lib.
.TP
.B DYLD_VERSIONED_LIBRARY_PATH
This is a colon separated list of directories that contain potential override libraries. 
The dynamic linker searches these directories for dynamic libraries.  For
each library found dyld looks at its LC_ID_DYLIB and gets the current_version 
and install name.  Dyld then looks for the library at the install name path.
Whichever has the larger current_version value will be used in the process whenever
a dylib with that install name is required.  This is similar to DYLD_LIBRARY_PATH
except instead of always overriding, it only overrides is the supplied library is newer.
.TP
.B DYLD_PRINT_TO_FILE
This is a path to a (writable) file. Normally, the dynamic linker writes all
logging output (triggered by DYLD_PRINT_* settings) to file descriptor 2 
(which is usually stderr).  But this setting causes the dynamic linker to
write logging output to the specified file.  
.TP
.B DYLD_SHARED_REGION 
This can be "use" (the default), "avoid", or "private".  Setting it to 
"avoid" tells dyld to not use the shared cache.  All OS dylibs are loaded 
dynamically just like every other dylib.  Setting it to "private" tells
dyld to remove the shared region from the process address space and mmap()
back in a private copy of the dyld shared cache in the shared region address
range. This is only useful if the shared cache on disk has been updated 
and is different than the shared cache in use.
.TP
.B DYLD_INSERT_LIBRARIES
This is a colon separated list of dynamic libraries to load before the ones
specified in the program.  This lets you test new modules of existing dynamic
shared libraries that are used in flat-namespace images by loading a temporary
dynamic shared library with just the new modules.  Note that this has no
effect on images built a two-level namespace images using a dynamic shared
library unless
.SM DYLD_FORCE_FLAT_NAMESPACE
is also used.
.TP
.B DYLD_FORCE_FLAT_NAMESPACE
Force all images in the program to be linked as flat-namespace images and ignore
any two-level namespace bindings.  This may cause programs to fail to execute
with a multiply defined symbol error if two-level namespace images are used to
allow the images to have multiply defined symbols.
.TP
.B DYLD_IMAGE_SUFFIX
This is set to a string of a suffix to try to be used for all shared libraries
used by the program.  For libraries ending in ".dylib" the suffix is applied
just before the ".dylib".  For all other libraries the suffix is appended to the
library name.  This is useful for using conventional "_profile" and "_debug"
libraries and frameworks.
.TP
.B DYLD_PRINT_OPTS
When this is set, the dynamic linker writes to file descriptor 2 (normally
standard error) the command line options.
.TP
.B DYLD_PRINT_ENV
When this is set, the dynamic linker writes to file descriptor 2 (normally
standard error) the environment variables.
.TP
.B DYLD_PRINT_LIBRARIES
When this is set, the dynamic linker writes to file descriptor 2 (normally
standard error) the filenames of the libraries the program is using.
This is useful to make sure that the use of
.SM DYLD_LIBRARY_PATH
is getting what you want.
.TP
.B DYLD_BIND_AT_LAUNCH
When this is set, the dynamic linker binds all undefined symbols
the program needs at launch time. This includes function symbols that can are normally 
lazily bound at the time of their first call.
.TP
.B DYLD_PRINT_STATISTICS
Right before the process's main() is called, dyld prints out information about how
dyld spent its time.  Useful for analyzing launch performance.
.TP
.B DYLD_PRINT_STATISTICS_DETAILS
Right before the process's main() is called, dyld prints out detailed information about how
dyld spent its time.  Useful for analyzing launch performance.
.TP
.B DYLD_DISABLE_DOFS
Causes dyld not register dtrace static probes with the kernel.
.TP
.B DYLD_PRINT_INITIALIZERS
Causes dyld to print out a line when running each initializers in every image.  Initializers
run by dyld included constructors for C++ statically allocated objects, functions marked with
__attribute__((constructor)), and -init functions.
.TP
.B DYLD_PRINT_APIS
Causes dyld to print a line whenever a dyld API is called (e.g. NSAddImage()).
.TP
.B DYLD_PRINT_SEGMENTS
Causes dyld to print out a line containing the name and address range of each mach-o segment
that dyld maps.  In addition it prints information about if the image was from the dyld 
shared cache.
.TP
.B DYLD_PRINT_BINDINGS 
Causes dyld to print a line each time a symbolic name is bound.  
.TP
.B DYLD_PRINT_DOFS 
Causes dyld to print out information about dtrace static probes registered with the kernel. 
.TP
.B DYLD_PRINT_RPATHS
Cause dyld  to print a line each time it expands an @rpath variable and whether
that expansion was successful or not.
.TP
.B DYLD_SHARED_CACHE_DIR
This is a directory containing dyld shared cache files.  This variable can be used in
conjunction with DYLD_SHARED_REGION=private and DYLD_SHARED_CACHE_DONT_VALIDATE
to run a process with an alternate shared cache.
.TP
.B DYLD_SHARED_CACHE_DONT_VALIDATE
Causes dyld to not check that the inode and mod-time of files in the shared cache match
the requested dylib on disk. Thus a program can be made to run with the dylib in the
shared cache even though the real dylib has been updated on disk.
.TP
.SH DYNAMIC LIBRARY LOADING
Unlike many other operating systems, Darwin does not locate dependent dynamic libraries
via their leaf file name.  Instead the full path to each dylib is used (e.g. /usr/lib/libSystem.B.dylib).
But there are times when a full path is not appropriate; for instance, may want your
binaries to be installable in anywhere on the disk.
To support that, there are three @xxx/ variables that can be used as a path prefix.  At runtime dyld
substitutes a dynamically generated path for the @xxx/ prefix.
.TP
.B @executable_path/
This variable is replaced with the path to the directory containing the main executable for 
the process.  This is useful for loading dylibs/frameworks embedded in a .app directory. 
If the main executable file is at /some/path/My.app/Contents/MacOS/My and a framework dylib 
file is at /some/path/My.app/Contents/Frameworks/Foo.framework/Versions/A/Foo, then 
the framework load path could be encoded as 
@executable_path/../Frameworks/Foo.framework/Versions/A/Foo and the .app directory could be
moved around in the file system and dyld will still be able to load the embedded framework.
.TP
.B @loader_path/
This variable is replaced with the path to the directory containing the mach-o binary which
contains the load command using @loader_path. Thus, in every binary, @loader_path resolves to
a different path, whereas @executable_path always resolves to the same path. @loader_path is
useful as the load path for a framework/dylib embedded in a plug-in, if the final file 
system location of the plugin-in unknown (so absolute paths cannot be used) or if the plug-in 
is used by multiple applications (so @executable_path cannot be used). If the plug-in mach-o
file is at /some/path/Myfilter.plugin/Contents/MacOS/Myfilter and a framework dylib 
file is at /some/path/Myfilter.plugin/Contents/Frameworks/Foo.framework/Versions/A/Foo, then 
the framework load path could be encoded as 
@loader_path/../Frameworks/Foo.framework/Versions/A/Foo and the Myfilter.plugin directory could 
be moved around in the file system and dyld will still be able to load the embedded framework.
.TP
.B @rpath/
Dyld maintains a current stack of paths called the run path list.  When @rpath is encountered
it is substituted with each path in the run path list until a loadable dylib if found.  
The run path stack is built from the LC_RPATH load commands in the depencency chain
that lead to the current dylib load.
You can add an LC_RPATH load command to an image with the -rpath option to ld(1).  You can
even add a LC_RPATH load command path that starts with @loader_path/, and it will push a path
on the run path stack that relative to the image containing the LC_RPATH.  
The use of @rpath is most useful when you have a complex directory structure of programs and
dylibs which can be installed anywhere, but keep their relative positions.  This scenario
could be implemented using @loader_path, but every client of a dylib could need a different 
load path because its relative position in the file system is different. The use of @rpath
introduces a level of indirection that simplies things.  You pick a location in your directory
structure as an anchor point.  Each dylib then gets an install path that starts with @rpath 
and is the path to the dylib relative to the anchor point. Each main executable is linked
with -rpath @loader_path/zzz, where zzz is the path from the executable to the anchor point.
At runtime dyld sets it run path to be the anchor point, then each dylib is found relative
to the anchor point.  
.SH "SEE ALSO"
dyldinfo(1), ld(1), otool(1)

 -->
