# ADC module for D-Lang
Analog-digital converter function written in D-Lang

## Design 
ADC Module works with sysfs and reads from an analog pin the value. It works only with boards that are compatible with analog pin(BeagleBone Black Board, but RaspberryPi no).
The ADC uses 12 bits, so the value that is read can be as high as 4095, the equivalent of 1.8V. The returned value is scaled to these 12 bits.

## Functions implemented
### Reading from a pin (function called by user)
````d
float read(int pinNumber);
````

Read the value from the given pin. The function takes only one argument:
* the number of the pin to read from

The function will do the following:
* Will check if the board is a BeagleBlone Boards, that supports analog pins and if so, it will call the ````d readAnalog(int pinNumber);```` function.
* If there is another board than BeagleBone, it will throw an exception. 

The function returns the value from the pin or an exception.

### Reading from a pin (function called inside the module)
````d 
readAnalog(int pinNumber);
````

Actually read the value from the given pin. The function takes only one argument:
* the number of the pin to read from

The function will do the following:
* Will try to open the file "/sys/bus/iio/devices/iio:device0/in_voltage'pinNumber'_raw" file
* Will read the value that is stored there
* Will transform the value from the raw to the actual value usign the following formula: ( 1,8 / 4095 ) * valueRead;
* The function works as a 12-bit analog-digital converter. 

The function returns the value from the given pin or a exception(the file could not have been opened or the value could not have been read).


## Example
### Read the same value for 5 times with 3 seconds waiting time between reads:
````d
import adc;

import core.thread;
import std.stdio;

void main() {
    /* wait time variable */
    int waitTime = 3;
    /* index */
    int i = 0;

    /* read for 5 times */ 
    while (i++ < 6) {
        /* read the value from the analog pin 1 */
        float value = adc.read(1);
        /* write the value on the screen */
        writeln("Read no. ", i, " with the result: ", value);
        /* wait 3 seconds */
        Thread.sleep(waitTime.seconds);
    }
}
````

## Requirements

* Do the following: 
    * sudo dd if=/dev/zero of=/dev/mmcblk1 count=1 seek=1 bs=128k. - it will erase the first 128k of flash memory from you beagle bone 
    board and you will be able to load overlays. 
    * in the /boot/uEnv.txt file write or uncomment the following commands to enable ADC:
        * enable_uboot_cape_universal=1
        * cape_enable=bone_capemgr.enable_partno=BB-ADC