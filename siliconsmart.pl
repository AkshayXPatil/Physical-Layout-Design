#!/usr/bin/perl -w

##########Remove old char_dir #######################
if (-d "./char_dir")
{
system "chmod 775 -R *";
system "rm -rf char_dir";
print("Deleting the old files..........\n\n");
}
##########Start Silicon Smart and generate the char_dir ########################
print("Now creating new Characterization Directory..........\n\n");

##########Generate the TCL script for setup #####################
open(SCRIPT, ">./setup.tcl") or die "could not open the script file to write!";
print SCRIPT "create char_dir\n";
print SCRIPT "set_location char_dir\n";

# prompt and receive cell names,spice netlist and I/Os
print "******************************************************************************\n";
print "******************************************************************************\n";
print "PLEASE ENTER INPUT AND OUTPUT PIN NAMES IN CAPITAL FORMAT\n";
print "******************************************************************************\n";
print "******************************************************************************\n";
print "Please enter the total number of cells :";
$cellNum = <STDIN>;
chomp($cellNum);

for ($i = 0; $i < $cellNum; $i++)
{
	print("Please enter a cell name or enter dff for Flip-Flop data :");
	$cellName=<STDIN>;
	chomp ($cellName);
        if ($cellName eq "dff" ) 
	{
	dff_data();
	}
        else
	{
	print("please enter the name of spice netlist file <filename.pex.sp> of the cell :");
	$input = <STDIN>;
	chomp($input);
	$cellnetlist{$cellName} = $input;

	print("Please enter the no of input pins :");
	$input_count = <STDIN>;
	chomp($input_count);
	$cellInputCountHash{$cellName} = $input_count;
		for ($j=0;$j<$input_count;$j++)
		{
			print ("Please enter input ",$j+1,": ");
			$in[$j]= <STDIN>;
			chomp($in[$j]);
		}
	$cellInputHash{$cellName} = [@in];

	print("Please enter the output pin name(s) seperated by spaces :");
	$input = <STDIN>;
	chomp($input);
	$cellOutputHash{$cellName} = $input;
	
	print("Please enter cell area :");
	$input = <STDIN>;
	chomp($input);
	$cellAreaHash{$cellName} = $input;

	print("Please enter a cell function :");
	$input=<STDIN>;
	chomp ($input);
	$cellFunctionHash{$cellName} = $input;
	
        }
}


sub dff_data
{
$dff=1;
	print("Enter the DFF name :");
	$cellName=<STDIN>;
	chomp ($cellName);
        $dffname = $cellName;

	print("please enter the name of spice netlist file <filename.sp> of the DFF cell :");
	$input = <STDIN>;
	chomp($input);
	$DFFnetlist = $input;

	print("Please enter the Data pin name :");
	$dinput = <STDIN>;
	chomp($dinput);
	

	print("Please enter the Reset pin name :");
	$rinput = <STDIN>;
	chomp($rinput);
	
	print("Please enter RESET sensitivity if #ACTIVE HIGH enter 1 else #ACTIVE LOW Enter 0 :");
	$rtype = <STDIN>;
	chomp($rtype);
	if ($rtype==1)	
	{
	$RESET="$rinput";	
	}	
	else
	{
	$RESET=join ("","!",$rinput);
	}
		
	print("Please enter the Clock pin name :");
	$cinput = <STDIN>;
	chomp($cinput);
	
	print("Please enter clock edge sensitivity if #FALLING EDGE TRIGGERED enter 1 else #RISING EDGE Enter 0 :");
	$ctype = <STDIN>;
	chomp($ctype);
	
	if ($ctype==0)	
	{
	$CLK="$cinput";	
	}	
	else
	{
	$CLK=join ("","!",$cinput);
	}

	print("Please enter the Q output pin name :");
	$output = <STDIN>;
	chomp($output);

	print("Please enter The output type if #Q enter 1 else #Qbar Enter 0 :");
	$qtype = <STDIN>;
	chomp($qtype);

	if ($qtype==1)	
	{
	$Q="$output";	
	}	
	else
	{
	$Q=join ("","!",$output);
	}

		
	print("Please enter cell area :");
	$input = <STDIN>;
	chomp($input);
	$dffAreaHash = $input;
	
}



# Generate list file 

open(LIST, ">./list") or die "could not open list file to write!";

foreach $key (keys %cellInputHash)
{
	print LIST "$key\n";
}

#Import the netlist in the Tcl Script

foreach $cellName (keys %cellInputHash)
{
print SCRIPT "import -netlist ../$cellnetlist{$cellName} -overwrite $cellName\n";
}
	

if($dff==1)
{
print SCRIPT "import -netlist ../$DFFnetlist -overwrite $dffname\n";	
}
##########################Exit Siliconsmart to configure the instance files ######################
print SCRIPT "exit\n";

############################### Run the TCL script for SiliconSmart ACE setup ######################
system "siliconsmart ./setup.tcl";

###############################Copy the configuration file ######################
print("Now copying the configuration file..........\n\n");
system "cp -rf /home/eng/a/aat171030/Desktop/SS/configure.tcl ./char_dir/config/.";
	
######################################Configure the Instance Files ######################
foreach $cellName (keys %cellInputHash)
{
	open($INST_FILE, "< /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$cellName.inst") || die "Instance File not found";	#opening auto-generated inst file
	open($INST_NEW, ">> /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$cellName-new.inst") || die "Instance File not found"; #creating and opening new inst file
	while (my $line = readline($INST_FILE))
	{
		
		if($line =~ m/add_pin/i)
		{
			print "found\n";			
			$found = $line;
			if ($found =~ m/add_pin $cellOutputHash{$cellName} default -inout/i)
			{
			print "changed output\n";			
			$found =~ s/inout/output/i;
			print $INST_NEW $found;
			}
			elsif($found =~ m/add_pin VDD|GND default -inout/i)
			{
			print "changed supply\n";
			$found =~ s/inout/supply/i;										#NewLine
			print $INST_NEW $found;
			}
			else
			{		
				for($j=0;$j<$cellInputCountHash{$cellName};$j++)
				{
				if($found =~ m/add_pin $cellInputHash{$cellName}[$j] default -inout/i)
					{
					print "changed input\n";
					$found =~ s/inout/input/i;
					print $INST_NEW $found; 
					}
				}
			}
			next;
		}
		print $INST_NEW $line;	
	}
	
	print $INST_NEW "add_function $cellOutputHash{$cellName} { $cellFunctionHash{$cellName} }\n";
	#print $INST_NEW "add_function VDD { HI }\n";									#NewLine
	#print $INST_NEW "add_function GND { LO }\n";									#NewLine
	print $INST_NEW "define_parameters $cellName { set area $cellAreaHash{$cellName} }\n";	
	close(INST_FILE);
	#system "chmod 775 -R *";
	system "rm -rf /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$cellName.inst";
	close(INST_NEW);
	system "mv -f /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$cellName-new.inst /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$cellName.inst";
	
}

#DFF data
open($DFFINST_FILE, "< /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$dffname.inst") || die "Instance File not found";
open($DFFINST_NEW, ">> /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$dffname-new.inst") || die "Instance File not found";
	while (my $line = readline($DFFINST_FILE))
	{
		
		if($line =~ m/add_pin/i)
		{
			print "found\n";			
			$found = $line;
			if ($found =~ m/add_pin $output default -inout/i)
			{
			print "changed output\n";			
			$found =~ s/inout/output/i;
			print $DFFINST_NEW $found;
			}
			elsif($found =~ m/add_pin VDD|GND default -inout/i)
			{
			print "changed supply\n";
			$found =~ s/inout/supply/i;
			print $DFFINST_NEW $found;
			}
			else
			{		
				if($found =~ m/add_pin $dinput/i)
					{
					print "changed input\n";
					$found =~ s/inout/input/i;
					print $DFFINST_NEW $found; 
					}
				elsif($found =~ m/add_pin $cinput/i)
					{
					print "changed clock\n";
					$found =~ s/inout/input/i;
					print $DFFINST_NEW $found; 
					}
				else
					{
					print "changed reset\n";
					$found =~ s/inout/input/i;
					print $DFFINST_NEW $found; 
					}
			}
			next;
		}
		print $DFFINST_NEW $line;	
		
	}
print $DFFINST_NEW "add_flop IQ IQN $CLK $dinput -clear $RESET \n";
print $DFFINST_NEW "add_function $Q IQ\n";
#print $DFFINST_NEW "add_function VDD { HI }\n";									#NewLine
#print $DFFINST_NEW "add_function GND { LO }\n";									#NewLine
print $DFFINST_NEW "define_parameters $dffname { set area $dffAreaHash }\n";
# append set_config_opt to dff inst
open($CONFIG_OPT, "<", '/home/eng/x/xxx110230/public_html/scripts/siliconsmart/config.opt' );
while ( my $line = readline ($CONFIG_OPT) ) {
  print $DFFINST_NEW $line;
}
close(CONFIG_OPT);
close(DFFINST_FILE);
system "rm -rf /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$dffname.inst";
close(DFFINST_NEW);
system "mv -f /home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$dffname-new.inst	/home/eng/a/aat171030/cad/siliconsmart/run_dir/char_dir/control/$dffname.inst";
################################ Make the TCL script for characterizing ######################
open(CSCRIPT, ">./characterize.tcl") or die "could not open the script file to write!";
print CSCRIPT "set_location char_dir\n";
print CSCRIPT "configure\n";
print CSCRIPT "characterize\n";
print CSCRIPT "model\n";
print CSCRIPT "exit\n";


############################### Run the TCL script for SiliconSmart ACE ######################
system "siliconsmart ./characterize.tcl";





