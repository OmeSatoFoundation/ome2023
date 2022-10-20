#ifndef __rpz-fabo__
#define __rpz-fabo__

#module
#deffunc oled str _s1
	;gpmes _s1
	update 1
	exec "/home/pi/ome/bin/./oled \""+_s1+"\""
	;gpmes "./oled \""+_s1+"\""
	return 0

#defcfunc rasp_map int _x, int _in_min, int _in_max, int _out_min, int _out_max
	if (_in_max - _in_min) + _out_min < 0 : return 0
	_value=(_x - _in_min)*(_out_max - _out_min) / (_in_max - _in_min) + _out_min
	return _value

#global

#endif