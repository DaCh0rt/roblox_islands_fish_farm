; Ian Harvey
#MaxThreadsPerHotkey 3

line_hotkey = 6
red := 0x6969FF ;BGR
white := 0xFFFFFF ;BGR
y1 := 782
x1 := 640
y2 := 784
x2 := 1300

c_ranges := [[-1, red], [-1, white]] ; median, color

throw_line()
{
	Send, % line_hotkey
	Sleep, 100
	Send, % line_hotkey
	Sleep, 100
	Click, Down
	Sleep, 200
	Click, Up
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