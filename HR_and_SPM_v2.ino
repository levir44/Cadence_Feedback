/*
Tempo Control For Simple Cardio Workouts

Written by Levi Rash for Cal Poly SLO
 */

// Includes------------
#include <SPI.h>
#include <SD.h>
File myFile;

// defines for more readable code
#define HR_RX 4 // pin polar is connected to.
#define AVG_SIZE 9 // usually 5
#define FILENAME_HR "KHR3.txt" // FOR NOW CAP THIS AT 8 CHARACTERS NOT INCLUDING .TXT
#define FILENAME_SPM "KSPM3.txt"
#define FILENAME_CAD "KCAD3.txt"
#define FILENAME_EXP_HR "KHRE3.txt"
#define TAU 10

// defines for get expected heart rate
#define NUM_DESIRED_HR 6 // Assuming 6 desired heart rates and times, change as needed

// Global Variables-----------
typedef enum {ST_INIT, ST_DETECT, ST_UPDATE, ST_POST} State_type;
State_type state = ST_INIT;

// All from Cario Trainer Code to get instantaneous HR and store it, also get average of last 5 hr measurments
int hb_median = 0;
int hb_expected = 100;
int hb_index    = 0;
int hb_bpm      = 0;

bool workout_started = 0;

unsigned long workout_start_time = 0;
unsigned long curr_time_HR, last_time_HR, hb_time;
int hb_array[AVG_SIZE]; 

uint8_t hb_oldSample, hb_sample;


// Variables for getting the avg SPM and storing it
int fsrPin = 0;     // the FSR and 10K pulldown are connected to a0
int fsrReading;     // the analog reading from the FSR resistor divider
int fsrVoltage;     // the analog reading converted to voltage
unsigned long fsrResistance;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance; 
long fsrForce;       // Finally, the resistance converted to force
int fsrLast = 0;

unsigned long curr_time_STEP, last_time_STEP;
unsigned long SPM_time;
int step_SPM = 0;
int step_index = 0;
int step_array[AVG_SIZE];
int step_average = 0;

int step_median = 100;
int step_median_prev = 100;
bool step_bool = 0;


// Metronome variables
int buzzerPin1 = 9; // Choose a PWM pin connected to the buzzer
int buzzerPin2 = 8;
int h_switch = 0;
unsigned long MET_interval = 60000 / hb_expected; // Interval between beats in milliseconds
unsigned long curr_time_MET, last_time_MET;


// variables for updating pace
unsigned long curr_update_time, last_update_time= 0;

// updating tempo variables 
int RHR = 40;
float cadence_next = 100;

// variables for ending the workout  - only check in update state
// in mins CHANGE THE WORKOUT LENGTH HERE
int workout_length = 9;
unsigned long workout_time = 0;

// variables for getting the expected heart rate
int desired_HRs[] = {127, 127, 172, 172, 127, 127}; //, 135, 135, 115, 115};
float desired_times[] = {0, 3, 3.2, 7, 7.2, 10}; //, 3.5, 5.5, 8, 10};

void setup()
 { Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  
  if (!SD.begin(10)) {
    Serial.println("initialization failed!");
    while (1);
  } 
  Serial.println("initialization done.");
  SD.remove(FILENAME_HR); //Clearing room for file.
  SD.remove(FILENAME_SPM);
  SD.remove(FILENAME_CAD);
  SD.remove(FILENAME_EXP_HR);

  pinMode(HR_RX, INPUT);
  workout_started = 1;
  delay(30000);
  tone(buzzerPin1, 600, 750); // 225, 25
  tone(buzzerPin2, 600, 750); // 225, 25
 } 


void loop ()
 {
  // FSM:
  switch (state) {
    case ST_INIT:  //===============================================================================
      if(workout_started){
        // May want to play start message to the user "Workout Starts in 3, 2, 1"
        // Start Timer for workout
        workout_start_time = millis();
        //initializing times
        last_time_HR    = workout_start_time; 
        curr_time_HR    = workout_start_time;

        last_time_STEP  = workout_start_time;
        curr_time_STEP  = workout_start_time;

        last_time_MET   = workout_start_time;
        curr_time_MET   = workout_start_time;

        // Go to detect state
        state = ST_DETECT;
      }
      else{
        state = ST_INIT;
      }
      break;
      
    case ST_DETECT:  //=============================================================================
      // BEGIN WITH METRONOME -> THEN HR -> THEN STEP (COULD SWITCH MET & HR LATER)
      
      // =============================== METRONOME ===================================================
      // Metronome generation for the user to follow
      // dont generate until 1 TAU has passed from the beginning, after that generate based on the MET_interval
      // Check if it's time to play the next beat
      curr_time_MET = millis();
      //Serial.println(curr_time_MET); 
      if (curr_time_MET > (1000 * TAU + workout_start_time)){ //checking to mkae sure its past one TAU
        if (curr_time_MET - last_time_MET >= MET_interval) { // checking to make sure its time to play the met
          last_time_MET = curr_time_MET;
          // Generate tone
          if (h_switch == 0) {
            tone(buzzerPin1, 275, 20); // 225, 25
            h_switch = h_switch + 1;
          } else {
            tone(buzzerPin2, 275, 20);
            h_switch = h_switch - 1;
          }
        }
      }
      // =============================== METRONOME ===================================================


      // =============================== HR DETECTION ===================================================
      // Continously detecting HB until we hit instruction time or end time.
      hb_sample = digitalRead(HR_RX);  //Store signal output 
      curr_time_HR = millis(); 
      if (hb_sample && (hb_oldSample != hb_sample)) {  
        hb_time = curr_time_HR - last_time_HR;
        hb_bpm = 60000/hb_time;
        //Serial.print("detected a hb");  
        //hb_time is time between two beats
        //hb_bpm is instantanoeus hr
        last_time_HR = curr_time_HR;  // to account for the delay or writing to the sd card
        
        // WRITING TO SD CARD
        myFile = SD.open(FILENAME_HR, FILE_WRITE); //Writing HB and time to SD.
        if (myFile) {
           myFile.println(hb_bpm);//myHBFile.print("HeartBeat: "); 
           myFile.println(curr_time_HR);//myHBFile.print(" Time: ");     
           myFile.close();
        } 
        // END OF WRITING TO SD CARD

   

        // storing the instantanoeus hr to the hb array which stores the last 5 heart rate detections
        if (hb_index < AVG_SIZE){ 
          hb_array[hb_index] = hb_bpm;
          hb_index += 1;
        } else{  
          hb_array[0] = hb_bpm;
          hb_index = 1;   
        } 
      }

      hb_oldSample = hb_sample; 
    // =============================== HR DETECTION =================================================== 


    // =============================== STEP DETECTION ===================================================   
    fsrReading = analogRead(fsrPin);  
    curr_time_STEP = millis(); 
 
    // analog voltage reading ranges from about 0 to 1023 which maps to 0V to 5V (= 5000mV)
    fsrVoltage = map(fsrReading, 0, 1023, 0, 5000);
 
    if (fsrVoltage == 0) {
    //Serial.println("No pressure");  
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance = 5000 - fsrVoltage;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance *= 10000;                // 10K resistor
      fsrResistance /= fsrVoltage;
      fsrConductance = 1000000;           // we measure in micromhos so 
      fsrConductance /= fsrResistance;
 
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance <= 1000) {
        fsrForce = fsrConductance / 80;   
      } else {
        fsrForce = fsrConductance - 1000;
        fsrForce /= 30;         
      }
    }


    step_bool = (fsrForce >= 2) && (fsrLast <= 1);
    // testing new stuff, instantaneous spm and stuff like that
   /* if ((fsrForce > 15) && (fsrLast < 15)) {  
      SPM_time = curr_time_STEP - last_time_STEP;
      step_SPM = 2 * (60000/SPM_time);
      last_time_STEP = curr_time_STEP;
      // ADD to array of 5 after getting instant
      Serial.print("detected a stride"); 
      Serial.println(step_SPM); */

    if (step_bool) {  
      SPM_time = curr_time_STEP - last_time_STEP;
      if (SPM_time < 600){
      } else {     
      step_SPM = 2 * (60000/SPM_time);
      last_time_STEP = curr_time_STEP;
      // ADD to array of 5 after getting instant
      //Serial.print("detected a stride"); 
      //Serial.println(step_SPM);         
      // delay by 12 millis to mimic storing to sd card
      }   

      // WRITING TO SD CARD
      myFile = SD.open(FILENAME_SPM, FILE_WRITE); //Writing HB and time to SD.
      if (myFile) {
        myFile.println(step_SPM);//myHBFile.print("HeartBeat: "); 
        myFile.println(curr_time_STEP);//myHBFile.print(" Time: ");     
        myFile.close();
      } 
      // END OF WRITING TO SD CARD

      
      // storing instantaneous SPM in array of 5 last readings
      if (step_index < AVG_SIZE){ 
        step_array[step_index] = step_SPM;
        step_index += 1;
      } else {  
        step_array[0] = step_SPM;
        step_index = 1;   
      } 
    }
    fsrLast = fsrForce;
    // =============================== STEP DETECTION =================================================== 

      
      // ======= CHECKING IF IT IS TIME TO UPDATE THE TEMPO, NEED ALL PARTS CALCULATED FIRST ===============
      curr_update_time = millis();
      if((curr_update_time - last_update_time) > (TAU * 1000)){
        state = ST_UPDATE;
        // need to median filter hb_array and average filter step_array        
        // median filtering the hr measurement
        hb_median = findMedian(hb_array, AVG_SIZE); //AVG_SIZE

        // averaging filter the step measurement
        /*Serial.println("UPDATING - STEP ARRAY BELOW");
        Serial.println(step_array[0]);
        Serial.println(step_array[1]);
        Serial.println(step_array[2]);
        Serial.println(step_array[3]);
        Serial.println(step_array[4]);*/
        for (int i=0; i < AVG_SIZE; i++){ //Averaging steps. 
          step_average += step_array[i]; 
        }        
        step_average = step_average / AVG_SIZE;
        step_index = 0;
        // NOT CURRENTLY USING, BUT MIGHT LATER
        step_median_prev = step_median; 
        step_median = findMedian(step_array, AVG_SIZE);  //AVG_SIZE      

        last_update_time = curr_update_time;
      }

      else{
        state = ST_DETECT;
      }
      // ======= CHECKING IF IT IS TIME TO UPDATE THE TEMPO, NEED ALL PARTS CALCULATED FIRST ===============
      break;

    case ST_UPDATE:  //============================================================================ 
      workout_time = millis();
      // send the hb_median and step_average to update the new MET_interval
      // currently hb_expected is const = 150
      Serial.println("In ST_UPDATE");
      //Serial.print("median hr: ");
      //Serial.println(hb_median);  
      //Serial.print("average spm: ");
      //Serial.println(step_average);
      //Serial.print("expected hr: ");
      //Serial.println(hb_expected);
      //Serial.print("RHR: ");
      //Serial.println(RHR); */

      // getting the expected heart rate and write it to sd card
      hb_expected = 172; //getExpectedHR(workout_time, desired_HRs, desired_times);  //172; 
      Serial.println("Heart beat expected =");
      Serial.print(hb_expected);
      Serial.println("time =");
      Serial.print(workout_time);      

      // WRITING TO SD CARD
      myFile = SD.open(FILENAME_EXP_HR, FILE_WRITE); //Writing HB and time to SD.
      if (myFile) {
        myFile.println(hb_expected);//myHBFile.print("HeartBeat: "); 
        myFile.println(workout_time);//myHBFile.print(" Time: ");     
        myFile.close();
      } 
      // END OF WRITING TO SD CARD  

      // want to use previous cadence: step_median_prev 
      //step_median_prev = step_median; 

      // calculating the next cadence for expected heart rate
      // want to use previous cadence: step_median_prev
      cadence_next = (hb_expected - RHR) * step_median_prev / (hb_median - RHR); // could use step_median here instead
      //Serial.print("Cadence b4 limit: ");
      //Serial.println(cadence_next); 
      if (cadence_next < 50){
        cadence_next = 50;
      } else if (cadence_next > 250){
        cadence_next = 250;
      }
      MET_interval = 60000 / cadence_next;
      // WRITING TO SD CARD
      myFile = SD.open(FILENAME_CAD, FILE_WRITE); //Writing HB and time to SD.
      if (myFile) {
        myFile.println(cadence_next);//myHBFile.print("HeartBeat: "); 
        myFile.println(curr_update_time);//myHBFile.print(" Time: ");     
        myFile.close();
      } 
      // END OF WRITING TO SD CARD

      // checking if it is time to stop the workout
      if (workout_time - workout_start_time > (workout_length * 60000)){
        state = ST_POST;        
      } else {
        state = ST_DETECT;
      }  
      Serial.print("new Cadence: ");
      Serial.println(cadence_next);  
      break;
      

    case ST_POST:  //===============================================================================
      // just setting the buzzer to 0 to stop buzzing the user
      //Serial.println("In ST_POST");
      workout_started = 0;
      state = ST_INIT;
      tone(buzzerPin1, 500, 750);
      tone(buzzerPin2, 500, 750); // 225, 25
      digitalWrite(buzzerPin1, 0);
      digitalWrite(buzzerPin2, 0);
      break;
  }
}

//================ MEDIAN FILTERING FUNCTIONS =========================================
int findMedian(int arr[], int size) {
  // Sort the array
  bubbleSort(arr, size);

  // Find the median
  if (size % 2 == 0) {
    // If the size of the array is even
    return (arr[size / 2 - 1] + arr[size / 2]) / 2;
  } else {
    // If the size of the array is odd
    return arr[size / 2];
  }
}

void bubbleSort(int arr[], int size) {
  for (int i = 0; i < size - 1; i++) {
    for (int j = 0; j < size - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        // Swap arr[j] and arr[j+1]
        int temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
  }
}

// Function definition for getting the expected heart rate
int getExpectedHR(unsigned long workout_time, int desired_HRs[], float desired_times[]) {
  // Convert workout time to minutes
  float workout_time_min = workout_time / (1000.0 * 60.0);

  // Check if workout time is within the range of desired times
  if (workout_time_min < desired_times[0]) {
    return desired_HRs[0]; // Return the first desired heart rate
  }
  else if (workout_time_min >= desired_times[NUM_DESIRED_HR - 1]) {
    return desired_HRs[NUM_DESIRED_HR - 1]; // Return the last desired heart rate
  }
  else {
    // Find the closest desired time index
    int closest_time_index = 0;
    for (int i = 1; i < NUM_DESIRED_HR; i++) {
      if (desired_times[i] <= workout_time_min) {
        closest_time_index = i;
      }
      else {
        break; // Exit loop when we find the closest time
      }
    }

    // Linear interpolation to find expected heart rate
    float slope = (desired_HRs[closest_time_index + 1] - desired_HRs[closest_time_index]) / (desired_times[closest_time_index + 1] - desired_times[closest_time_index]);
    float expected_HR = desired_HRs[closest_time_index] + slope * (workout_time_min - desired_times[closest_time_index]);

    return (int)expected_HR; // Return the expected heart rate
  }
}