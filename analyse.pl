#!/usr/bin/perl
#

my $log = $ARGV[0];
open (FILE, "<${log}") || die $!;

while (my $row = <FILE>) {
	if ($row =~ /'_type': 'scan ([^']*)', '_stamp': '([^']*)'/) {
		my $pid = $1;
		my $timestamp = $2;
		$row =~ /'value': '([^']*)'/;
		my $value = $1;
		$value =~ s/\\n/\n/g;

		print "pid $pid @ $timestamp\n";

		for my $line (split /^/, $value) {
			$line =~ s/\s+$//;
			if ($line =~ /^...10/) {
				next;
			}
			my $spacedline;
			my $count = 0;
			for my $c (split //, $line) {
				if ($count == 3) {
					$spacedline = $spacedline." ";
				}
				if ($count > 3 && (($count-1)%2) == 0) {
					$spacedline = $spacedline." ";
				}
				$spacedline = $spacedline.$c;
				$count++;
			}

			$olde=$e;
			$oldf=$f;
			$oldg=$g;
			$a = hex(substr($line,5,2));
			$b = hex(substr($line,7,2));
			$c = hex(substr($line,9,2));
			$d = hex(substr($line,11,2));
			$e = hex(substr($line,13,2));
			$f = hex(substr($line,15,2));
			$g = hex(substr($line,17,2));

			# 7A0/7A8 - BCM / TPMS

			if ($pid eq "22c00b") {
				if ($line =~ /^7A821/) {
					$spacedline = "BCM ".$spacedline." [?=".$a."] [Tyre Pre_FL=".($b/5.0)."] [Tyre Temp_FL=".($c-50.0)."] [?=".$d."] [?=".$e."] [Tyre Pre_FR=".($f/5.0)."] [Tyre Temp_FR=".($g-50.0)."]";
				}
				if ($line =~ /^7A822/) {
					$spacedline = "BCM ".$spacedline." [?=".$a."] [?=".$b."] [Tyre Pre_RR=".($c/5.0)."] [Tyre Temp_RR=".($d-50.0)."] [?=".$e."] [?=".$f."] [Tyre Pre_RL=".($g/5.0)."]";
				}
				if ($line =~ /^7A823/) {
					$spacedline = "BCM ".$spacedline." [Tyre Temp_RL=".($a-50.0)."] [?=".$b."] [?=".$c."] [?=".$d."] [PAD] [PAD] [PAD] [PAD]";
				}
			}

			if ($pid eq "22c002") {
				if ($line =~ /^7A821/) {
					$spacedline = "BCM ".$spacedline." [?=".$a."] [TPMS ID 0=".($b*16777216+$c*65536+$d*256+$e)."]";
				}
				if ($line =~ /^7A822/) {
					$spacedline = "BCM ".$spacedline."[TPMS ID 1=".($oldf*16777216+$oldgc*65536+$a*256+$b)."] [TPMS ID 2=".($c*16777216+$d*65536+$e*256+$f)."]";
				}
				if ($line =~ /^7A823/) {
					$spacedline = "BCM ".$spacedline."[TPMS ID 3=".($oldf*16777216+$a*65536+$c*256+$c)."] [PAD] [PAD] [PAD] [PAD]"
				}
			}

			if ($pid eq "22b00c") {
				if ($line =~ /^7A821/) {
					$spacedline = "BCM ".$spacedline." [?=".$a."] [Heated Handle=".(($b&0x20)>>5)."] [?=".$c."] [?=".$d."] [?=".$e."] [PAD] [PAD]";
				}
			}

			if ($pid eq "22b00e") {
				if ($line =~ /^7A821/) {
					$spacedline = "BCM ".$spacedline." [?=".$a."] [Charge port=".(($b&0x10)>>4)."] [?=".$c."] [?=".$d."] [?=".$e."] [PAD] [PAD]";
				}
			}

			# 7E2/7EA - VCU/VMCU - Vehicle Motor Control System
			
			if ($pid eq "2101") {
				if ($line =~ /^7EA21/) {
					$gear="";
					if (($b&0x0f) == 1) {
						$gear="P";
					} elsif (($b&0x0f) == 2) {
						$gear="R";
					} elsif (($b&0x0f) == 4) {
						$gear="N";
					} elsif (($b&0x0f) == 8) {
						$gear="D";
					}
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [Gear=".$gear."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA22/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [Speed=".(($b*256+$c)/10.0)."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA23/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			if ($pid eq "2102") {
				if ($line =~ /^7EA21/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA22/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA23/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [AUXBATTV=".(($c*256+$b)/1000.0)."] [AUXBATTC=".(($e*256+$d)/1000.0)."] [AUXBATTSOC=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA24/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EA25/) {
					$spacedline = "VMCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			# 7C6 / 7CE - CLU
			
			if ($pid eq "22b002") {
				if ($line =~ /^7CE21/) {
					$spacedline = "CLU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7CE22/) {
					$spacedline = "CLU ".$spacedline." [odometer=".($a*256+$b)."] [PAD] [PAD] [PAD] [PAD] [PAD]";
				}
			}

			# 770 / 778 - IGMP
			
			if ($pid eq "22bc03") {
				if ($line =~ /^77821/) {
					$spacedline = "IGMP ".$spacedline." [?=".$a."] [Trunk door=".(($b&0x80)>>7)."] [FL door=".(($b&0x20)>>5)."] [FR door=".(($b&0x10)>>4)."] [RL door=".(($b&0x01))."] [RR door=".(($b&0x04)>>2)."] [Hood=".($c&0x01)."] [On=".($c&0x60)."] [Belt Driver=".(($c&0x02)>>1)."] [Belt Passenger=".(($c&0x04)>>2)."] [?=".$d."] [?=".$e."] [PAD] [PAD]"
				}
			}

			if ($pid eq "22bc04") {
				if ($line =~ /^77821/) {
					$spacedline = "IGMP ".$spacedline." [?=".$a."] [FL Door Lock=".(($b&0x08)>>3)."] [FR Door Lock=".(($b&0x04)>>2)."] [?=".$c."] [?=".$d."] [Belt BL=".(($e&0x04)>>2)."] [Belt BM=".(($e&0x08)>>3)."] [Belt BR=".(($e&0x10)>>4)."] [Lights=".(($f&0x10)>>4)."] [PAD]"
				}
			}

			if ($pid eq "22bc07") {
				if ($line =~ /^77821/) {
					$spacedline = "IGMP ".$spacedline." [?=".$a."] [?=".$b."] [DeFog=".$c."] [?=".$d."] [?=".$e."] [PAD] [PAD]"
				}
			}
			# 7E3/7EB - MCU

			if ($pid eq "2101") {
				if ($line =~ /^7EB21/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB22/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB23/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB24/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}
			
			if ($pid eq "2102") {
				if ($line =~ /^7EB21/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB22/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [Inv Temp=".$d."] [Mot Temp=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB23/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB24/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB25/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB26/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB27/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EB28/) {
					$spacedline = "MCU ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			# 7E4/7EC - BMS

			if ($pid eq "220101") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [SOCBMS=".($b/2.0)."] [MAXREGEN=".(($c*256+$d)/100.0)."] [MAXPOWER=".(($e*256+$f)/100.0)."] [BMS?=".$g."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [BATTCURR=".(unpack('s',pack('S',$a*256+$b)))/10.0."] [BATTVOLTS=".(($c*256+$d)/10.0)."] [BATTPOWER=".(((unpack('s',pack('S',$a*256+$b)))/10.0)*(($c*256+$d)/10.0)/1000.0)."] [BATTMAXT=".(unpack('s',pack('S',$e)))."] [BATTMINT=".(unpack('s',pack('S',$f)))."] [BATTTEMP1=".(unpack('s',pack('S',$g)))."]";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [BATTTEMP2=".(unpack('s',pack('S',$a)))."] [BATTTEMP3=".(unpack('s',pack('S',$b)))."] [BATTTEMP4=".(unpack('s',pack('S',$c)))."] [BATTTEMP5=".(unpack('s',pack('S',$d)))."] [?] [BATTINLETT=".(unpack('s',pack('S',$f)))."] [MAXCELLV=".($g/50.0)."]";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [MAXCELVNO=".$a."] [MINCELLV=".($b/50.0)."] [MINCELLNO=".$c."] [BATTFANSPD=".$d."] [BATTFANMOD=".$e."] [AUXBATTV=".($f/10.0)."]";
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [CCC=".(($oldg*16777216+$a*65536+$b*256+$c)/10.0)."] [CDC=".(($d*16777216+$e*65536+$f*256+$g)/10.0)."]";
				}
				if ($line =~ /^7EC26/) {
					$spacedline = "BMS ".$spacedline." [CEC=".(($a*16777216+$b*65536+$c*256+$d)/10.0)."]";
				}
				if ($line =~ /^7EC27/) {
					$spacedline = "BMS ".$spacedline." [CED=".(($olde*16777216+$oldf*65536+$oldg*256+$a)/10.0)."] [OPTIME=".(($b*16777216+$c*65536+$d*256+$e)/3600.0)."] [?BMSIGN=".$f."]";
				}
				if ($line =~ /^7EC28/) {
					$spacedline = "BMS ".$spacedline." [BMSCAP=".($oldg*256+$a)."] [RPM1=".($b*256+$c)."] [RPM2=".($d*256+$e)."] [SURGER=".($f*256+$g)."]";
				}
			}

			if ($pid eq "220102") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [CELLV01=".($b/50)."] [CELLV02=".($c/50)."] [CELLV03=".($d/50)."] [CELLV04=".($e/50)."] [CELLV05=".($f/50)."] [CELLV06=".($g/50)."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [CELLV07=".($a/50)."] [CELLV08=".($b/50)."] [CELLV09=".($c/50)."] [CELLV10=".($d/50)."] [CELLV11=".($e/50)."] [CELLV12=".($f/50)."] [CELLV13=".($g/50)."] ";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [CELLV14=".($a/50)."] [CELLV15=".($b/50)."] [CELLV16=".($c/50)."] [CELLV17=".($d/50)."] [CELLV18=".($e/50)."] [CELLV19=".($f/50)."] [CELLV20=".($g/50)."] ";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [CELLV21=".($a/50)."] [CELLV22=".($b/50)."] [CELLV23=".($c/50)."] [CELLV24=".($d/50)."] [CELLV25=".($e/50)."] [CELLV26=".($f/50)."] [CELLV27=".($g/50)."] ";
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [CELLV28=".($a/50)."] [CELLV29=".($b/50)."] [CELLV30=".($c/50)."] [CELLV31=".($d/50)."] [CELLV32=".($e/50)."] [PAD] [PAD] ";
				}
			}

			if ($pid eq "220103") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [CELLV33=".($b/50)."] [CELLV34=".($c/50)."] [CELLV35=".($d/50)."] [CELLV36=".($e/50)."] [CELLV37=".($f/50)."] [CELLV38=".($g/50)."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [CELLV39=".($a/50)."] [CELLV40=".($b/50)."] [CELLV41=".($c/50)."] [CELLV42=".($d/50)."] [CELLV43=".($e/50)."] [CELLV44=".($f/50)."] [CELLV45=".($g/50)."] ";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [CELLV46=".($a/50)."] [CELLV47=".($b/50)."] [CELLV48=".($c/50)."] [CELLV49=".($d/50)."] [CELLV50=".($e/50)."] [CELLV51=".($f/50)."] [CELLV52=".($g/50)."] ";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [CELLV53=".($a/50)."] [CELLV54=".($b/50)."] [CELLV55=".($c/50)."] [CELLV56=".($d/50)."] [CELLV57=".($e/50)."] [CELLV57=".($f/50)."] [CELLV59=".($g/50)."] ";
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [CELLV60=".($a/50)."] [CELLV61=".($b/50)."] [CELLV62=".($c/50)."] [CELLV63=".($d/50)."] [CELLV64=".($e/50)."] [PAD] [PAD] ";
				}
			}

			if ($pid eq "220104") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [CELLV65=".($b/50)."] [CELLV66=".($c/50)."] [CELLV67=".($d/50)."] [CELLV68=".($e/50)."] [CELLV69=".($f/50)."] [CELLV70=".($g/50)."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [CELLV71=".($a/50)."] [CELLV72=".($b/50)."] [CELLV73=".($c/50)."] [CELLV74=".($d/50)."] [CELLV75=".($e/50)."] [CELLV76=".($f/50)."] [CELLV77=".($g/50)."] ";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [CELLV78=".($a/50)."] [CELLV79=".($b/50)."] [CELLV80=".($c/50)."] [CELLV81=".($d/50)."] [CELLV82=".($e/50)."] [CELLV83=".($f/50)."] [CELLV84=".($g/50)."] ";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [CELLV85=".($a/50)."] [CELLV86=".($b/50)."] [CELLV87=".($c/50)."] [CELLV88=".($d/50)."] [CELLV89=".($e/50)."] [CELLV90=".($f/50)."] [CELLV91=".($g/50)."] ";
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [CELLV92=".($a/50)."] [CELLV93=".($b/50)."] [CELLV94=".($c/50)."] [CELLV95=".($d/50)."] [CELLV96=".($e/50)."] [PAD] [PAD] ";
				}
			}

			if ($pid eq "220105") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [VDIFF=".($d/50)."] [?] [AIRBAG=".$f."] [HEATERTEMP1=".$g."]";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [HEATERTEMP2=".$a."] [SOH=".(($b*256+$c)/10.0)."] [MAXDETNO=".$d."] [MINDET=".(($e*256+$f)/10.0)."] [MINDETNO=".$g."]"
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [SOCDISPLAY=".($a/2.0)."] [?] [?] [CELLV97=".($d/50)."] [CELLV98=".($e/50)."] [PAD] [PAD]";
				}
				if ($line =~ /^7EC26/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [PAD] [PAD]";
				}
			}

			if ($pid eq "220106") {
				if ($line =~ /^7EC21/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [COOLING=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC22/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC23/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC24/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7EC25/) {
					$spacedline = "BMS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [PAD] [PAD]";
				}
			}
			
			# 7E5/7ED - OBC
			if ($pid eq "2101") {
				if ($line =~ /^7ED21/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED22/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED23/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED24/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [Pilot duty=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED25/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED26/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [Charge temp=".(($d/2.0)-40.0)."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED27/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [Main batt v=".(($d*256+$e)/10)."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED28/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			if ($pid eq "2103") {
				if ($line =~ /^7ED21/) {
					$spacedline = "OBC ".$spacedline." [AC Current=".(($a*256+$b)/100)."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED22/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED23/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED24/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [Pilot duty=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED25/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED26/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7ED27/) {
					$spacedline = "OBC ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}
			
			# 7E6/7EE 

			# 7B3/7BB - AirCon
			if ($pid eq "220100") {
				if ($line =~ /^7BB21/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [INDOORTEMP=".(($c/2)-40)."] [OUTDOORTEMP=".(($d/2)-40)."] [EVAPORATORTEMP?=".(($e/2)-40)."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB22/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB23/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB24/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [speed?=".($f/1.609)."] [?=".$g."]";
				}
				if ($line =~ /^7BB25/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			if ($pid eq "220102") {
				if ($line =~ /^7BB21/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [Coolant 1=".$b."] [Coolant 2=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB22/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB23/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB24/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7BB25/) {
					$spacedline = "AirCon ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			# 7D1/7D9 ABS ESP
			if ($pid eq "220100") {
				if ($line =~ /^7D921/) {
					$spacedline = "ABS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7D922/) {
					$spacedline = "ABS ".$spacedline." [?=".$a."] [?=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
				if ($line =~ /^7D923/) {
					$spacedline = "ABS ".$spacedline." [Traction control=".$a."] [Emerg lights=".$b."] [?=".$c."] [?=".$d."] [?=".$e."] [?=".$f."] [?=".$g."]";
				}
			}

			print "$spacedline\n";
		}

		print "\n";
	}
}
