import java.util.Collections;
import java.util.ArrayList;
import java.util.List;
import java.nio.file.*;

int buttonWidth = 120;
int buttonHeight = 50;
int x, y;  // Coordinates of the button
int centerX, centerY; // Coordinates for the center of the screen
int pause; // Randomized pause time between button clicks
boolean buttonClicked = false;
long clickTime, reactionTime;
int buttonsPerGroup = 10;
int buttonsInCurrentGroup = 0;
int currentGroup = 0; // Start with the first group
Table table; // table
Path path; //path
int participantNum = 1;
int tasksCompleted = 0;

List<Integer> buttonColors; // List to store button colors
boolean isLightBackground = true; // Flag to track background color
boolean started = false; // Program start bool

 /* COLOR CODES (RGB)
  color(255,69,0);            //Reddit Red 
  color(77, 217, 100);        //iOS Green
  color(88, 101, 242);        //Discord Blue

  color(255, 255, 255);       //Chrome Light Mode (white)
  color(53, 54, 58);          //Chrome Dark Mode
 */

void setup() {
  fullScreen();
  noStroke();
  
  path = Paths.get("colorsarefun/data/colors.csv");
  
  if (Files.exists(path)) {
    table = loadTable("colors.csv");
  } else {
    table = new Table();
  }
  
  table.addColumn("participant");
  table.addColumn("background_color");
  table.addColumn("button_color");
  table.addColumn("reaction_time");

  // Initialize the list with colors
  buttonColors = new ArrayList<>();
  buttonColors.add(color(255, 69, 0));   // Red color (Reddit)
  buttonColors.add(color(77, 217, 100)); // Green color (iOS)
  buttonColors.add(color(88, 101, 242)); // Blue color (Discord)


  // Shuffle the list using Collections.shuffle
  Collections.shuffle(buttonColors);

  // Randomly set the background color
  isLightBackground = random(1) > 0.5;
  
  x = (int) random(buttonWidth * 2, width - buttonWidth * 2);
  y = (int) random(buttonHeight * 2, height - buttonHeight * 2);
  
  centerX = (int) width / 2;
  centerY = (int) height / 2;
}


void draw() {
  
  if (started) {
    color darkmodeColor = color(53,54,58);
    background(isLightBackground ? 255 : darkmodeColor); // Set background color based on the flag
    if (!buttonClicked) {
      fill(buttonColors.get(currentGroup));
      rect(x, y, buttonWidth, buttonHeight, 15);
    }
  } else {
    background(200 , 210, 255);
    fill(200, 180, 255);
    rectMode(CENTER);
    rect(centerX, height/2.25, 1400, 500, 60);
    fill(0);
    textSize(60);
    textAlign(CENTER);
    text("COLORS ARE FUN",centerX, height/2.9);
    text("_______________", centerX, height/2.7);
    textSize(30);
    text("In this experiment you will be tested on your ability to locate and click on colored buttons.", centerX, height/2.4);
    text("buttons will appear on the screen in random positions, please click on buttons as quickly as you are able.", centerX, height/2.2);
    text("-- Click the BUTTON to start --", centerX, centerY);
    rect(centerX, height/1.8, buttonWidth, buttonHeight, 15);
    fill(255, 69, 0);
    rect(centerX, height/1.8, buttonWidth - 10, buttonHeight - 10, 15);
    fill(77, 217, 100);
    rect(centerX, height/1.8, buttonWidth - 20, buttonHeight - 20, 15);
    fill(88, 101, 242);
    rect(centerX, height/1.8, buttonWidth - 30, buttonHeight - 30, 15);
    fill(255, 69, 0);
    rect(centerX, height/1.8, buttonWidth - 40, buttonHeight - 40, 15);
  }
 }

void mousePressed() {
  pause = (int) random(500, 1500);
  if (!buttonClicked && started) {
    // Check if the mouse coordinates are within the button
    if (mouseX >= x - buttonWidth/2 && mouseX <= x + buttonWidth/2 && mouseY >= y - buttonHeight/2 && mouseY <= y + buttonHeight/2) {
      reactionTime = millis() - clickTime;
      String colorName = getColorName(currentGroup);
      String backgroundColor = isLightBackground ? "light" : "dark";
      println("Your reaction time to " + colorName + " button on " + backgroundColor + " background: " + reactionTime + " milliseconds");
      
      TableRow newRow = table.addRow();
      newRow.setInt("participant", participantNum);
      newRow.setString("background_color", backgroundColor);
      newRow.setString("button_color", colorName);
      newRow.setFloat("reaction_time", reactionTime);
      
      saveTable(table, "data/colors.csv");
      
      
      buttonClicked = true;

      // Wait for a moment before showing the next button
      new java.util.Timer().schedule(
          new java.util.TimerTask() {
            @Override
            public void run() {
              nextbutton();
            }
          },
          pause
      );
    }
  } else if (!buttonClicked && !started) {
    if (mouseX >= centerX - buttonWidth/2 && mouseX <= centerX + buttonWidth/2 && mouseY >= height/1.8 - buttonHeight/2 && mouseY <= height/1.8 + buttonHeight/2) {
      started = true;
      clickTime = millis();
    }
  }
}

void keyPressed() {
  if (char(keyCode) == 'R'){
    int rowNum = table.getRowCount() - 1;
    for (int i = 0; i < tasksCompleted; i++) {
      println(rowNum);
      table.removeRow(rowNum);
      rowNum--;
    }
    tasksCompleted = buttonsPerGroup * 6;
    participantNum = participantNum - 1;
    nextbutton();
  }
}

void nextbutton() {
  tasksCompleted++;
  if (tasksCompleted >= buttonsPerGroup * 6) {
    tasksCompleted = 0;
    participantNum++;
    currentGroup = 0;
    buttonsInCurrentGroup = 0;
    
    // Shuffle the list using Collections.shuffle
    Collections.shuffle(buttonColors);
  
    // Randomly set the background color
    isLightBackground = random(1) > 0.5;
  
    // Start the first button
    x = (int) random(buttonWidth * 2, width - buttonWidth * 2);
    y = (int) random(buttonHeight * 2, height - buttonHeight * 2);
    buttonClicked = false;
    
    started = false;
  } 
  else {
    x = (int) random(buttonWidth * 2, width - buttonWidth * 2);
    y = (int) random(buttonHeight * 2, height - buttonHeight * 2);
    buttonClicked = false;
    clickTime = millis();
  
    buttonsInCurrentGroup++;
  
    if (buttonsInCurrentGroup >= buttonsPerGroup) {
      currentGroup++;
      buttonsInCurrentGroup = 0;
  
      // If all groups are shown, reshuffle the colors list and toggle background color
      if (currentGroup >= buttonColors.size()) {
        Collections.shuffle(buttonColors);
        currentGroup = 0;
        isLightBackground = !isLightBackground; // Toggle background color
      }
    }
  }
}

// Function to get color name based on shuffled index
String getColorName(int index) {
  if (index >= 0 && index < buttonColors.size()) {
    int colorValue = buttonColors.get(index);
    if (colorValue == color(255, 69, 0)) {
      return "Reddit Red";
    } else if (colorValue == color(77, 217, 100)) {
      return "iOS Green";
    } else if (colorValue == color(88, 101, 242)) {
      return "Discord Blue";
    }
  }
  return "Unknown";
}
