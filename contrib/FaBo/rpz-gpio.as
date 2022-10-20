;	RPZ-Sensor Raspberry Pi module
#ifndef __rpz-gpio__
#define __rpz-gpio__

	;	RPZ-Sensor用の拡張コマンドを定義するファイルです
	;	#include "rpz-gpio.as"
	;	を先頭に入れて使用してください
	;

#module

#deffunc getnotestr var _p1, str _p2

	;	getnotestr 取得先変数, "検索文字列"
	;	noteselで指定した文字列バッファの中から
	;	"検索文字列"で指定した文字列で始まる行の内容を取得する
	;	結果は取得先変数に代入される
	;	該当文字列がなかった場合は""が代入される
	;
	s1=_p2				; 検索文字列
	s1len=strlen(s1)		; s1の長さ(byte)を取得
 	s1res=notefind(s1,1)		; s1で始まる行を検索
	if s1res<0 : _p1="" : return	; 該当行なし
	noteget s2,s1res		; 該当行を取得
	_p1=strmid(s2,s1len,255)	; 検索文字列以降を取得
	return

#deffunc geti2c

	;	geti2c
	;	rpz-sensorボードのI2C関連情報を取得する
	;	(rpz-sensorコマンドを使用、取得までラグがあります)
	;	以下の変数に結果が代入されます(すべて実数型になります)
	;	(温度) rpz_temp
	;	(気圧) rpz_pressure
	;	(湿度) rpz_humidity
	;	(照度) rpz_lux
	;
	exec "/home/pi/ome/bin/rpz-sensor >result.txt"
	notesel msg
	noteload "result.txt"		; result.txtを取り込む
	getnotestr res," Temp :"	; Tempの行内容をresに取得
	rpz_temp@=0.0+res
	getnotestr res," Pressure :"	; Pressureの行内容をresに取得
	rpz_pressure@=0.0+res
	getnotestr res," Humidity :"	; Humidityの行内容をresに取得
	rpz_humidity@=0.0+res
	getnotestr res," Lux :"		; Luxの行内容をresに取得
	rpz_lux@=0.0+res
	return 0

#deffunc init_bme
  i2cch_bme = 0
	static_cal_dig_T1 = 0
	static_cal_dig_T2 = 0
	static_cal_dig_T3 = 0
	static_cal_dig_P1 = 0
	static_cal_dig_P2 = 0
	static_cal_dig_P3 = 0
	static_cal_dig_P4 = 0
	static_cal_dig_P5 = 0
	static_cal_dig_P6 = 0
	static_cal_dig_P7 = 0
	static_cal_dig_P8 = 0
	static_cal_dig_P9 = 0
	static_cal_dig_H1 = 0
	static_cal_dig_H2 = 0
	static_cal_dig_H3 = 0
	static_cal_dig_H4 = 0
	static_cal_dig_H5 = 0
	static_cal_dig_H6 = 0
	; TODO: slave address (0x77) should be variable.
	; 0x76: external BME280
	; 0x77: onboard BME280
	devcontrol "i2copen", 0x76, i2cch_bme
	if stat {
		devcontrol "i2copen", 0x77, i2cch_bme
		if stat: return 1
		buf = "外付けBME280の初期化に失敗したため、基板上のBME280を使用しています。"
		notesel buf
		notesave "/dev/stdout"
	}

	; *** get calibration data ***
	; dig_T1
	devcontrol "i2cwrite", 0x88, 1, i2cch_bme
	if stat {
		devcontrol "i2copen", 0x77, i2cch_bme
		if stat: return 2
		buf = "外付けBME280の初期化に失敗したため、基板上のBME280を使用しています。\n"
		notesel buf
		notesave "/dev/stdout"
		devcontrol "i2cwrite", 0x88, 1, i2cch_bme
	}
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_T1 = stat

	; dig_T2
	devcontrol "i2cwrite", 0x8A, 1, i2cch_bme
	if stat: return 3
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_T2 = get_signed16(stat)

	; dig_T3
	devcontrol "i2cwrite", 0x8C, 1, i2cch_bme
	if stat: return 4
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_T3 = get_signed16(stat)

	; dig_P1
	devcontrol "i2cwrite", 0x8E, 1, i2cch_bme
	if stat: return 5
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P1 = stat

	; dig_P2
	devcontrol "i2cwrite", 0x90, 1, i2cch_bme
	if stat: return 6
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P2 = get_signed16(stat)

	; dig_P3
	devcontrol "i2cwrite", 0x92, 1, i2cch_bme
	if stat: return 7
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P3 = get_signed16(stat)

	; dig_P4
	devcontrol "i2cwrite", 0x94, 1, i2cch_bme
	if stat: return 8
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P4 = get_signed16(stat)

	; dig_P5
	devcontrol "i2cwrite", 0x96, 1, i2cch_bme
	if stat: return 9
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P5 = get_signed16(stat)

	; dig_P6
	devcontrol "i2cwrite", 0x98, 1, i2cch_bme
	if stat: return 10
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P6 = get_signed16(stat)

	; dig_P7
	devcontrol "i2cwrite", 0x9A, 1, i2cch_bme
	if stat: return 11
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P7 = get_signed16(stat)

	; dig_P8
	devcontrol "i2cwrite", 0x9C, 1, i2cch_bme
	if stat: return 12
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P8 = get_signed16(stat)

	; dig_P9
	devcontrol "i2cwrite", 0x9E, 1, i2cch_bme
	if stat: return 13
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_P9 = get_signed16(stat)

	; dig_H1
	devcontrol "i2cwrite", 0xA1, 1, i2cch_bme
	if stat: return 14
	devcontrol "i2cread", i2cch_bme
	static_cal_dig_H1 = stat

	; dig_H2
	devcontrol "i2cwrite", 0xE1, 1, i2cch_bme
	if stat: return 15
	devcontrol "i2creadw", i2cch_bme
	static_cal_dig_H2 = get_signed16(stat)

	; dig_H3
	devcontrol "i2cwrite", 0xE3, 1, i2cch_bme
	if stat: return 16
	devcontrol "i2cread", i2cch_bme
	static_cal_dig_H3 = stat

	devcontrol "i2cwrite", 0xE5, 1, i2cch_bme
	if stat: return 17
	devcontrol "i2cread", i2cch_bme
	h4h5lower = stat

	h4lower = (0x0F & h4h5lower)
	h5lower = (0xF0 & h4h5lower) >> 4

	; dig_H4
	devcontrol "i2cwrite", 0xE4, 1, i2cch_bme
	if stat : return 18
	devcontrol "i2cread", i2cch_bme
	static_cal_dig_H4 = get_signed12((stat << 4) | h4lower)

	; dig_H5
	devcontrol "i2cwrite", 0xE6, 1, i2cch_bme
	if stat : return 19
	devcontrol "i2cread", i2cch_bme
	static_cal_dig_H5 = get_signed12((stat << 4) | h5lower)

	; dig_H6
	devcontrol "i2cwrite", 0xE7, 1, i2cch_bme
	if stat : return 20
	devcontrol "i2cread", i2cch_bme
	static_cal_dig_H6 = get_signed8(stat)

  if stat : return 0


#defcfunc get_signed16 int uint
	res = uint
	if uint>32767: res = uint-65536
	return res

#defcfunc get_signed8 int uint
	res = uint
	if uint>127: res = uint-256
	return res

#defcfunc get_signed12 int uint
	res = uint
	if uint>2047: res = uint-4096
	return res

#defcfunc force_bme int i2cch, array THP
	devcontrol "i2cwrite", 0x00F5, 2, i2cch
	if stat: return 1
	devcontrol "i2cwrite", 0x05F2, 2, i2cch
	if stat: return 2
	devcontrol "i2cwrite", 0xB5F4, 2, i2cch
	if stat: return 3

	; read status
	; wait for measuring is 0
	devcontrol "i2cwrite", 0xF3, 1, i2cch
	if stat : return 4
	devcontrol "i2cread", i2cch
	status = stat
	while (status & 0x08 != 0)
		devcontrol "i2cwrite", 0xF3, 1, i2cch
		if stat : return 5
		devcontrol "i2cread", i2cch
		status = stat
	wend

	readdatalen = 8
	readdataaddr = 0xF7
	dim data, readdatalen

	repeat readdatalen
		devcontrol "i2cwrite", readdataaddr, 1, i2cch
		if stat : return 6
		devcontrol "i2cread", i2cch
		data(cnt) = stat
		readdataaddr++
	loop

	adc_T = (data(3) << 12) + (data(4) << 4) + (data(5) >> 4)
	adc_H = (data(6)<<8) + data(7)
	adc_P = (data(0)<<12) + (data(1)<<4) + (data(2)>>4)

	THP(0) = adc_T
	THP(1) = adc_H
	THP(2) = adc_P
	return 0

#deffunc get_temp
  i2cch_temp = 0
	static_t_fine = 0

	dim data, 3
	status = force_bme(i2cch_temp, data)
	; TODO: error handling using `status`
	adc_T = data(0)

	var1 = (((adc_T>>3) - (static_cal_dig_T1<<1)) * (static_cal_dig_T2)) >> 11
	var2  = (((((adc_T>>4) - (static_cal_dig_T1)) * ((adc_T>>4) - (static_cal_dig_T1))) >> 12) * (static_cal_dig_T3)) >> 14
	static_t_fine = var1 + var2
	temp = double((static_t_fine * 5 + 128) >> 8)/100.0
  rpz_temp@=temp
	return

#deffunc get_humidity
  i2cch_hum = 0
	dim data, 3
	status = force_bme(i2cch_hum, data)
	; TODO: error handling using `status`
	adc_H = data(1)
	v_x1_u32r = (staic_t_fine - 76800)
	v_x1_u32r = (((((adc_H << 14) - ((static_cal_dig_H4) << 20) - ((static_cal_dig_H5) * v_x1_u32r)) + 16384) >> 15) * (((((((v_x1_u32r * static_cal_dig_H6) >> 10) * (((v_x1_u32r * static_cal_dig_H3) >> 11) + 32768)) >> 10) + 2097152) * static_cal_dig_H2 + 8192) >> 14))
	v_x1_u32r = (v_x1_u32r - (((((v_x1_u32r >> 15) * (v_x1_u32r >> 15)) >> 7) * static_cal_dig_H1) >> 4))
	if v_x1_u32r < 0: v_x1_u32r = 0
	if v_x1_u32r > 419430400: v_x1_u32r = 419430400
	res = double(v_x1_u32r>>12)/1024.0
  rpz_hum@=res
	return

#deffunc get_pressure
  i2cch_press = 0
	; need 64bit integer
	dim data, 3
	status = force_bme(i2cch_press, data)
	; TODO: error handling using `status`
	adc_P = data(2)

	var1 = ((static_t_fine) >> 1) - 64000
	var2 = (((var1 >> 2) * (var1 >> 2)) >> 11) * static_cal_dig_P6
	var2 = var2 + ((var1 * static_cal_dig_P5) << 1)
	var2 = (var2 >> 2) + (static_cal_dig_P4 << 16)
	var1 = (((static_cal_dig_P3 * (((var1>>2) * (var1>>2)) >> 13 )) >> 3) + (((static_cal_dig_P2) * var1)>>1))>>18
	var1 = ((((32768+var1))*(static_cal_dig_P1))>>15)

	if var1 == 0 : return 0  ; avoid zero-division exception

	p = ((((1048576)-adc_P)-(var2>>12)))*3125
	if p < 0x80000000 {
		p = (p << 1) / var1
	}else{
		p = (p / var1) * 2
	}
	var1 = ((static_cal_dig_P9) * ((((p>>3) * (p>>3))>>13)))>>12
	var2 = (((p>>2)) * (static_cal_dig_P8))>>13
	res = (p + ((var1 + var2 + static_cal_dig_P7) >> 4))
  rpz_press@=double(res)/100.0
	return

#deffunc geti2c_lux_init

	;	geti2c_lux_init
	;	rpz-sensorボードの照度センサーTSL2561を初期化します
	;	(最初の1回だけ実行してください、以降はgeti2c_luxで更新できます)
	;
  init_lux(1)
	return 0

#deffunc geti2c_lux

	;	geti2c_lux
	;	(照度) rpz_luxを高速に取得
	;
	rpz_lux@=0+get_lux_fixed(1)			; 16bit整数でセンサー値を取得
	return

#deffunc geti2c_lux_als

  ; geti2c_lux
  ; ルクス単位に近い値を返します
  ;
  rpz_lux@=get_lux(1)
  return

#deffunc init_lux int _ch
	devcontrol "i2copen",0x39,_ch	; TSL2572を初期化
	if stat : return 1
	wait 40
	return
	
#defcfunc max var _p1, var _p2
	if _p1 > _p2 : return _p1 : else : return _p2
	return 0

#deffunc set int _p1, int _p2, int _ch
	if(_p1 == 0){
		devcontrol "i2cwrite",0x048D, 2, _ch
		devcontrol "i2cwrite",0x008F, 2, _ch
	}else : if (_p1 == 1){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x008F, 2, _ch
	}else : if (_p1 == 2){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x018F, 2, _ch
	}else : if (_p1 == 3){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x028F, 2, _ch
	}else : if (_p1 == 4){
		devcontrol "i2cwrite",0x008D, 2, _ch
		devcontrol "i2cwrite",0x038F, 2, _ch
	}
	
	devcontrol "i2cwrite",(_p2<<8)|0x0081, 2, _ch // set time
	return
	

#deffunc integration int _again, int _atime, int _ch, array _data
	devcontrol "i2cwrite",0x0180,2, _ch
	if stat : return 1
	set _again, _atime, _ch
	devcontrol "i2cwrite",0x0380,2, _ch
	if stat : return 1
	wait 40
	repeat
		devcontrol "i2cwrite",0x93, 1, _ch
		devcontrol "i2cread", _ch
		status=0+stat
		if( (status&0x1 == 1) && ((status&0x10)>>4)==1){
			devcontrol "i2cwrite",0x0180,2,_ch
			break
			}
		else : wait 100
	loop
	devcontrol "i2cwrite",0x14|0xA0,1, _ch
	devcontrol "i2creadw", _ch	
	_data(0) = stat
	devcontrol "i2cwrite",0x16|0x80,1, _ch
	devcontrol "i2creadw", _ch
	_data(1) = stat

	return 

#defcfunc calc_lux int _again, int _atime, int _ch0, int _ch1
	if(_again == 0){ g = 0.16 }
	else : if (_again == 1){ g = 1.0 }
	else : if (_again == 2){ g = 8.0 }
	else : if (_again == 3){ g = 16.0 }
	else : if (_again == 4){ g = 120.0 }
	
	if(_atime == 0xED){ t = 50.0 }
	else : if(_atime == 0xB6){ t = 200.0 }
	else : if(_atime == 0x24){ t = 600.0 }
	
	cpl = (t*g)/60.0

	lux1 = (double(_ch0) - 1.87*double(_ch1)) / cpl
	lux2 = (0.63*double(_ch0) - double(_ch1)) / cpl
	return max(lux1, lux2)
	
#defcfunc get_lux int ch
	again = 1
	atime = 0xB6
	
	integration again,atime,ch, data

	ch0 = data(0)
	ch1 = data(1)

	if(max(ch0,ch1) == 65535){
		again = 0
		atime = 0xED
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 100){
		again = 4
		atime = 0x24
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 300){
		again = 4
		atime = 0xB6
		integration again,atime,ch, data
	} else : if(max(ch0,ch1) < 3000){
		again = 2
		atime = 0xB6
		integration again,atime,ch, data
	}

	devcontrol "i2cwrite",0x0180,2,ch
	
	ch0 = data(0)
	ch1 = data(1)

	lux = calc_lux(again, atime, ch0, ch1)

	return lux

#defcfunc get_lux_fixed int ch
	again = 2
	atime = 0xB6

	integration again,atime,ch, data

	ch0 = data(0)
	ch1 = data(1)

	return ch0

#deffunc oled str _s1
	;gpmes _s1
	;update 1
	wait 1
	exec "/home/pi/ome/bin/./oled \""+_s1+"\""
	;gpmes "./oled \""+_s1+"\""
	return 0

#defcfunc rasp_map int _x, int _in_min, int _in_max, int _out_min, int _out_max
	_value=(_x - _in_min)*(_out_max - _out_min) / (_in_max - _in_min) + _out_min
	return _value

#global

	i2c_stat=0
	_umsg=""

#endif
