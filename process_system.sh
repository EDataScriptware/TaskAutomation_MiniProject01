# Name: Quoc Huynh, Trent Jacobson, and Edward Riley
# Professor: Erik Golen
# Date: 3/8/2018
# Assignment: Mini-Project 1

# This is a function which will kill all APMs regardless if it is running or not.
killAll() {
	echo "Execute: killAll()"	
	killall -9 APM1
        sleep 1
	killall -9 APM2
	sleep 1
	killall -9 APM3
	sleep 1
	killall -9 APM4
	sleep 1
	killall -9 APM5
	sleep 1
	killall -9 APM6
	sleep 1
	killall -9 ifstat
	echo "Success!"
}

trap killAll EXIT

# This is a function which will run all programs in sequential order. 
spawnAll() {
	echo "Execute: spawnAll()"	
	./APM1 $1 &
	./APM2 $1 &
	./APM3 $1 &
	./APM4 $1 &
	./APM5 $1 &
	./APM6 $1 &
	ifstat -d 1
	echo "Killed all!"
}

# This is a function which will record all CPU, Memory in a five second interval.  
recordAllAPMs(){
		
	echo "Recording APM (Time, CPU, Mem) . . . 5 Seconds Passed!"
	APM_1_CPU=$(ps -aux | egrep APM1 | awk '{print $3}')
	APM_1_Mem=$(ps -aux | egrep APM1 | awk '{print $4}')	
	APM_2_CPU=$(ps -aux | egrep APM2 | awk '{print $3}')
        APM_2_Mem=$(ps -aux | egrep APM2 | awk '{print $4}')
        APM_3_CPU=$(ps -aux | egrep APM3 | awk '{print $3}')
        APM_3_Mem=$(ps -aux | egrep APM3 | awk '{print $4}')
	APM_4_CPU=$(ps -aux | egrep APM4 | awk '{print $3}')
        APM_4_Mem=$(ps -aux | egrep APM4 | awk '{print $4}')
        APM_5_CPU=$(ps -aux | egrep APM5 | awk '{print $3}')
	APM_5_Mem=$(ps -aux | egrep APM5 | awk '{print $4}')
	APM_6_CPU=$(ps -aux | egrep APM6 | awk '{print $3}')
	APM_6_Mem=$(ps -aux | egrep APM6 | awk '{print $4}')
	echo "Success!"
}	

# This is a function which will record all RX Rate, TX Rate, Disk Write, and Disk Available in a five second interval.
systemLevel() {
	
	echo "Recording Time, RXrate, TXrate, Disk Write, Disk Available . . . 5 Seconds Passed!"
        RXrate=$(ifstat | tail -n 4 | head -n 1 | awk '{print $7}')
        TXrate=$(ifstat | tail -n 4 | head -n 1 | awk '{print $9}')
        diskWrite=$(iostat | tail -n 5 | head -n 1 | awk '{print $4}')
        diskAvailable=$(df -m | head -n 2 | tail -n 1 | awk '{print $4}')
	echo "Success!"
}



# This will be used to check whether the .csv file exists or not - if the .csv file exists, it will be removed to allow for a new file to be made. 
if [ -e process_metrics.csv ]
then
	rm process_metrics.csv
fi

if [ -e system_metrics.csv ]
then
    	rm system_metrics.csv
fi


# execue with ip address
spawnAll $1

# starting at 0
SECONDS=0

#This will be documented onto the process_metrics.csv and system_metrics.csv at the header to show some organization and tidiness.
echo Time, APM1 CPU , APM1 Memory , APM2 CPU , APM2 Memory , APM3 CPU , APM3 Memory , APM4 CPU , APM4 Memory , APM5 CPU ,  APM5 Memory , APM6 CPU , APM6 Memory  >> process_metrics.csv

echo Time, RX Data Rate, TX Data Rate, Disk Writes, Available Disk Capacity >> system_metrics.csv


# Keeps going until the process is killed directly by a user. 
notDone=true

# Starting at 0 count 
count=0

# Running forever until quit then document itself to the process.metrics.csv and system_metrics.csv
while $notDone 
do
	# Documenting all process information into .csv file
	recordAllAPMs
	echo $SECONDS, $APM_1_CPU, $APM_1_Mem, $APM_2_CPU, $APM_2_Mem, $APM_3_CPU, $APM_3_Mem, $APM_4_CPU, $APM_4_Mem, $APM_5_CPU, $APM_5_Mem , $APM_6_CPU ,  $APM_6_Mem >> process_metrics.csv

	# Documenting all system information into seperate .csv file
	systemLevel
        echo $SECONDS, ${RXrate//K}, ${TXrate//K}, $diskWrite, $diskAvailable >> system_metrics.csv
	
	# Wait for 5 seconds
        sleep 5
	((count++))
done

