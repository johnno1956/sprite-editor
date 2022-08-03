MAX_UNDO = 10

undo_buffer_default_width = 512
undo_buffer_default_height = 512

Dim undo_buffer[MAX_UNDO, undo_buffer_default_width, undo_buffer_default_height]   'This holds the buffer (ie. the image) for each undo
Dim undo_buffer_order$   'This holds the order of the items in the undo buffer.
                         'This is an optimization trick we can use to prevent us from having to move data around in the undo_buffer.

undo_buffer_order_digits = 1  'We are going to store each index in this string as 1 digit.
                              'We are using 1 digit since the max number we will store will be 9 (0 to 9 is the 10 indexes in our array)

current_undo = 0   'The current index in the undo buffer to write to

'This will add the current state of the image to the undo buffer
Sub Add_Undo_Action(ByRef image, image_width, image_height)
	'If image_width > undo_buffer_default_width Or image_height > undo_buffer_default_height Then
	'	ReDim undo_buffer[MAX_UNDO, image_width, image_height]
	'End If
	
	For y = 0 to image_height-1
		For x = 0 to image_width-1
			undo_buffer[current_undo, x, y] = image[y*image_width+x]   'image[x,y] is representing the color at (x,y) position in the image
		Next
	Next

	undo_buffer_order$ = Right$(undo_buffer_order$, (MAX_UNDO-1) * undo_buffer_order_digits)  'If there is 10 items in the undo buffer, this will only keep the last 9
	undo_buffer_order$ = undo_buffer_order$ + Str$(current_undo)  'This adds our current undo action to the end of our buffer order

	current_undo = current_undo + 1   'Move the current_undo index to the next position in the buffer for the next undo action

	'If current_undo has reached the size of our undo_buffer then we set it back to 0
	If current_undo = MAX_UNDO Then
		current_undo = 0
	End If
	
	'Print "DO_BUFFER = ";undo_buffer_order$
End Sub

'This will remove the last undo action from our buffer order and return the index in the undo buffer
Function Pop_Undo()
	last_undo = 0
	If Length(Trim$(undo_buffer_order$)) <= 1  Then
		last_undo = -1
	Else
		restore_index$ = Left$(Right$(undo_buffer_order$, undo_buffer_order_digits*2), undo_buffer_order_digits)
		If Trim$(restore_index$) = "" Then
			last_undo = -1
		Else
			last_undo = Val( restore_index$ )  'Here we are getting the last undo buffer index of the last action stored
			If last_undo + 1 = MAX_UNDO Then
				current_undo = 0
			Else
				current_undo = last_undo + 1
			End If
			undo_buffer_order$ = Left$(undo_buffer_order$, Min((MAX_UNDO-1) * undo_buffer_order_digits, Length(undo_buffer_order$)-1))  'Here we are removing the last index from the buffer order
		End If
	End If
	
	'If the current_undo is less than 0 then we set it to the end of the undo_buffer
	If current_undo < 0 Then
		current_undo = MAX_UNDO-1
	End If
	
	'And finally we need to return the action that we have removed from the buffer
	Return last_undo
End Function


Function Undo(ByRef image, image_width, image_height)
	restore_buffer_index = Pop_Undo()
	'print "Restore = ";restore_buffer_index
	If restore_buffer_index >= 0 Then
		For y = 0 to image_height-1
			For x = 0 to image_width-1
				image[y*image_width+x] = undo_buffer[restore_buffer_index, x, y]
			Next
		Next
	End If
	Return restore_buffer_index
End Function