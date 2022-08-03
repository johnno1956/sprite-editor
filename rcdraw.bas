Include "undo.bas"

xmax = 1300
ymax = 640
title$ = "RC Draw v 0.1"
center_x = windowpos_centered
center_y = windowpos_centered
WindowOpen(1,title$,center_x,center_y,xmax,ymax,WindowMode(1,0,0,0,0),1)
SetWindowAutoClose(1, 0)
CanvasOpen(1,xmax,ymax,0,0,xmax,ymax,0)
ClearCanvas

arial14 = 1: loadFont(arial14, "assets/arial.ttf", 14)
	
click = 1: loadSound(1, "assets/buttonClick.wav")

'	Define colours
'
gridColour = rgb(128, 128, 128)
darkGray = rgb(64, 64, 64)
red = rgb(255, 0, 0)
darkRed = rgb(128, 0, 0)
green = rgb(0, 255, 0)
darkGreen = rgb(0, 128, 0)
darkCyan = rgb(0, 128, 128)
yellow = rgb(255, 255, 0)
black = rgb(0, 0, 0)
white = rgb(255, 255, 255)


'	Variables and arrays
'
gridSize = 64
gSize = 9
pSize = 1
tools = 5
currentColour = 0
resetCurrentColour = 0
symmetry = 0
exist = 0
'r5 = 0
'g5 = 0
'b5 = 0

Dim mainGrid[gridSize, gridSize]
'Dim bGrid[gridSize, gridSize]
Dim prevGrid[gridSize, gridSize]
Dim tool[tools]
Dim zone[20]
Dim a1[201, 61]
Dim mx
Dim my
Dim ux
Dim uy
Dim w
Dim h
Dim msgWidth
Dim msgHeight


'=====================================================================
Sub Setup()
	'
	'	Reset Tool Flags
	'
	tool[1] = 0
	tool[2] = 0
	tool[3] = 0
	
	'
	'	Reset Zones
	'
	for i = 1 to 10
		zone[i] = 0
	next
	
	'
	'	Draw Main Grid
	'
	setColor(gridColour)
	for x = 0 to 640
		line(x, 0, x, 640)
		x = x + gSize
	next
	for y = 0 to 640
		line(0, y, 640, y)
		y = y + gSize
	next
	zone1 = 0
	
	for y = 0 to gridSize-1
		for x = 0 to gridSize-1
			mainGrid[x,y]=black
		next
	next
	
	Add_Undo_Action(mainGrid, gridSize, gridSize)
	
	'
	'	Program Title and author
	'
	logo = 1: loadImage(logo, "assets/draw1.png")
	drawImage(logo, 720, 0)
	
	setColor(darkCyan)
	DrawText("(c) 2015, 2022 John Baldwin", 730, 620)
	
	'
	'	Colour Selection Samples
	'
	patch = 2: loadImage(patch, "assets/colourpatch.png")
	DrawImage(patch, 690, 300)
	
	'
	'	Sprite Preview Boxes
	'
	setColor(gridColour)
	rect(698, 98, 67, 67)
	rect(798, 98, 134, 134)
	setColor(white)
	Font(arial14)
	DrawText("Preview", 703, 170)
	DrawText("Preview x2", 830, 235)
	
	'
	'	Display Current Colour
	'
	setColor(gridColour)
	rect(812, 520, 30, 30)
	
	'
	'	Display Menu Buttons
	'
	setColor(gridcolour)
	rect(690,520,80,40)
	'create zone 2,690,520,80,40
	DrawText("NEW", 698, 523)
	zone2 = 0

	rect(690,570,80,40)
	'create zone 3,690,570,80,40
	DrawText("LOAD", 698, 573)
	zone3 = 0

	rect(787,570,80,40)
	'create zone 4,790,570,80,40
	DrawText("SAVE", 795, 573)
	zone4 = 0

	rect(884,520,80,40)
	'create zone 5,884,520,80,40
	DrawText("QUIT", 891, 523)
	zone5 = 0
	
	rect(884,570,80,40)
	'create zone 6,884,570,80,40
	DrawText("CLEAR", 892, 573)
	zone6 = 0
	
	'
	'	Display Tool Buttons
	'
	'
	'	PENCIL
	'
	setColor(gridColour)
	rect(1014, 98, 80, 40)
	'create zone 7,1014,98,80,40
	Font(arial14)
	DrawText("Pencil", 1022, 101)
	tool[1]=0

	'
	'	LINE
	'
	setColor(gridColour)
	rect(1014, 148, 80, 40)
	'create zone 8,1014,14,80,40
	Font(arial14)
	DrawText("Line", 1022, 151)
	DrawText("wip", 1059, 168)
	tool[2]=0	
	
	'
	'	Mirror / Symmetry
	'
	setColor(gridColour)
	rect(1014, 198, 80, 40)
	'create zone 9,1014,198,80,40
	Font(arial14)
	DrawText("Mirror", 1022, 201)
	tool[3]=0
	
	'
	'	Spare Buttons
	'
	setColor(darkGray)
	rect(1014, 248, 80, 40)
	rect(1014, 298, 80, 40)
	rect(1014, 348, 80, 40)
	rect(1014, 398, 80, 40)
	rect(1014, 448, 80, 40)
	rect(1104, 98, 80, 40)
	rect(1104, 148, 80, 40)
	rect(1104, 198, 80, 40)
	rect(1104, 248, 80, 40)
	rect(1104, 298, 80, 40)
	rect(1104, 348, 80, 40)
	rect(1104, 398, 80, 40)
	rect(1104, 448, 80, 40)
	rect(1194, 98, 80, 40)
End Sub

Sub getZones()
	'	Define mouse "zones"
	'
	'	Zone1 = Main Grid
	'	Zone2 = NEW
	'	Zone3 = LOAD
	'	Zone4 = SAVE
	'	Zone5 = QUIT
	'	Zone6 = PENCIL
	'	Zone7 = LINE (WIP)
	'	Zone8 = MIRROR/SYMMETRY
	'	Zone9 = CLEAR
	'	Zone10 = COLOUR SELECTION
	
	'	MAIN GRID
	if mx > 0 and mx < 640 and my > 0 and my < 640 then
		zone[1] = 1
	else
		zone[1] = 0
	end if
	
	'	NEW
	if mx > 690 and mx < 770 and my > 520 and my < 560 then
		zone[2] = 1
	else
		zone[2] = 0
	end if
	
	'	LOAD
	if mx > 690 and mx < 770 and my > 570 and my < 610 then
		zone[3] = 1
	else
		zone[3] = 0
	end if
	
	'	SAVE
	if mx > 787 and mx < 867 and my > 570 and my < 610 then
		zone[4] = 1
	else
		zone[4] = 0
	end if
	
	'	QUIT
	'setColor(rgb(255, 0, 255))
	'Rect(884, 520, 80, 40)
	'setColor(gridColour)
	if mx > 884 and mx < 964 and my > 520 and my < 560 then
		zone[5] = 1
	else
		zone[5] = 0
	end if
	
	'	PENCIL
	if mx > 1014 and mx < 1094 and my > 98 and my < 138 then
		zone[6] = 1
	else
		zone[6] = 0
	end if
	
	'	LINE - WIP
	if mx > 1014 and mx < 1094 and my > 148 and my < 188 then
		zone[7] = 1
	else
		zone[7] = 0
	end if
	
	'	MIRROR / SYMMETRY
	if mx > 1014 and mx < 1094 and my > 198 and my < 238 then
		zone[8] = 1
	else
		zone[8] = 0
	end if
	
	'	CLEAR / ERASE GRIDS
	if mx > 884 and mx < 964 and my > 570 and my < 610 then
		zone[9] = 1
	else
		zone[9] = 0
	end if
	
	'	COLOUR SELECTION
	if mx > 690 and mx < 964 and my > 300 and my < 490 then
		zone[10] = 1
	else
		zone[10] = 0
	end if
End Sub

Sub center(fontSlot, msg$, ypos, colour)
	GetTextSize(fontSlot, msg$, ByRef msgWidth, ByRef msgHeight)
	Font(fontSlot): setColor(colour)
	DrawText(msg$, (1300 - msgWidth) / 2, ypos)
End Sub

Sub messageBox(var1, var2, var3, tx1$, tx2$, tx3$, tx4$, tx5$)
	sx = (xmax - var2) / 2
	sy = (ymax - var3) / 2
	lw = len(tx1$)
	lw2 = len(tx2$)
	lw3 = len(tx3$)
	lw4 = len(tx4$)
	lw5 = len(tx5$)
	for uy=0 to var3-1
		for ux=0 to var2-1
			a1[ux, uy] = getpixel(sx + ux, sy + uy)
		next
	next
	setColor(black)
	rectFill(sx, sy, var2, var3)
	setColor(var1)
	rect(sx, sy, var2, var3)

	do
		center(arial14, tx1$, sy, white)
		center(arial14, tx2$, sy + 10, var1)
		center(arial14, tx3$, sy + 20, black)
		center(arial14, tx4$, sy+30, yellow)
		center(arial14, tx5$, sy + 40, black)
		update()
    loop until key(32) = 1
	wait(500)
	for uy=0 to var3-1
		for ux=0 to var2-1
			setcolor(a1[ux, uy])
			pset(sx+ux,sy+uy)
		next
	next
	update()
	wait(500)
End Sub

Sub DrawOnMainGrid()
	if tool[1] <> 0 then
		setColor(currentColour)
		mouseGridX = int(mx/10) * 10
		mouseGridY = int(my/10) * 10
		mainGrid[int(mx/10),int(my/10)] = currentColour
		rectFill(mouseGridX, mouseGridY, 10, 10)
		pset(700 + (mouseGridX / 10), 100 + (mouseGridY / 10))
		rectFill(800 + (mouseGridX / 10) * 2, 100 + (mouseGridY / 10) * 2, 2, 2)
		if symmetry = 1 then
			setColor(currentColour)
			mouseGridX2 = 640 - (int(mx/10) * 10) - 9
			mouseGridY2 = int(my/10) * 10
			rectFill(mouseGridX2, mouseGridY2, 10, 10)
			pset(700 + (mouseGridX2 / 10), 100 + (mouseGridY2 / 10))
			rectFill(800 + (mouseGridX2 / 10) * 2, 100 + (mouseGridY2 / 10) * 2, 2, 2)
		end if
	end if
End Sub

Sub EraseFromMainGrid()
	if tool[1] <> 0 then
		setColor(black)
		mouseGridX = int(mx/10) * 10
		mouseGridY = int(my/10) * 10
		mainGrid[int(mx/10), int(my/10)] = black
		rectFill(mouseGridX, mouseGridY, 10, 10)
		pset(700 + (mouseGridX / 10), 100 + (mouseGridY / 10))
		rectFill(800 + (mouseGridX / 10) * 2, 100 + (mouseGridY / 10) * 2, 2, 2)
	end if
End Sub

Sub RedrawMainGrid()
	setColor(gridColour)
	for x = 0 to 640
		line(x, 0, x, 640)
		x = x + gsize
	next
	for y = 0 to 640
		line(0, y, 640, y)
		y = y + gsize
	next
End Sub

Sub UpdatePreview()
	for prevx = 0 to 63
		for prevy = 0 to 63
			setColor(getpixel((prevx * 10) + 5, (prevy * 10) + 5))
			pset(700 + prevx, 100 + prevy)
		next
	next
	'	Magnified Preview
	'for prevx = 0 to 63
	'	for prevy = 0 to 63
	'		setColor(getpixel((prevx*10)+5,(prevy*10)+5))
	'		'set pixel 800+(prevx*2),100+(prevy*2)
	'		'set pixel 801+(prevx*2),100+(prevy*2)
	'		'
	'		'set pixel 800+(prevx*2),101+(prevy*2)
	'		'set pixel 801+(prevx*2),101+(prevy*2)
	'		rectFill(800 +(prevx * 2), 100 + (prevy * 2), 2, 2)
	'	next
	'next
End Sub

Sub ChangeGridSize()
	'
	'	NOT YET IMPIMENTED
	'
End Sub

Sub Sure()
	'	This procedure will be used when
	'	NEW or Quit are selected.
	exist = 0
	for imagex = 0 to 63
		for imagey = 0 to 63
			if getpixel(700 + imagex, 100 + imagey) <> black then
				exist = 1
			end if
		next
	next
End Sub

'==============
'
'	TOOLS
'
'==============
Sub Mirror()
	if tool[3]=0 then
		setColor(gridColour)
		rect(1014, 198, 80, 40)
		Font(arial14)
		DrawText("Mirror", 1022, 201)
	end if
	if tool[3]=1 then
		setColor(white)
		rect(1014, 198, 80, 40)
		Font(arial14)
		setColor(yellow)
		DrawText("Mirror", 1022, 201)
		setColor(gridColour)
	end if
End Sub

Sub DrawLine()
	if tool[2] = 0 then
		setColor(gridColour)
		rect(1014, 148, 80, 40)
		Font(arial14)
		DrawText("Line", 1022, 151)
	end if
	if tool[2] = 1 then
		setColor(white)
		rect(1014, 148, 80, 40)
		Font(arial14)
		setColor(yellow)
		DrawText("Line", 1022, 151)
		setColor(gridColour)
	end if
End Sub

Sub Pencil()
	if tool[1] = 0 then
		setColor(gridColour)
		rect(1014, 98, 80, 40)
		Font(arial14)
		DrawText("Pencil", 1022, 101)
	end if
	if tool[1] = 1 then
		setColor(white)
		rect(1014, 98, 80, 40)
		Font(arial14)
		setColor(yellow)
		DrawText("Pencil", 1022, 101)
		setColor(gridColour)
		tool[2] = 0
		DrawLine()
		tool[3] = 0
		symmetry = 0
		Mirror()
	end if
End Sub

'==========
'
'	MENU
'
'==========
Sub StoreFile()

End Sub

Sub LoadFile()

End Sub

Sub ClearImage()
	tool[1] = 0
	Pencil()
	tool[2] = 0
	DrawLine()
	tool[3] = 0
	Mirror()
	for imagex = 0 to 63
		for imagey = 0 to 63
			mainGrid[imagex, imagey] = black
			setColor(mainGrid[imagex, imagey])
			dotx = imagex * 10
			doty = imagey * 10
			rectFill(dotx, doty, 10, 10)
			'    ---------------------------------------
			'        Draw Preview
			'    ---------------------------------------
			pset(700 + imagex, 100 + imagey)
			'    ---------------------------------------
			'        Draw Magnified Preview
			'    ---------------------------------------
			rectFill(800 + (imagex * 2), 100 + (imagey * 2), 2, 2)
		next
	next
	resetCurrentColour = 1
	RedrawMainGrid()
	wait(100)
	'free file 1
End Sub

Sub NewImage()
	Sure()
	if exist = 1 then
		StoreFile()
		exist = 0
	end if
	tool[1] = 0
	Pencil()
	tool[2] = 0
	DrawLine()
	tool[3] = 0
	symmetry = 0
	Mirror()
	for imagex = 0 to 63
		for imagey = 0 to 63
			mainGrid[imagex, imagey] = black
			setColor(maingrid[imagex, imagey])
			dotx = imagex * 10
			doty = imagey * 10
			rectFill(dotx, doty, 10, 10)
			'    ---------------------------------------
			'        Draw Preview
			'    ---------------------------------------
			pset(700 + imagex, 100 + imagey)
			'    ----------------------------------------------------
			'        Draw Magnified Preview
			'    ----------------------------------------------------
			RectFill(800 + (imagex * 2), 100 + (imagey * 2), 2, 2)
		next
	next
	resetCurrentColour = 1
	RedrawMainGrid()
	wait(100)
	'free file 1
End Sub


Sub RefreshMainGrid()
	For y = 0 to gridSize-1
		For x = 0 to gridSize-1
			setColor(mainGrid[x,y])
			rectFill(x*10, y*10, 10, 10)
			pset(700 + x, 100 + y)
			rectFill(800 + x * 2, 100 + y * 2, 2, 2)
		Next
	Next
	RedrawMainGrid()
End Sub
'=====================================================================

Setup()

'We will use the mouse down to track undo actions
mb0_down = false
mb1_down = false

'
'		M A I N   L O O P
'
do
	'	Scan for and define mouse input
	'
	mx = mousex()
	my = mousey()
	mb0 = mousebutton(0)
	mb1 = mousebutton(1)
	
	
	If (Key(K_RCTRL) Or Key(K_LCTRL)) And Key(K_Z) Then
		'print "Undo"
		Undo(mainGrid, gridSize, gridSize)
		RefreshMainGrid()
		
		While Key(K_Z)
			Update()
		Wend
		
	End If
	
	getZones()
	
	'	Draw on and Erase from Main Grid
	'
	if zone[1] = 1 and mb0 = 1 then
		DrawOnMainGrid()
		mb0_down = true
	end if
	
	if zone[1] = 1 and mb1 = 1 then
		'EraseFromMainGrid()
		'mb1_down = true
	end if
	
	
	If (Not mb0) And mb0_down Then
		'Print "Action"
		Add_Undo_Action(mainGrid, gridSize, gridSize)
		mb0_down = false
	End If
	
	If (Not mb1) And mb1_down Then
		'Print "Action"
		Add_Undo_Action(mainGrid, gridSize, gridSize)
		mb1_down = false
	End If
	
	
	'UpdatePreview()
	RedrawMainGrid()
	
	'	QUIT / EXIT EDITOR
	'
	if zone[5] = 1 and mb0 = 1 then
		messageBox(green,200,60,"  ","Goodbye!","  ","Press SPACE key","  ")
		update()
		end
	end if
	
	'	LOAD FILE
	'
	if mb0 and zone[3] = 1 then
		messageBox(red,200,60,"  ","Not yet!!","  ","Press SPACE key","  ")
		update()
		'play sound click
		'tool[1] = 0
		'Pencil()
		'LoadFile()
	end if
	
	'	SAVE FILE
	'
	if mb0 and zone[4] = 1 then
		messageBox(yellow,200,60,"  ","Not yet!!","  ","Press SPACE key","  ")
		update()
		'play sound 1
		'StoreFile()
	end if
	
	'	NEW / ERASE GRIDS
	'
	if mb0 and zone[2] = 1 then
		'play sound 1
		NewImage()
	end if
	
	'	CLEAR / ERASE GRIDS
	'
	if mb0 and zone[9] = 1 then
		'play sound 1
		ClearImage()
	end if
	
	'	TOOLS - PENCIL
	'
	if mb0 and zone[6] = 1 then
		'play sound 1
		tool[1] = 1
		Pencil()
		tool[2] = 0
		DrawLine()
		tool[3] = 0
		symmetry = 0
		Mirror()
		
	end if
	
	'	TOOLS - LINE
	'
	if mb0 and zone[7] = 1 then
		messageBox(rgb(0, 255, 255),200,60,"  ","Not yet!!","  ","Press SPACE key","  ")
		update()

		'play sound 1
		'tool[1] = 1
		'Pencil()
		'tool[2] = 1
		'DrawLine()
		'tool[3] = 0
		'symmetry = 0
		'Mirror()
	end if
	
	'	TOOLS - MIRROR
	'
	if mb0 and zone[8] = 1 then
		'play sound 1
		tool[1] = 1
		Pencil()
		tool[2] = 0
		DrawLine()
		tool[3] = 1
		symmetry = 1
		Mirror()
	end if
	
	'	SELECT CURRENT COLOUR
	'
	if mb0 and zone[10] = 1 then
		currentColour = getpixel(mx, my)
	end if
	setColor(currentColour)
	rectFill(813, 521, 28, 28)

	if Not WindowExists(1) Or WindowEvent_Close(1) Then
		end
	end if
	update()
loop until key(27) = 1
