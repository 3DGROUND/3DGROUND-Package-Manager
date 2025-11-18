/*  
[INFO] 
NAME=Package Manager
VERSION=1.0.0
AUTHOR=MastaMan
DEV=https://3dground.net
HELP=
CLIENT=3DGROUND

[PACKAGES]
Prune Scene=
Model Packer=
CopyTo PRO=
Telegram Notifications=
Stock Model Fixer=
Paste Ref Image=
Window Placer=

[Prune Scene]
DESCRIPTION=With Prune Scene you can clear your 3Ds Max scene from scripted viruses and accumulated garbage. This allows in some cases to greatly reduce the size and accelerate saving of scene.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/Prune-Scene/master/PruneScene.mzp
API=https://raw.githubusercontent.com/3DGROUND/Prune-Scene/gh-pages/update.ini
DIR=PruneScene
QUAD=false

[Model Packer]
DESCRIPTION=With the Model Packer, you can prepare your 3D models for uploading to 3D stocks or Asset Libraries. Just a couple of clicks and you will create an archive with your model or scene.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/Model-Packer/master/ModelPacker.mzp
API=https://raw.githubusercontent.com/3DGROUND/Model-Packer/gh-pages/update.ini
DIR=ModelPacker
QUAD=false

[CopyTo PRO]
DESCRIPTION=With CopyTo PRO script you can copy objects and paste them into the current scene or between open windows 3Ds Max.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/CopyTo-Pro/main/CopyToPro.mzp
API=https://raw.githubusercontent.com/3DGROUND/CopyTo-Pro/gh-pages/update.ini
DIR=CopyToPro
QUAD=true

[Telegram Notifications]
DESCRIPTION=A script for 3Ds Max that allows you to send messages to Telegram using a special bot. It is possible to send a message about the completion of the rendering process with sending the rendered image.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/telegram-notifications/master/TelegramNotifications.mzp
API=https://raw.githubusercontent.com/3DGROUND/telegram-notifications/gh-pages/update.ini
DIR=TelegramNotifications
QUAD=false

[Stock Model Fixer]
DESCRIPTION=With this script you can quick prepare model, downloaded from 3D stocks, before merge into your main scene.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/Stock-Model-Fixer/master/StockModelFixer.mzp
API=https://raw.githubusercontent.com/3DGROUND/Stock-Model-Fixer/gh-pages/update.ini
DIR=StockModelFixer
QUAD=false

[Paste Ref Image]
DESCRIPTION=With Paste RefImage you can quickly create a Plane with a picture copied to the clipboard.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/Paste-Ref-Image/master/PasteRefImage.mzp
API=https://raw.githubusercontent.com/3DGROUND/Paste-Ref-Image/gh-pages/update.ini
DIR=PasteRefImage
QUAD=true

[Window Placer]
DESCRIPTION=This script is used for quick placement of windows in 3Ds Max scene.Before using the script requires preset the windows.
PACKAGE=https://raw.githubusercontent.com/3DGROUND/Window-Placer/master/WindowPlacer.mzp
API=https://raw.githubusercontent.com/3DGROUND/Window-Placer/gh-pages/update.ini
DIR=WindowPlacer
QUAD=false

[ABOUT]
A script that automatically downloads the latest 3DGROUND updates and performs a silent installation of all scripts without any user interaction.=

[1.0.0]
* Initial release =

[SCRIPT]
*/

global SILENT_INSTALLATION = true
try(closeRolloutFloater floaterSilentInstallation) catch()
global floaterSilentInstallation = newRolloutFloater "3DGROUND Packages" 300 510


try (DestroyDialog rSilentInstall) catch ()
rollout _rSilentInstall "" category: 1 (
	group "3DGROUND Packages" (
		multilistbox lbxPackages "" 
		button btnSelectAll "Select All" width: 100 across: 2
		button btnDeselectAll "Deselect All" width: 100		
		
		button btnViewInfo "View Info" width: 100 across: 2 enabled: false
		button btnDummy "" width: 100 enabled: false	
	)
	
	group "Mode" (
		radiobuttons rdoMode "" labels: #("Install", "Uninstall") align: #left
	)
	
	group "Installation Log" (
		dotNetControl edtLog "System.Windows.Forms.Textbox" align:#center height: 120
	)
	
	button btnInstallSelected "Install Selected (0)" height: 36 width: 260 enabled: false offset: [0, 10]
	
	local packages = #()
	
	struct dotNetColors (
		fn getClr r g b = (dotnetclass "System.Drawing.Color").FromArgb r g b,
		fn getBg = (
			local bg = if((maxVersion())[1] > 16000) then #rollupTitleFace else #background
			local c = (colorman.getColor bg) * 255
			return getClr c[1] c[2] c[3]
		),
		fn getFg = (
			local c = (colorman.getColor #rollupTitleText) * 255
			return getClr c[1] c[2] c[3]
		),
		fn getByName n = (
			local c = try (n as color) catch(color 0 0 0)
			local cc = #(c.r, c.g, c.b)
			j = for i in cc collect i as integer
				
			return getClr j[1] j[2] j[3]
		),
		fn getByRGB r g b = (
			return getClr r g b
		)
	)
	
	fn boost = if (((maxVersion())[1] / 1000) >= 13) do windows.processPostedMessages() 

	fn setTextBoxPadding c p =
	(
		local h = c.handle
		local EM_SETMARGINS = 0xd3
		local EC_RIGHTMARGIN = 2
		local EC_LEFTMARGIN = 1
		local EC_TOPMARGIN = 0	
		windows.SendMessage h EM_SETMARGINS EC_LEFTMARGIN p				
		windows.SendMessage h EM_SETMARGINS EC_RIGHTMARGIN (bit.shift p 16)	
	)

	fn initTextBox textBox = (
		cc = dotNetColors()
		textBox.Font = dotNetObject "System.Drawing.Font" "MS Sans Serif" 8 ((dotNetClass "System.Drawing.FontStyle").Regular)
		textBox.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		textBox.BackColor = cc.getBg()
		textBox.ForeColor = cc.getFg()
		textBox.MultiLine = true
		textBox.WordWrap = true
		textBox.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
		textBox.ReadOnly = true
		
		setTextBoxPadding textBox 5
	)

	
	global rShowLog
	fn showLog m title:"Log" height: 300 width: 600 = (
		try(DestroyDialog rShowLog)catch()
		global szStat = m
		global iWidth = width - 2
		global iHeight = height - 35
		
		rollout rShowLog title (
			dotNetControl edtStat "System.Windows.Forms.Textbox" width: iWidth height: iHeight align:#center pos: [1, 1]
					
			dotNetControl btnCopyLog "System.Windows.Forms.Button" height: 25 width: 90 align: #left across: 2 
			dotNetControl btnCloseLog "System.Windows.Forms.Button" height: 25 width: 90 align: #right 
			
			fn initDotNet = (
				initTextBox edtStat
				btnCloseLog.text = "Close"
				btnCopyLog.text = "Copy"
				
				btnCloseLog.flatStyle = btnCloseLog.flatStyle.Popup
				btnCopyLog.flatStyle = btnCloseLog.flatStyle.Popup
			)
			
			on btnCloseLog Click do try(DestroyDialog rShowLog)catch()
			on btnCopyLog Click do setClipboardText szStat 
			
			on rShowLog open do (
				initDotNet()
				edtStat.text = szStat
			)
		)
		
		createDialog rShowLog width height
	)
	
	fn downloadFile url dl = (
		deleteFile dl
		w = dotNetObject "System.Net.WebClient"			
		try(
			spm = dotNetClass "System.Net.ServicePointManager"
			spm.SecurityProtocol = spm.SecurityProtocol.TLS12				
			w.DownloadFile (url + "?time=" + timestamp() as string) dl				
		) catch(
			return false
		)
		
		return true
	)
	
	fn formatString s v: #() tag: "$" = (
		for i in 1 to v.count  do (
			t = v[i] as string
			s = substituteString s (tag + i as string) (t)
		)
		
		return s
	)
	
	fn getPackages = (
		local ini = getThisScriptFilename()
		local haystack = getINISetting ini "PACKAGES"
		local pp = #()
		
		for i in haystack do (
			local n = i
			local d = getINISetting ini i "DESCRIPTION"
			local p = getINISetting ini i "PACKAGE"
			local a = getINISetting ini i "API"
			local dd = getINISetting ini i "DIR"
			local quad = (getINISetting ini i "QUAD") == "true"
			local dir = (getDir #temp) + @"\" + dd + @"\"
			local h = doesFileExist (dd + "install.ini")
			
			struct tmp (name, description, package, api, dir, exist, macro, quad)
			append pp (tmp name: n description: d package: p api: a dir: dir exist: h macro: dd quad: quad)
		)
		
		return pp
	)
	
	fn updateLbx load: false = (
		if (load == true) do packages = getPackages()
		
		local ll = for i in packages collect i.name		
		local ss = lbxPackages.selection as array
		
		lbxPackages.items = ll
		
		
		btnViewInfo.enabled = ss.count == 1
		btnInstallSelected.enabled = ss.count != 0
		local m = if (rdoMode.state == 1) then  "Install" else "Uninstall"
		btnInstallSelected.caption = formatString "$1 Selected ($2)" v: #(m, ss.count)
	)	
	
	fn getInfo = (	
		local ss = lbxPackages.selection as array
		local id = ss[1]
		
		if (id == 0 or id == undefined) do return false
		
		local p = packages[id]
		if (p == undefined) do return false
		
		btnViewInfo.caption = "Loading..."
		local d = getFilenamePath (getThisScriptFilename())
		local dl = formatString "$1$2.tmp" v: #(d, timeStamp())
		
		local r = downloadFile p.api dl
		
		if(not r or not doesFileExist dl) do return messageBox "Can't get info about script!" title: "Error!"
		local v = getIniSetting dl "INFO" "VER"	
		local n = getIniSetting dl "NOTES"	
		local d = getIniSetting dl "INFO" "DATE"
		deleteFile dl	
			
		local m = p.name + "\r\n\r\n"
		m += "Version: " + v + "\r\n"
		m += "Date: " + d + "\r\n\r\n"
		m += "Description: \r\n"
		m += p.description + "\r\n\r\n"
		m += "Release Notes: \r\n"
		for i in n do m += i + "\r\n"
			
		showLog m title: p.name
		
		btnViewInfo.caption = "View Info"
	)
	
	fn addLog t div: false = (
		if (div) do t = "\r\n---------------------------------------"
		edtLog.text += t + "\r\n"
		edtLog.SelectionStart = edtLog.text.count
		edtLog.ScrollToCaret()
		boost()
		edtLog.ScrollToCaret()
	)
	
	fn installPackages = (
		local div = "\r\n---------------------------------------\r\n"
		local ss = lbxPackages.selection as array
		local d = (getFilenamePath (getThisScriptFilename())) + @".download\"
		makeDir d all: true
		local uac_bat = @"c:\temp\uac.bat"	
		
		for i in ss do (
			local p = packages[i]
			
			addLog ("Downloading " + p.macro + ".mzp...")
			
			local dl = d + p.macro + ".mzp"
			deleteFile dl
			local r = downloadFile p.package dl
			
			if(r == undefined or not doesFileExist dl) do (
				addLog ("Error! Skipping...")
				addLog "" div: true				
				boost()
				continue
			)
			
			addLog "Complete downloading!"
		
			
			addLog "Unpacking..."
			isUnpack = msZip.unloadPackage dl &extractDir &dropFile
			deleteFile dl
			
			if (not isUnpack) then (
				addLog "Error! Skipping..."
				addLog "" div: true
				continue
			)
			
			addLog "Complete unpacking!"
			
			if (rdoMode.state == 1) then addLog "Installing!" else addLog "Uninstalling!"
					
			local installFile = p.dir + "install.mse"
			try (fileIn installFile) catch (
				addLog "Error! Skipping..."
				addLog "" div: true
				continue
			)
			
			try(closeRolloutFloater ::fInstallWiard) catch()
			
			local uac_lnk = p.dir + "uac.lnk"
			deleteFile uac_lnk
			deleteFile uac_bat
			
			::ACTION = 1	
			::QUAD = p.quad
			::TOOLBAR = true
			::MAINDROPDOWN = true
			::ICONS_TYPE = 1
				
			if (rdoMode.state == 1) then (
				try (::installScript()) catch (
					addLog "Error while installing!"
					addLog "" div: true
					continue
				)
			) else (
				try (::unistallScript()) catch (
					addLog "Error while unstalling!"
					addLog "" div: true
					continue
				)
			)
			
			HiddenDOSCommand uac_bat
			
			local f = cui.getConfigFile() 		
			cui.saveConfigAs f
			cui.loadConfig f
			updateToolbarButtons()
			
			if (rdoMode.state == 1) then addLog "Successfully installed!" else addLog "Successfully uninstalled!"
			addLog "" div: true
		)				
	)
	
	on _rSilentInstall open do (
		updateLbx load: true
		
		initTextBox edtLog		
	)
	
	on btnViewInfo pressed do getInfo()
	
	on btnDeselectAll pressed do (
		lbxPackages.selection = #{}
		updateLbx load: false
	)
	
	on btnSelectAll pressed do (		
		lbxPackages.selection = for i in 1 to lbxPackages.items.count collect i
		updateLbx load: false
	)
	
	on lbxPackages selectionEnd do (
		updateLbx load: false
	)
	
	on lbxPackages doubleClicked v do getInfo()
		
	on btnInstallSelected pressed do installPackages()
	
	on rdoMode changed v do updateLbx load: false
)

rollout _rSilentInstallAbout "About" category: 999 (
	group "Description" (
		dotNetControl edtDescription "System.Windows.Forms.Textbox" align:#center height: 60
	)
	
	label lblDummy1 ""
    
	label lblName "" 
	label lblVer ""
	
	label lblDummy2 ""
	
	label lblAuthor ""
	hyperlink lblCopy ""  align: #center color: orange
	
	label lblDummy3 ""
	
	timer tmrRestart "" active: false interval: 300
	    
	fn downloadFile url dl = (
		deleteFile dl
		w = dotNetObject "System.Net.WebClient"			
		try(
			spm = dotNetClass "System.Net.ServicePointManager"
			spm.SecurityProtocol = spm.SecurityProtocol.TLS12				
			w.DownloadFile (url + "?time=" + timestamp() as string) dl				
		) catch(
			return false
		)
		
		return true
	)
	
	fn bgUpdate = (
		local url = "https://raw.githubusercontent.com/3DGROUND/Silent-Installation/main/"
		local main = url + "Silent Installation.ms"
		
		local additionalFiles = #(			
		)
		
		local this = getThisScriptFileName()
		local p = getFileNamePath (getThisScriptFileName())
		local dl = this + ".tmp"
		local r = downloadFile main dl
		if(not r or not doesFileExist dl) do return print "Can't download updates!"
		local vn = getIniSetting dl "INFO" "VERSION"
		local vo = getIniSetting this "INFO" "VERSION"
		
		if(vn > vo) do (
			deleteFile this
			renameFile dl this
			
			for n in additionalFiles do (
				downloadFile (url + n) (p + n)
			)
			
			tmrRestart.active = true
		)
		
		deleteFile dl
	)
	
	fn updateWorker = (
		m = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"
		m.WorkerSupportsCancellation = true 
		m.CancelAsync() 
		dotNet.addEventHandler m "DoWork" bgUpdate
		m.RunWorkerAsync()	
	)
	
    fn getScriptInfo s releaseInfo: "" =  (
        if(releaseInfo != "") do (
            local r = getINISetting s releaseInfo
            return r
        )
		
        local v = getINISetting s "INFO" "VERSION"
        local a = getINISetting s "INFO" "AUTHOR"
        local n = getINISetting s "INFO" "NAME"
        local o = ""
		for i in (getINISetting s "ABOUT") do o += i + "\r\n"
        local d = getINISetting s "INFO" "DEV"
        local h = getINISetting s "INFO" "HELP"
        local c = getINISetting s "INFO" "CLIENT"
        
		struct data (version, author, name, description, developer, client, help, releases)
		
        local r = for i in (getINISetting s) where (i != "ABOUT" and i != "SCRIPT" and i != "COPY") collect i
		
		return (data version: v author: a name: n description: o developer: d client: c help: h releases: r)
    )
	
	on tmrRestart tick do (
		this = getThisScriptFileName()
		try(fileIn this) catch()
		vo = getIniSetting this "INFO" "VERSION"
		m = ("Silent Installation updated to version " + vo + "!\n\n\n")
		for c in (getIniSetting this vo) do (
			m += c + "\n"
		)
		
		print "---UPDATED---"
		print m
		tmrRestart.active = false
	)

    on _rSilentInstallAbout open do (
		edtDescription.MultiLine = true
		edtDescription.WordWrap = true
		edtDescription.ReadOnly = true
		edtDescription.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		
        local i = getScriptInfo (getThisScriptFilename())
		
        lblName.caption = i.name
        lblAuthor.caption = i.author
        lblVer.caption = i.version
        lblCopy.address = lblCopy.caption = i.developer
		edtDescription.text = i.description
		
		try (floaterSilentInstallation.title = i.name + " " + i.version) catch()
		try (_rSilentInstall.title = i.name + " v" +  i.version) catch()
		
		updateWorker()	
    )

	on _rSilentInstallAbout close do (
		::SILENT_INSTALLATION = undefined
	)
)

addRollout _rSilentInstall floaterSilentInstallation rolledUp: false border: false
addRollout _rSilentInstallAbout floaterSilentInstallation rolledUp: true 