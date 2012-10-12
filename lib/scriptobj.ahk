/*
 * =============================================================================================== *
 * Author           : RaptorX   <graptorx@gmail.com>
 * Script Name      : Script Object
 * Script Version   : 1.0
 * Homepage         : 
 *
 * Creation Date    : September 03, 2011
 * Modification Date: October 05, 2012
 *
 * Description      :
 * ------------------
 * This is an object used to have a few common functions between scripts
 * Those are functions related to script information 
 *
 * -----------------------------------------------------------------------------------------------
 * License          :       Copyright ©2010-2012 RaptorX <GPLv3>
 *
 *          This program is free software: you can redistribute it and/or modify
 *          it under the terms of the GNU General Public License as published by
 *          the Free Software Foundation, either version 3 of  the  License,  or
 *          (at your option) any later version.
 *
 *          This program is distributed in the hope that it will be useful,
 *          but WITHOUT ANY WARRANTY; without even the implied warranty  of
 *          MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the
 *          GNU General Public License for more details.
 *
 *          You should have received a copy of the GNU General Public License
 *          along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * -----------------------------------------------------------------------------------------------
 *                                          Script Object
 * =============================================================================================== *
 */
 
;[General Variables]{
; Make SuperGlobal variables
global unused:=0, null:="",sec:=1000,min:=60*sec,hour:=60*min
;}

class scriptobj
{
    name        := ""
    version     := ""
    author      := ""
    email       := ""
    homepage    := ""
    crtdate     := ""
    moddate     := ""
    conf        := ""
    debugging   := false
    
    getparams(){
        global
        ; First we organize the parameters by priority [-sd, then -d , then everything else]
        ; I want to make sure that if i select to save a debug file, the debugging will be ON
        ; since the beginning because i use the debugging inside the next parameter checks as well.
        Loop, %0%
            param .= %a_index% .  a_space           ; param will contain the whole list of parameters

        if (InStr(param, "-h") || InStr(param, "--help")
        ||  InStr(param, "-?") || InStr(param, "/?")){
            script.debug ? script.debug("* ExitApp [0]", 2)
            Msgbox, 0x40
                  , % "Accepted Parameters"
                  , % "The script accepts the following parameters:`n`n"
                    . "-h    --help`tOpens this dialog.`n"
                    . "-v    --version`tOpens a dialog containing the current script version.`n"
                    . "-d    --debug`tStarts the script with debug ON.`n"
                    . "-sd  --save-debug`tStarts the script with debug ON but saves the info on the `n"
                    . "`t`tspecified txt file.`n"
                    . "-sc  --source-code`tSaves a copy of the source code on the specified dir, specially `n"
                    . "`t`tuseful when the script is compiled and you want to see the source code."
            ExitApp
        }
        if (InStr(param, "-v") || InStr(param, "--version")){
            script.debug ? script.debug("* ExitApp [0]", 2)
            Msgbox, 0x40
                  , % "Version"
                  , % "Author: " script.author " <" script.email ">`n" "Version: " script.name " v" script.version "`t"
            ExitApp
        }
        if (InStr(param, "-d")
        ||  InStr(param, "--debug")){
            sparam := "-d "                         ; replace sparam with -d at the beginning.
        }
        if (InStr(param, "-sd")
        ||  InStr(param, "--save-debug")){
            RegexMatch(param,"-sd\s(\w+\.\w+)", df) ; replace sparam with -sd at the beginning
            sparam := "-sd " df1  a_space           ; also save the output file name next to it
        }
        Loop, Parse, param, %a_space%
        {
            if (a_loopfield = "-d" || a_loopfield = "-sd"
            ||  InStr(a_loopfield, ".txt")){        ; we already have those, so we just add the
                continue                            ; other parameters
            }
            sparam .= a_loopfield . a_space
        }
        sparam := RegexReplace(sparam, "\s+$")      ; Remove trailing spaces. Organizing is done

        Loop, Parse, sparam, %a_space%
        {
            if (sdebug && !debugfile && (!a_loopfield || !InStr(a_loopfield,".txt")
            || InStr(a_loopfield,"-"))){
                script.debug ? script.debug("* Error, debug file name not specified. ExitApp [1]", 2)
                Msgbox, 0x10
                      , % "Error"
                      , % "You must provide a name to a txt file to save the debug output.`n`n"
                        . "usage: " a_scriptname " -sd file.txt"
                ExitApp
            }
            else if (sdebug){
                debugfile ? :debugfile := a_loopfield
                script.debug ? script.debug("")
            }
            if (a_loopfield = "-d"
            ||  a_loopfield = "--debug"){
                debug := True, sdebug := False
                script.debug ? script.debug("* " script.name " Debug ON`n* " script.name " [Start]`n* getparams() [Start]", 1)
            }
            if (a_loopfield = "-sd"
            ||  a_loopfield = "--save-debug"){
                sdebug := True, debug := True
            }
            if (a_loopfield = "-sc"
            ||  a_loopfield = "--source-code"){
                sc := True
                script.debug ? script.debug("* Copying source code")
                FileSelectFile, instloc, S16, source_%a_scriptname%
                              , % "Save source file to..."
                              , % "AutoHotkey Script (*.ahk)"
                if (!instloc){
                    script.debug ? script.debug("* Canceled. ExitApp [1]", 2)
                    ExitApp
                }
                FileInstall,AHK-ToolKit.ahk, %instloc%
                if (!ErrorLevel){
                    script.debug ? script.debug("* Source code successfully copied")
                    MsgBox, 0x40
                          , % "Source code copied"
                          , % "The source code was successfully copied"
                          , 10 ; 10s timeout
                }
                else
                {
                    script.debug ? script.debug("* Error while copying the source code")
                    Msgbox, 0x10
                          , % "Error while copying"
                          , % "There was an error while copying the source code.`nPlease check that "
                            . "the file is not already present in the current directory and that "
                            . "you have write permissions on the current folder."
                    ExitApp
                }
            }
        }
        script.debug ? : script.debug("* " script.name " Debug OFF")
        if (sdebug && !debugfile){                      ; needed in case -sd is the only parameter given
            script.debug ? script.debug("* Error, debug file name not specified. ExitApp [1]", 2)
            Msgbox, 0x10
                  , % "Error"
                  , % "You must provide a name to a txt file to save the debug output.`n`n"
                    . "usage: " a_scriptname " -sd file.txt"
            ExitApp
        }
        if (sc = True){
            script.debug ? script.debug("* ExitApp [0]", 2)
            ExitApp
        }
        script.debug ? script.debug("* getparams() [End]")
        return
        }
    update(lversion, rfile="github", logurl="", vline=1){
        ; global script, conf, debug

        script.debug ? script.debug("* update() [Start]", 1), node := conf.selectSingleNode("/" script.name "/@version")
        if  node.text != script.version
        {
            node.text := script.version
            conf.save(script.conf), conf.load(script.conf), node:=root:=options:=null             ; Save & Clean
        }
        
        if a_thismenuitem = Check for Updates
            Progress, 50,,, % "Updating..."

        logurl := rfile = "github" ? "https://raw.github.com/" script.author
                                   . "/" script.name "/ver/ver" : logurl

        RunWait %ComSpec% /c "Ping -n 1 google.com" ,, Hide  ; Check if we are connected to the internet
        if connected := !ErrorLevel
        {
            script.debug ? script.debug("* Downloading log file")

            if a_thismenuitem = Check for Updates
                Progress, 90

            UrlDownloadToFile, %logurl%, %a_temp%\logurl
            FileReadLine, logurl, %a_temp%\logurl, %vline%
            script.debug ? script.debug("* Version: " logurl)
            RegexMatch(logurl, "v(.*)", Version)
            rfile := rfile = "github" ? ("https://www.github.com/"  
                                      . script.author "/" 
                                      . script.name "/zipball/" (a_iscompiled ? "latest-compiled" : "latest"))
                                      : rfile
            script.debug ? script.debug("* Local Version: " lversion " Remote Version: " Version1)
            
            if (Version1 > lversion){
                Progress, Off
                script.debug ? script.debug("* There is a new update available")
                Msgbox, 0x40044
                      , % "New Update Available"
                      , % "There is a new update available for this application.`n"
                        . "Do you wish to upgrade to " Version "?"
                      , 10 ; 10s timeout
                IfMsgbox, Timeout
                {
                    script.debug ? script.debug("* Update message timed out", 3)
                    return 1
                }
                IfMsgbox, No
                {
                    script.debug ? script.debug("* Update aborted by user", 3)
                    return 2
                }
                script.debug ? script.debug("* Downloading file to: " a_temp "/" script.name ".zip")
                Download(rfile, a_temp "/" script.name ".zip")
                oShell := ComObjCreate("Shell.Application")
                oDir := oShell.NameSpace(a_temp), oZip := oShell.NameSpace(a_temp "/" script.name ".zip")
                oDir.CopyHere(oZip.Items), oShell := oDir := oZip := null
                
                ; FileCopy instead of FileMove so that file permissions are inherited correctly.
                Loop, % a_temp "/" script.author "*", 1
                    FileCopyDir, %a_loopfilefullpath%, %a_scriptdir%, 1
                
                FileDelete, % a_temp "/" script.name ".zip"
                FileDelete, % a_temp "/" script.author "*"
                
                Msgbox, 0x40040
                      , % "Installation Complete"
                      , % "The application will now restart."
                
                Reload
            }
            else if (a_thismenuitem = "Check for Updates")
            {
                Progress, Off
                script.debug ? (script.debug("* Script is up to date"), script.debug("* update() [End]", 2))
                Msgbox, 0x40040
                      , % "Script is up to date"
                      , % "You are using the latest version of this script.`n"
                        . "Current version is v" lversion
                      , 10 ; 10s timeout

                IfMsgbox, Timeout
                {
                    script.debug ? script.debug("* Update message timed out", 3)
                    return 1
                }
                return 0
            }
            else
            {
                script.debug ? (script.debug("* Script is up to date"), script.debug("* update() [End]", 2))
                return 0
            }
        }
        else
        {
            Progress, Off
            script.debug ? (script.debug("* Connection Failed", 3), script.debug("* update() [End]", 2))
            return 3
        }
    }
    splash(img=""){
        global

        Gui, 99: -Caption +LastFound +Border +AlwaysOnTop +Owner
        $hwnd := WinExist()
        WinSet, Transparent, 0

        Gui, 99: add, Picture, x0 y0, % img
        Gui, 99: show, w500 h200 NoActivate

        Loop, 255
        {
            alpha += 1
            WinSet, Transparent, %alpha%
        }

        Sleep, 2.5*sec

        Loop, 255
        {
            alpha--
            WinSet, Transparent, %alpha%
        }

        Gui, 99: destroy
        return
    }
    autostart(status){
        if status
        {
            RegWrite, REG_SZ, HKCU
                            , Software\Microsoft\Windows\CurrentVersion\Run
                            , % this.name
                            , %a_scriptfullpath%
        }
        else
        {
            RegDelete, HKCU
                     , Software\Microsoft\Windows\CurrentVersion\Run
                     , % this.name
        }
    }
    debug(msg,delimiter = false){
    global debugfile, sdebug, script
    static ft := True   ; First time

    t := delimiter = 1 ? msg := "* ------------------------------------------`n" msg
    t := delimiter = 2 ? msg := msg "`n* ------------------------------------------"
    t := delimiter = 3 ? msg := "* ------------------------------------------`n" msg
                             .  "`n* ------------------------------------------"
    if (!debugfile){
        sdebug && ft ? (msg := "* ------------------------------------------`n"
                            .  "* " script.name " Debug ON`n* " script.name "[Start]`n"
                            .  "* getparams() [Start]`n" msg, ft := 0)
        OutputDebug, %msg%
    }
    else if (debugfile){
        ft ? (msg .= "* ------------------------------------------`n"
                  .  "* " script.name " Debug ON`n* " script.name
                  .  " [Start]`n* getparams() [Start]", ft := 0)
        FileAppend, %msg%`n, %debugfile%
    }
}
}

; Based on code by Sean and SKAN @ http://www.autohotkey.com/forum/viewtopic.php?p=184468#184468
Download(url, file)
{
    global _cu
    static vt
    SplitPath file, dFile
    x:=(a_screenwidth/2)-(330/2), y:=(a_screenheight/2)-(52/2), VarSetCapacity(_cu, 100), VarSetCapacity(tn, 520)
    
    if !VarSetCapacity(vt)
    {
        VarSetCapacity(vt, A_PtrSize*11), nPar := "31132253353"
        Loop Parse, nPar
            NumPut(RegisterCallback("DL_Progress", "F", A_LoopField, A_Index-1), vt, A_PtrSize*(A_Index-1))
    }

    DllCall("shlwapi\PathCompactPathEx", "str", _cu, "str", url, "uint", 50, "uint", 0)
    Progress, Hide CWE0E0E0 CT000020 CB1111DD x%x% y%y% w330 h52 B1 FM8 FS8 WM700 WS700 ZH12 ZY3 C11,, %_cu%, % script.name, Tahoma
    
    if (0 = DllCall("urlmon\URLDownloadToCacheFile", "ptr", 0, "str", url, "str", tn, "uint", 260, "uint", 0x10, "ptr*", &vt))
        FileCopy %tn%, %file%
    else
        ErrorLevel := 1
    Progress Off
    return !ErrorLevel
}
DL_Progress( pthis, nP=0, nPMax=0, nSC=0, pST=0 )
{
    global _cu
    if A_EventInfo = 6
    {
        Progress Show
        Progress % P := 100*nP//nPMax, % "Downloading:     " Round(np/1024,1) " KB / " Round(npmax/1024) " KB    [ " P "`% ]", %_cu%
    }
    return 0
}