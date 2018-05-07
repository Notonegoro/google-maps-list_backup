#include <MsgBoxConstants.au3>
#include <Misc.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>

HotKeySet("{SPACE}", "_main")
HotKeySet("{+}", "increase")
HotKeySet("-", "decrease")
HotKeySet("{ESC}", "ende")

#Region ;Variabeln
$iCounts = 1
$sClipDetails = ClipGet()
$fsClipDetails = ClipGet()
#EndRegion

#Region ;Datei erstellen
;~ Die Datei erstellen.
$sFileName = @YEAR & "-" & @MON & "-" & @MDAY & "-" & @HOUR & "." & @MIN & "." & @SEC & "_" & "MapsBackUp.csv"
$sFilePath = "[YOUR FILEPATH]" & $sFileName
$sep = '"sep=;"'
Global $hFileOpen = FileOpen($sFilePath, 1)
If $hFileOpen = -1 Then
	MsgBox($MB_SYSTEMMODAL, "", "An Error occurred!")
EndIf
FileWriteLine($hFileOpen, $sep)
FileWriteLine($hFileOpen, "Koordinaten_Dez; Beschreibung; Koordinaten_Grad; Link_Copy; Link_Created; Latitude; Longitude")
#EndRegion

Func _main()
	Do
		If $iCounts == 1 Then
			Call("Case1")
		EndIf
		Do
			Sleep(1000)
			$iWaitColor = PixelGetColor(72, 289)
		Until $iWaitColor = 4359668 ;blau
		Call("Case2")
		Sleep(250)
		Call("Case3")
		Do
			Sleep(250)
			$iWaitColor = PixelGetColor(72, 289)
		Until $iWaitColor = 16777215
		Sleep(250)
		Call("Case4")
	Until _IsPressed("1B")
EndFunc

Func _main_2() ;old, cases moved into Functions and handeld in main
	Select
		Case $iCounts = 1

;~ 			Wird nur beim starten ausgeführt.
;~ 			Das oberste Element in der Liste anklicken.
			MouseClick("left", 253, 178) ;oberste element wird angeklickt

;~ 			Protokoll zum Test in die Konsole schreiben
			$iCounts += 1
			ConsoleWrite($iCounts & @CRLF)


		Case $iCounts = 2

;~ 			Adresszeile Kopieren
			Send("{F6}")
			Sleep(150)
			Send("^c")
			Global $ClipAdressbar = ClipGet()

;~ 			Der Text und die Koordinaten werden kopiert.
			Local $x = 65
			Local $y = 323

;~ 			Maus zum blauen Berech bewegen und Farbe holen.
			MouseMove($x, $y, 0)
			$aPix1 = PixelGetColor($x, $y)

;~ 			Maus nach unten bewegen und vergleichen, dass sich die Farbe ändert.
			Do
				$y += 2 ;nach unten
				MouseMove($x, $y, 0)
				$aPix2 = PixelGetColor($x, $y)
			Until $aPix1 <> $aPix2

;~ 			Maus nach rechts und in blauen Berech bewegen.
			$y -= 3
			MouseMove(355, $y, 0)

;~ 			Maus klicken und nach oben links bewegen um Text zu markieren.
			Do
				$b = MouseDown($MOUSE_CLICK_MAIN)
			Until $b = True
			MouseMove($x, $y, 5)
			Do
				$y -= 2 ;nach oben
				MouseMove($x, $y, 0)
				$aPix2 = PixelGetColor($x, $y)
			Until $aPix1 <> $aPix2

;~ 			Maus nach unten bewegen, und "Maustaste" loslassen, sowie markieren Text kopieren.
			MouseMove($x, $y+5, 1) ; +5, damit nicht zu viel markiert wird
			Do
				$b = MouseUp($MOUSE_CLICK_MAIN)
			Until $b = True
			Send("^c")
			$sClipDetails = ClipGet()

;~ 			Damit nicht das Icon vom übersetzer im weg ist
			MouseClick($MOUSE_CLICK_MAIN, $x, $y+25, 1, 0)

;~ 			Kopierte Details aufteilen
			$sClipDetails = StringSplit($sClipDetails, @CRLF, 1)

;~ 			Entscheiden, was alles in der Zwischenablage steht.
			If $sClipDetails[0] == 2 Then
				$Beschreibung = ""
				$Koordinaten = $sClipDetails[1]
				$DecKoordinaten = $sClipDetails[2]
			Else
				$Beschreibung = $sClipDetails[1]
				$Koordinaten = $sClipDetails[2]
				$DecKoordinaten = $sClipDetails[3]
			EndIf

;~ 			Dezimale Koordinaten aufteilen, "whitespaces" entfernen und den Link für g-maps kreiren.
			$LatLong = StringSplit(StringStripWS($DecKoordinaten, $STR_STRIPALL), ",") ;Latitude = $LatLong[1] | Longitude = $LatLong[2]
;~ 			$fsClipDetails wird für später benötigt.
			Global $fsClipDetails = StringRight(StringTrimRight($DecKoordinaten, 1), 9)
			$sLink = "http://maps.google.com/?q=" & $LatLong[1] & "," & $LatLong[2]

;~ 			String erstellen und in Datei schreiben.
;~ 			[Koordinaten_Dez, Beschreibung, Koordinaten_Grad, Link_Copy, Link_Created, Latitude, Longitude]
			$sString = 	$DecKoordinaten & ";" & $Beschreibung & ";" & $Koordinaten & ";" & _
						$ClipAdressbar & ";" & $sLink & ";" & $LatLong[1] & ";" & $LatLong[2] & ";" & @CRLF
			FileWriteLine($hFileOpen, $sString)

;~ 			Protokoll zum Test in die Konsole schreiben.
			$iCounts += 1
			ConsoleWrite($iCounts & @CRLF)


		Case $iCounts = 3

;~ 			Koordinaten setzen und Maus an der x-Achse herunterfahren lassen um herreauszufinden in welcher Liste schon gespeicher ist.
			Local $x = 127
			Local $y = 347
			MouseMove($x, $y, 0)
			While 1
				$y += 1
				MouseMove($x, $y, 0)
				$iPix1 = PixelGetColor($x, $y)
				If $iPix1 == 16498733 Then ExitLoop	;gelb
				If $iPix1 == 3450963 Then ExitLoop	;grün
				If $iPix1 == 5227511 Then ExitLoop	;blau
			WEnd

;~ 			Bedingung wurde so gesetzt, dass gelb vorzufinden sein soll.
			While 1
				Select

;~ 					Wenn "gelb", dann klicke auf "zurück zur Liste".
					Case $iPix1 = 16498733 ;0xFBC02D (gelb)
						MouseClick($MOUSE_CLICK_MAIN, 123, 137) ;zurueck
						ExitLoop


;~ 					Wenn "grün", dann...
					Case $iPix1 = 3450963 ;0x34A853 (grün)

;~ 						Finde die Koordinaten von dem "grün" und klicke drauf.
						$aColor = PixelSearch(98, 348, 145, 535, $iPix1, 10)
						MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)

;~ 						Warte 300ms dann suche in der angezeigten Liste erneut nach "grün" und klicke drauf.
						Sleep(300)
						$aColor = PixelSearch(110, 316, 128, 765, $iPix1, 10);0x34A853 (grün)
						If Not @error Then
							MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)
						EndIf

;~ 						Warte so lange, bis das "blaue" Symbol auftaucht und dann mache im nächten Case weiter machen.
						Do
							$aColor = PixelSearch(98, 348, 145, 535, 5227511, 10);0x4FC3F7 (blau)
						Until $aColor == 5227511
						ContinueCase


;~ 					Wenn "blau", dann...
					Case $iPix1 = 5227511 ;0x4FC3F7 (blau)

;~ 						Finde die Koordinaten von dem "blau" und klicke drauf.
						$aColor = PixelSearch(98, 348, 145, 535, $iPix1, 10);0x4FC3F7 (blau)
						MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)

;~ 						Warte 300ms dann suche in der angezeigten Liste erneut nach "grün" und klicke drauf.
						Sleep(300)
						$aColor = PixelSearch(110, 316, 128, 765, 16498733, 10);0xFBC02D (gelb)

;~ 						Warte so lange, bis das "gelbe" Symbol auftaucht und dann auf "zurück zur Liste" klicken.
						If Not @error Then
							MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)
							Do
								$aColor = PixelSearch(98, 348, 145, 535, 16498733, 10);0xFBC02D (gelb)
							Until $aColor == 16498733
							MouseClick($MOUSE_CLICK_MAIN, 123, 137) ;zurueck
						EndIf
				EndSelect
			WEnd

;~ 			Protokoll zum Test in die Konsole schreiben
			$iCounts += 1
			ConsoleWrite($iCounts & @CRLF)


		Case $iCounts = 4

;~ 			Öffne das "Suchen" Feld
			Send("^f")
			Sleep(200)

;~ 			Fügt ein teil der Dezimalen Koordinaten ein und bestätigt die Eingabe
			ClipPut($fsClipDetails)
			Send("^v{ENTER}")
			Sleep(400)
;~ 			Send("{ENTER}")
;~ 			Sleep(200)

;~ 			Sucht nach dem orange von der Suche, (schließt das "Suchen" Feld und klickt auf das darunter liegende Feld.
			$aResult = PixelSearch(143, 150, 231, 765, 0xFF9632, 10)
			MouseClick($MOUSE_CLICK_MAIN, 1142, 78, 1, 0) ;Suchen Fenster schließen
;~ 			Falls der gefundene Text unter y=640 steht, dann auf den scrollbalken klicken und den Pfeil nach unten senden.
			If $aResult[1] > 640 Then
				$aScrollBar = PixelSearch(466, 147, 467, 767, 0x888888)
				MouseClick($MOUSE_CLICK_MAIN, $aScrollBar[0], $aScrollBar[1], 1, 1)
				Send("{DOWN 3}")
				Sleep(250)
				$aResult = PixelSearch(143, 150, 231, 765, 0x328EFE, 10)
				MouseClick($MOUSE_CLICK_MAIN, $aResult[0], $aResult[1]+112,1 ,1) ;unterhalb von Suchergebnis klicken
			Else
				MouseClick($MOUSE_CLICK_MAIN, $aResult[0], $aResult[1]+112,1 ,1) ;unterhalb von Suchergebnis klicken
			EndIf

;~ 			Protokoll zum Test in die Konsole schreiben
			$iCounts = 2
			ConsoleWrite($iCounts & @CRLF)


	EndSelect
EndFunc

Func Case1()

;~ 	Wird nur beim starten ausgeführt.
;~ 	Das oberste Element in der Liste anklicken.
	MouseClick("left", 253, 178) ;oberste element wird angeklickt

;~ 	Protokoll zum Test in die Konsole schreiben
	$iCounts += 1
	ConsoleWrite($iCounts & @CRLF)

EndFunc

Func Case2()

;~ 	Adresszeile Kopieren
	Send("{F6}")
	Sleep(150)
	Send("^c")
	Sleep(150)
	Global $ClipAdressbar = ClipGet()

;~ 	Der Text und die Koordinaten werden kopiert.
	Local $x = 65
	Local $y = 323

;~ 	Maus zum blauen Berech bewegen und Farbe holen.
	MouseMove($x, $y, 0)
	$aPix1 = PixelGetColor($x, $y)

;~ 	Maus nach unten bewegen und vergleichen, dass sich die Farbe ändert.
	Do
		$y += 2 ;nach unten
		MouseMove($x, $y, 0)
		$aPix2 = PixelGetColor($x, $y)
	Until $aPix1 <> $aPix2

;~ 	Maus nach rechts und in blauen Berech bewegen.
	$y -= 3
	MouseMove(355, $y, 0)

;~ 	Maus klicken und nach oben links bewegen um Text zu markieren.
	Do
		$b = MouseDown($MOUSE_CLICK_MAIN)
	Until $b = True
	MouseMove($x, $y, 5)
	Do
		$y -= 2 ;nach oben
		MouseMove($x, $y, 0)
		$aPix2 = PixelGetColor($x, $y)
	Until $aPix1 <> $aPix2

;~ 	Maus nach unten bewegen, und "Maustaste" loslassen, sowie markieren Text kopieren.
	MouseMove($x, $y+5, 1) ; +5, damit nicht zu viel markiert wird
	Do
		$b = MouseUp($MOUSE_CLICK_MAIN)
	Until $b = True
	Send("^c")
	$sClipDetails = ClipGet()

;~ 	Damit nicht das Icon vom übersetzer im weg ist
	MouseClick($MOUSE_CLICK_MAIN, $x, $y+25, 1, 0)

;~ 	Kopierte Details aufteilen
	$sClipDetails = StringSplit($sClipDetails, @CRLF, 1)

;~ 	Entscheiden, was alles in der Zwischenablage steht.
	If $sClipDetails[0] == 2 Then
		$Beschreibung = ""
		$Koordinaten = $sClipDetails[1]
		$DecKoordinaten = $sClipDetails[2]
	Else
		$Beschreibung = $sClipDetails[1]
		$Koordinaten = $sClipDetails[2]
		$DecKoordinaten = $sClipDetails[3]
	EndIf

;~ 	Dezimale Koordinaten aufteilen, "whitespaces" entfernen und den Link für g-maps kreiren.
	$LatLong = StringSplit(StringStripWS($DecKoordinaten, $STR_STRIPALL), ",") ;Latitude = $LatLong[1] | Longitude = $LatLong[2]
;~ 	$fsClipDetails wird für später benötigt.
	Global $fsClipDetails = StringRight(StringTrimRight($DecKoordinaten, 1), 9)
	$sLink = "http://maps.google.com/?q=" & $LatLong[1] & "," & $LatLong[2]

;~ 	String erstellen und in Datei schreiben.
;~ 	[Koordinaten_Dez, Beschreibung, Koordinaten_Grad, Link_Copy, Link_Created, Latitude, Longitude]
	$sString = 	$DecKoordinaten & ";" & $Beschreibung & ";" & $Koordinaten & ";" & _
				$ClipAdressbar & ";" & $sLink & ";" & $LatLong[1] & ";" & $LatLong[2] & ";" & @CRLF
	FileWriteLine($hFileOpen, $sString)

;~ 	Protokoll zum Test in die Konsole schreiben.
	$iCounts += 1
	ConsoleWrite($iCounts & @CRLF)


EndFunc

Func Case3()

;~ 	Koordinaten setzen und Maus an der x-Achse herunterfahren lassen um herreauszufinden in welcher Liste schon gespeicher ist.
	Local $x = 127
	Local $y = 347
	MouseMove($x, $y, 0)
	While 1
		$y += 2
		MouseMove($x, $y, 0)
		$iPix1 = PixelGetColor($x, $y)
		If $iPix1 == 16498733 Then
			ExitLoop	;gelb
		ElseIf $iPix1 == 3450963 Then
			ExitLoop	;grün
		ElseIf $iPix1 == 5227511 Then
			ExitLoop	;blau
		EndIf
	WEnd

;~ 	Bedingung wurde so gesetzt, dass gelb vorzufinden sein soll.
	While 1
		Select

;~ 			Wenn "gelb", dann klicke auf "zurück zur Liste".
			Case $iPix1 = 16498733 ;0xFBC02D (gelb)
				MouseClick($MOUSE_CLICK_MAIN, 123, 137) ;zurueck
				ExitLoop


;~ 			Wenn "grün", dann...
			Case $iPix1 = 3450963 ;0x34A853 (grün)

;~ 				Finde die Koordinaten von dem "grün" und klicke drauf.
				$aColor = PixelSearch(98, 348, 145, 535, $iPix1, 10)
				MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)

;~ 				Warte 300ms dann suche in der angezeigten Liste erneut nach "grün" und klicke drauf.
				Sleep(400)
				$aColor = PixelSearch(110, 316, 128, 765, $iPix1, 10);0x34A853 (grün)
				If Not @error Then
					MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)
				EndIf

;~ 				Warte so lange, bis das "blaue" Symbol auftaucht und dann mache im nächten Case weiter machen.
				Do
					$aColor = PixelSearch(98, 348, 145, 535, 5227511, 10);0x4FC3F7 (blau)
				Until $aColor == 5227511
				ContinueCase


;~ 			Wenn "blau", dann...
			Case $iPix1 = 5227511 ;0x4FC3F7 (blau)

				$iPix1 = 5227511

;~ 				Warte so lange, bis das "blaue" Symbol auftaucht und dann mache im nächten Case weiter machen.
				Do
					$aColor = PixelSearch(98, 348, 145, 535, $iPix1, 10);0x4FC3F7 (blau)
				Until $aColor == 5227511

;~ 				Finde die Koordinaten von dem "blau" und klicke drauf.
				$aColor = PixelSearch(98, 348, 145, 535, $iPix1, 10);0x4FC3F7 (blau)
				MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 2)

;~ 				Warte 300ms dann suche in der angezeigten Liste erneut nach "gelb" und klicke drauf.
				Sleep(350)
				$aColor = PixelSearch(110, 316, 128, 765, 16498733, 10);0xFBC02D (gelb)

;~ 				Warte so lange, bis das "gelbe" Symbol auftaucht und dann auf "zurück zur Liste" klicken.
				If Not @error Then
					MouseClick($MOUSE_CLICK_MAIN, $aColor[0]+2, $aColor[1]+2, 1, 3)
					Do
						$aColor = PixelSearch(98, 348, 145, 535, 16498733, 10);0xFBC02D (gelb)
					Until $aColor == 16498733
					MouseClick($MOUSE_CLICK_MAIN, 123, 137) ;zurueck
				EndIf
		EndSelect
	WEnd

;~ 	Protokoll zum Test in die Konsole schreiben
	$iCounts += 1
	ConsoleWrite($iCounts & @CRLF)


EndFunc

Func Case4()

;~ 	Öffne das "Suchen" Feld
	Send("^f")
	Sleep(200)

;~ 	Fügt ein teil der Dezimalen Koordinaten ein und bestätigt die Eingabe
	ClipPut($fsClipDetails)
	Send("^v{ENTER}")
	Sleep(400)
;~ 	Send("{ENTER}")
;~ 	Sleep(200)

;~ 	Sucht nach dem orange von der Suche, (schließt das "Suchen" Feld und klickt auf das darunter liegende Feld.
	$aResult = PixelSearch(143, 150, 231, 765, 0xFF9632, 10)
	MouseClick($MOUSE_CLICK_MAIN, 1142, 78, 1, 0) ;Suchen Fenster schließen
;~ 	Falls der gefundene Text unter y=640 steht, dann auf den scrollbalken klicken und den Pfeil nach unten senden.
	If $aResult[1] > 640 Then
		$aScrollBar = PixelSearch(466, 147, 467, 767, 0x888888)
		MouseClick($MOUSE_CLICK_MAIN, $aScrollBar[0], $aScrollBar[1], 1, 1)
		Send("{DOWN 3}")
		Sleep(250)
		$aResult = PixelSearch(143, 150, 231, 765, 0x328EFE, 10)
		MouseClick($MOUSE_CLICK_MAIN, $aResult[0], $aResult[1]+112,1 ,1) ;unterhalb von Suchergebnis klicken
	Else
		MouseClick($MOUSE_CLICK_MAIN, $aResult[0], $aResult[1]+112,1 ,1) ;unterhalb von Suchergebnis klicken
	EndIf

;~ 	Protokoll zum Test in die Konsole schreiben
	$iCounts = 2
	ConsoleWrite($iCounts & @CRLF)


EndFunc

Func increase()
	$iCounts += 1
	ConsoleWrite($iCounts & @CRLF)
EndFunc

Func decrease()
	$iCounts -= 1
	ConsoleWrite($iCounts & @CRLF)
EndFunc

Func ende()
	MouseUp("left")
	_MouseTrap()
	While 1
		Sleep(200)
		If _IsPressed("1B") Then
			FileClose($hFileOpen)
			Exit
		EndIf
	WEnd
EndFunc   ;==>ende

While 1
	Sleep(100)
WEnd

If @error Then
	ConsoleWrite(@extended & @CRLF)
	FileClose($hFileOpen)
	Exit
EndIf
