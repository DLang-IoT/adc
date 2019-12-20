module adc;

import std.conv;
import std.string;
import std.stdio;

/** 
 * File for reading the analog value of a pin
 */
File file;

/** 
 * This function reads the analog value from the given pin
 * Params:
 *   pinNumber = the number of the pin to read from
 * Returns: float value of the voltage on the input pin
 */
float analogRead(int pinNumber)
{
    try {
        string fileName = format!"%s%s%s"("/sys/bus/iio/devices/iio:device0/in_voltage", to!string(cast(double)pinNumber), "_raw");
        file = File(fileName, "r");
    } catch (std.exception.ErrnoException e) {
        throw new Exception("Cannot use analog input pins. \nMake sure you enabled BB-ADC and uboot overlays!");
    }

    string string_value;
    float value = 1.8 / 4095;

    try {
        string_value = strip(file.readln());
    } catch (std.exception.ErrnoException e) {
		throw new Exception("Cannot read value");
	}

    value *= to!float(string_value);
    file.close();
    return value;   
    
}

/** 
 * This function checks if the board has analog input pins and calls 
 * function readAnalog if so. If not, it throws an exception.
 * Params:
 *   pinNumber = the number of the pin to read from
 * Returns: float value of the voltage on the input pin or exception if the board
 *          is not valid for analog pins
 */
float read(int pinNumber)
{
	
    File cpuinfo;
    try {
        cpuinfo = File("/proc/cpuinfo", "r");
    } catch (std.exception.ErrnoException e) {
		throw new Exception("Unable to open /proc/cpuinfo\n");
	}

    char[] line;
    while (!cpuinfo.eof()) {
        line = cast(char[]) cpuinfo.readln();
        if (line.canFind("Hardware")) 
            break;
    }
    if (line.canFind("BCM283") || line.canFind("BCM271")) {
        throw new Exception("Unable to read from an analog pin on Raspberry Pi! Use other board!\n");
    } else if (line.canFInd("AM33XX")) {
        return analogRead(pinNumber);
    }
}
