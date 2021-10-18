# ThermoLogger
A gui-based MATLAB program for saving temperature data from a HH506RA thermocouple logger

## Installation
Download this repo.

## Usage
1. Open Matlab and navigate to this folder
2. Run "**_ThermoLogger_MAIN.m_**" to begin
3. Select the correct COM port from the list and connect
4. Choose how frequently you want to take a sample by changing the "_sample time_". Due to data speed limitations, 1 second is a good sample time to start with, but you might be able to push that a little faster.
5. Start and stop data collection using the "_Start_" and "_Stop_" buttons.
6. Data will automatically be saved in the "data" folder. A new sub-folder is auto-generated each time you run the program.
