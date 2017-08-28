on run

	tell application "System Preferences"
		activate
		set current pane to pane "com.apple.preference.trackpad"
	end tell

	tell application "System Events"
		tell process "System Preferences"
		  delay(0.5)
			click radio button "Scroll & Zoom" of tab group 1 of window "Trackpad"
			#delay(1)
			click checkbox 1 of tab group 1 of window "Trackpad"
			#delay(1)
		end tell
	end tell

	tell application "System Preferences"
		quit
	end tell
end run
