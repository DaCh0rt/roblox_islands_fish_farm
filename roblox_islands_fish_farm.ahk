; Ian Harvey
#MaxThreadsPerHotkey 3

;================================
;
; This is the bounding box around the fishing interface. It should be centered and almost touch
; the end of the bar without including the white outline. You can use windows spy included with
; the AHK download to find the coordinates of your window and fill them in below.
;
;================================
y1 := 782
x1 := 640
y2 := 784
x2 := 1300

red := 0x6969FF ;BGR
white := 0xFFFFFF ;BGR
c_ranges := [[-1, red], [-1, white]] ; median, color
last_hotkey := -1

;================================
;
; Actions is an array of actions which are mapped to the hotbar with information about its pressing time,
; cooldown time, and memory of last time pressed. When making your own for fishing, put the action for
; casting the rod last so your bobber doesn't disappear. The first example is using bait buffs in slots 2 and 3
; and then casting the rod on slot 1. The second example is just how to use the farm with only a rod.
;
; To start the farm start the script and use the hotkey Shift+`
;
; The script must be started with the first action hotbar item NOT selected. If you run out of buff items the
; farm will not break but may lose a couple seconds every few minutes.
;
;================================
;actions := [[2, 1100, 120000, -1], [3, 1100, 120000, -1], [1, 200, 50, -1]] ; hotbar, action cooldown time, last action time
actions := [[1, 200, 50, -1]] ; hotbar, action cooldown time, last action time

throw_line()
{
	global actions
	global last_hotkey

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

search_line_contains_color(x1, y1, x2, y2, color)
{
	PixelSearch, x, y, x1, y1, x2, y2, color,,Fast
	if (x != "")
		return 1
	return 0
}

wait_on_color(x1, y1, x2, y2, color)
{
	thrown := 0
	Loop
	{
		if search_line_contains_color(x1, y1, x2, y2, color){
			return
		}
		else if (thrown == 0){
			throw_line()
			thrown := 1
		}
	}
}

process_c_ranges(x1, y1, x2, y2, c_ranges)
{
	For i, c_range in c_ranges
	{
		color := c_range[2]

		PixelSearch, first_c, y, x1, y1, x2, y2, color,, Fast
		PixelSearch, last_c, y, x2, y2, x1, y1, color,, Fast

		c_range[1] := ((last_c - first_c) // 2) + first_c
	}
}

process_click(c_ranges)
{
	if ((c_ranges[2][1] - c_ranges[1][1]) > 0)
	{
		Click, Down
	} else
	{
		Click, Up
	}
}

+`::			; Start with Shift+`
	toggle := !toggle
	Loop
	{
		if (!toggle)
		{
			break
		}

		wait_on_color(x1, y1, x2, y2, red)
		process_c_ranges(x1, y1, x2, y2, c_ranges)
		process_click(c_ranges)
	}

;Esc::ExitApp	; Exit script with Escape key