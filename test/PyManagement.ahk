#Requires AutoHotkey v2+
#SingleInstance Force

Application := { 
    Name: "Python Venv Manager", 
    Version: "0.2",
    Icon: "AHK\Icons\Py.png"
}

; Set both tray and window icon
TraySetIcon(Application.Icon)


ShowGUI() {
    mainGui := Gui(, "Python Venv Manager")
    mainGui.Add("Picture", "w32 h-1", Application.Icon)
    mainGui.MarginX := 10
    mainGui.MarginY := 10
    
    ; Environment Management Group
    mainGui.Add("GroupBox", "x10 y10 w225 h60", "Environment")
    createVenvBtn := mainGui.Add("Button", "xp+10 yp+20 w205 h30", "Create/Open Venv")
    createVenvBtn.OnEvent("Click", CreateVenv)

    ; Requirements Management Group
    mainGui.Add("GroupBox", "x10 y+10 w225 h100", "Requirements")
    createReqsBtn := mainGui.Add("Button", "xp+10 yp+20 w205 h30", "Create Requirements")
    createReqsBtn.OnEvent("Click", CreateReqs)
    updateReqsBtn := mainGui.Add("Button", "xp yp+35 w100 h30", "Update")
    updateReqsBtn.OnEvent("Click", UpdateReqs)
    installReqsBtn := mainGui.Add("Button", "x+5 yp w100 h30", "Install")
    installReqsBtn.OnEvent("Click", InstallReqs)

    ; Terminal Group
    mainGui.Add("GroupBox", "x10 y+10 w225 h60", "Terminal")
    cmdBtn := mainGui.Add("Button", "xp+10 yp+20 w205 h30", "Open Command Prompt")
    cmdBtn.OnEvent("Click", OpenCmd)

    ; Python Files Group
    mainGui.Add("GroupBox", "x10 y+10 w225 h190", "Python Files") ; Made taller to accommodate new button
    pyList := mainGui.Add("ListView", "xp+10 yp+20 w205 h120 -Hdr", ["Filename"])
    runBtn := mainGui.Add("Button", "xp yp+125 w205 h30", "Run Selected Program")
    runBtn.OnEvent("Click", RunProgram)

    ; Add list events
    pyList.OnEvent("DoubleClick", RunProgram)
    
    ; Find .py files
    Loop Files, A_WorkingDir "\*.py" {
        pyList.Add(, A_LoopFileName)
    }
    
    ; Store ListView reference globally
    global gPyList := pyList
    
    mainGui.Show()  ; Set fixed window size
}

CreateVenv(*) {
    if !FileExist("venv") {
        Run("cmd.exe /k python -m venv venv && python .\venv\Scripts\activate.bat") 
        TrayTip("Virtual environment created", , "Mute")
        return
    }else{
        Run("cmd.exe /k .\venv\Scripts\activate.bat")
        TrayTip("Virtual environment already exists", , "Mute")
    }
}

CreateReqs(*) {
    if !FileExist("requirements.txt") {
        FileAppend("
        (
import os
import re
import sys

def get_imports():
    # Package name mappings (actual import name -> pip package name)
    package_mappings = {
        'PIL': 'Pillow',  # PIL should be installed as Pillow
    }
    
    # Comprehensive standard library list
    stdlib = {
        'abc', 'aifc', 'argparse', 'array', 'ast', 'asyncio', 'atexit', 'audioop',
        'base64', 'bdb', 'binascii', 'binhex', 'bisect', 'builtins', 'bz2',
        'calendar', 'cgi', 'cgitb', 'chunk', 'cmath', 'cmd', 'code', 'codecs',
        'codeop', 'collections', 'colorsys', 'compileall', 'concurrent', 'configparser',
        'contextlib', 'contextvars', 'copy', 'copyreg', 'cProfile', 'crypt', 'csv',
        'ctypes', 'curses', 'dataclasses', 'datetime', 'dbm', 'decimal', 'difflib',
        'dis', 'distutils', 'doctest', 'email', 'encodings', 'ensurepip', 'enum',
        'errno', 'faulthandler', 'fcntl', 'filecmp', 'fileinput', 'fnmatch',
        'formatter', 'fractions', 'ftplib', 'functools', 'gc', 'getopt', 'getpass',
        'gettext', 'glob', 'grp', 'gzip', 'hashlib', 'heapq', 'hmac', 'html',
        'http', 'imaplib', 'imghdr', 'imp', 'importlib', 'inspect', 'io', 'ipaddress',
        'itertools', 'json', 'keyword', 'lib2to3', 'linecache', 'locale', 'logging',
        'lzma', 'mailbox', 'mailcap', 'marshal', 'math', 'mimetypes', 'mmap',
        'modulefinder', 'msilib', 'msvcrt', 'multiprocessing', 'netrc', 'nis',
        'nntplib', 'numbers', 'operator', 'optparse', 'os', 'ossaudiodev', 'parser',
        'pathlib', 'pdb', 'pickle', 'pickletools', 'pipes', 'pkgutil', 'platform',
        'plistlib', 'poplib', 'posix', 'pprint', 'profile', 'pstats', 'pty',
        'pwd', 'py_compile', 'pyclbr', 'pydoc', 'queue', 'quopri', 'random',
        're', 'readline', 'reprlib', 'resource', 'rlcompleter', 'runpy', 'sched',
        'secrets', 'select', 'selectors', 'shelve', 'shlex', 'shutil', 'signal',
        'site', 'smtpd', 'smtplib', 'sndhdr', 'socket', 'socketserver', 'spwd',
        'sqlite3', 'ssl', 'stat', 'statistics', 'string', 'stringprep', 'struct',
        'subprocess', 'sunau', 'symbol', 'symtable', 'sys', 'sysconfig', 'syslog',
        'tabnanny', 'tarfile', 'telnetlib', 'tempfile', 'termios', 'test', 'textwrap',
        'threading', 'time', 'timeit', 'tkinter', 'token', 'tokenize', 'trace',
        'traceback', 'tracemalloc', 'tty', 'turtle', 'types', 'typing', 'unicodedata',
        'unittest', 'urllib', 'uu', 'uuid', 'venv', 'warnings', 'wave', 'weakref',
        'webbrowser', 'winreg', 'winsound', 'wsgiref', 'xdrlib', 'xml', 'xmlrpc',
        'zipapp', 'zipfile', 'zipimport', 'zlib'
    }
    
    imports = set()
    
    for file in [f for f in os.listdir('.') if f.endswith('.py')]:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Match both 'import x' and 'from x import y'
            matches = re.findall(r'^(?:from\s+([\w\.]+).*?import|import\s+([\w\.]+))', content, re.MULTILINE)
            for m in matches:
                pkg = m[0] or m[1]
                # Get the base package name (e.g., 'PIL.Image' -> 'PIL')
                base_pkg = pkg.split('.')[0]
                if base_pkg and base_pkg not in stdlib:
                    # Use the package mapping if it exists, otherwise use the original name
                    imports.add(package_mappings.get(base_pkg, base_pkg))
    
    with open('requirements.txt', 'w') as f:
        f.write('\n'.join(sorted(imports)))

get_imports()
        )", "temp_parse_imports.py")

        ; Run the parser
        RunWait("python temp_parse_imports.py",, "Hide")
        FileDelete("temp_parse_imports.py")
        
        if FileExist("requirements.txt")
            TrayTip("Requirements file created from imports", , "Mute")
        else
            TrayTip("Failed to create requirements", , "Mute")
        return
    }
    TrayTip("Requirements file already exists", , "Mute")
}

UpdateReqs(*) {
    FileAppend("
    (
import os
import re
import sys

def update_requirements():
    # Read existing requirements
    existing_reqs = set()
    if os.path.exists('requirements.txt'):
        with open('requirements.txt', 'r') as f:
            existing_reqs = {line.strip() for line in f if line.strip()}
    
    # Comprehensive standard library list
    stdlib = {
        'abc', 'aifc', 'argparse', 'array', 'ast', 'asyncio', 'atexit', 'audioop',
        'base64', 'bdb', 'binascii', 'binhex', 'bisect', 'builtins', 'bz2',
        'calendar', 'cgi', 'cgitb', 'chunk', 'cmath', 'cmd', 'code', 'codecs',
        'codeop', 'collections', 'colorsys', 'compileall', 'concurrent', 'configparser',
        'contextlib', 'contextvars', 'copy', 'copyreg', 'cProfile', 'crypt', 'csv',
        'ctypes', 'curses', 'dataclasses', 'datetime', 'dbm', 'decimal', 'difflib',
        'dis', 'distutils', 'doctest', 'email', 'encodings', 'ensurepip', 'enum',
        'errno', 'faulthandler', 'fcntl', 'filecmp', 'fileinput', 'fnmatch',
        'formatter', 'fractions', 'ftplib', 'functools', 'gc', 'getopt', 'getpass',
        'gettext', 'glob', 'grp', 'gzip', 'hashlib', 'heapq', 'hmac', 'html',
        'http', 'imaplib', 'imghdr', 'imp', 'importlib', 'inspect', 'io', 'ipaddress',
        'itertools', 'json', 'keyword', 'lib2to3', 'linecache', 'locale', 'logging',
        'lzma', 'mailbox', 'mailcap', 'marshal', 'math', 'mimetypes', 'mmap',
        'modulefinder', 'msilib', 'msvcrt', 'multiprocessing', 'netrc', 'nis',
        'nntplib', 'numbers', 'operator', 'optparse', 'os', 'ossaudiodev', 'parser',
        'pathlib', 'pdb', 'pickle', 'pickletools', 'pipes', 'pkgutil', 'platform',
        'plistlib', 'poplib', 'posix', 'pprint', 'profile', 'pstats', 'pty',
        'pwd', 'py_compile', 'pyclbr', 'pydoc', 'queue', 'quopri', 'random',
        're', 'readline', 'reprlib', 'resource', 'rlcompleter', 'runpy', 'sched',
        'secrets', 'select', 'selectors', 'shelve', 'shlex', 'shutil', 'signal',
        'site', 'smtpd', 'smtplib', 'sndhdr', 'socket', 'socketserver', 'spwd',
        'sqlite3', 'ssl', 'stat', 'statistics', 'string', 'stringprep', 'struct',
        'subprocess', 'sunau', 'symbol', 'symtable', 'sys', 'sysconfig', 'syslog',
        'tabnanny', 'tarfile', 'telnetlib', 'tempfile', 'termios', 'test', 'textwrap',
        'threading', 'time', 'timeit', 'tkinter', 'token', 'tokenize', 'trace',
        'traceback', 'tracemalloc', 'tty', 'turtle', 'types', 'typing', 'unicodedata',
        'unittest', 'urllib', 'uu', 'uuid', 'venv', 'warnings', 'wave', 'weakref',
        'webbrowser', 'winreg', 'winsound', 'wsgiref', 'xdrlib', 'xml', 'xmlrpc',
        'zipapp', 'zipfile', 'zipimport', 'zlib'
    }
    
    new_imports = set()
    
    # Scan Python files for imports
    for file in [f for f in os.listdir('.') if f.endswith('.py')]:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
            matches = re.findall(r'^(?:from\s+([\w\.]+).*?import|import\s+([\w\.]+))', content, re.MULTILINE)
            for m in matches:
                pkg = m[0] or m[1]
                base_pkg = pkg.split('.')[0]
                if base_pkg and base_pkg not in stdlib:
                    new_imports.add(base_pkg)
    
    # Merge existing and new requirements
    all_reqs = sorted(existing_reqs | new_imports)
    
    # Write updated requirements
    with open('requirements.txt', 'w') as f:
        f.write('\n'.join(all_reqs))

update_requirements()
    )", "temp_update_reqs.py")

    ; Run the update script
    RunWait("python temp_update_reqs.py",, "Hide")
    FileDelete("temp_update_reqs.py")
    
    if FileExist("requirements.txt") {
        TrayTip("Requirements updated successfully", , "Mute")
    } else {
        TrayTip("Error updating requirements", , "Mute")
    }
}

InstallReqs(*) {
    if FileExist("requirements.txt") {
        if FileExist("venv") {
            Run("cmd.exe /k .\venv\Scripts\activate.bat && pip install -r requirements.txt")
            TrayTip("Installing requirements...", , "Mute")
        } else {
            TrayTip("Please create virtual environment first", , "Mute")
        }
    } else {
        TrayTip("No requirements.txt found", , "Mute")
    }
}

RunProgram(*) {
    ; Get selected file from ListView
    if (row := gPyList.GetNext()) {
        selectedFile := gPyList.GetText(row, 1)
        if selectedFile {
            if FileExist("venv\Scripts\") {
                Run("cmd.exe /k .\venv\Scripts\activate.bat && python " selectedFile)
            } else {
                Run("python " selectedFile)
            }
            TrayTip("Running " selectedFile, , "Mute")
        }
    } else {
        MsgBox("Please select a Python file to run")
    }
}

; Open CMD in current directory
OpenCmd(*) {
    Run("cmd.exe", A_WorkingDir)
}

ShowGUI()