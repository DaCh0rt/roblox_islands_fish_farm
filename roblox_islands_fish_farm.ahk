; Ian Harvey
#MaxThreadsPerHotkey 3

;================================
;
; This is the bounding box around the fishing interface. It should be centered and almost touch
; the end of the bar without including the white outline. To find out the box for your specific
; window use the hotkey F2 while centered vertically on the fishing bar
;
;================================
x1 := 632
x2 := 1303
y1 := 783

red := 0xFF6969 ;RGB
white := 0xFFFFFF
gray := 0x717479
green := 0x218324
blue := 0x27598E
yellow := 0x8B901B
purple := 0x8A3783
fish_colors := [gray, green, blue, yellow, purple]
fish_bar := [-1, ""] ; x median, unknown color
red_bar := [-1, red] ; x median, color
last_hotkey := -1
hotbar_keys := 8

; turn this on to see real time tracking of the fish bar
mouse_debug := 0

;================================
;
; Actions is an array of actions which are mapped to the hotbar with information about their pressing time,
; cooldown time, and memory of last time pressed. When making your own for fishing, put the action for
; casting the rod last so your bobber doesn't disappear. The first example is using bait buffs in slots 2 and 3
; and then casting the rod on slot 1. The second example is just how to use the farm with only a rod.
;
; To start the farm start the script and use the hotkey F1
;
; If you run out of buff items the farm will not break but may lose a couple seconds every few minutes.
;
;================================
actions := [[2, 1100, 120000, -1], [3, 1100, 120000, -1], [1, 200, 1, -1]] ; hotbar, press time, cooldown time, last action time
;actions := [[1, 200, 1, -1]] ; hotbar, press time, cooldown time, last action time

throw_line()
{
	global actions
	global last_hotkey

	Sleep, 500 ; Need to sleep here because if there is no delay between catching a fish the cast can fail

	For i, action in actions
	{
		if (A_TickCount - action[4] >= action[3]) ; if action off cooldown, perform action.
		{
			if (last_hotkey != action[1])
			{
				Send, % action[1]
				last_hotkey := action[1]
			}
			Click, Down
			Sleep, % action[2]
			Click, Up
			action[4] := A_TickCount
		}
	}
}

search_line_contains_color(x1, x2, y1, color)
{
	PixelSearch, x,, x1, y1, x2, y1, color,, Fast RGB
	if (x != "")
		return 1
	return 0
}

wait_on_color(x1, x2, y1, color)
{
	thrown := 0
	Loop
	{
		if search_line_contains_color(x1, x2, y1, color)
		{
			return
		}
		else if (thrown == 0)
		{
			throw_line()
			thrown := 1
		}
	}
}

process_bars(x1, x2, y1)
{
	global red_bar
	global fish_bar
	global fish_colors

	color := red_bar[2]
	PixelSearch, first_x,, x1, y1, x2, y1, color,, Fast RGB
	PixelSearch, last_x,, x2, y1, x1, y1, color,, Fast RGB
	red_bar[1] := ((last_x - first_x) // 2) + first_x
	
	for i, color in fish_colors
	{
		if search_line_contains_color(x1, x2, y1, color)
		{
			fish_bar[2] := color
			break
		}
	}
	color := fish_bar[2]
	PixelSearch, first_x,, x1, y1, x2, y1, color,, Fast RGB
	PixelSearch, last_x,, x2, y1, x1, y1, color,, Fast RGB
	if (((last_x - first_x) / 2) >= 1) ; If the red bar is covering a side of the fish box, just use old position
	{
		fish_bar[1] := ((last_x - first_x) // 2) + first_x
	}
}

process_click(red_bar, fish_bar)
{
	global mouse_debug
	global y1

	if (mouse_debug)
	{
		MouseMove, fish_bar[1], y1
	}

	if ((fish_bar[1] - red_bar[1]) > 0)
	{
		Click, Down
	} else
	{
		Click, Up
	}
}

init_hotbar()
{
	global actions
	global last_hotkey
	global hotbar_keys

	first_hotkey := actions[1][1]
	next_hotkey := Mod(first_hotkey, hotbar_keys) + 1
	Send, % next_hotkey
	Send, % first_hotkey
	last_hotkey := first_hotkey
}

F1::
	toggle := !toggle

	if (toggle)
	{
	init_hotbar()	
	}

	While (toggle)
	{
		wait_on_color(x1, x2, y1, red)
		process_bars(x1, x2, y1)
		process_click(red_bar, fish_bar)
	}
	return

F2::
	MouseGetPos, m_x, m_y
	WinGetPos,,, w_w, w_h, A
	PixelSearch, x,, 0, m_y, % w_w // 2, m_y, white,, Fast RGB
	b_x1 := x + 2
	PixelSearch, x,, w_w, m_y, % w_w // 2, m_y, white,, Fast RGB
	b_x2 := x - 2
	MsgBox, % "Bounding area for fishing box with cursor as y value:`nx1: " . b_x1 . "`nx2: " . b_x2 . "`ny1: " . m_y
	return