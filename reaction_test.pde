import java.util.Collections;
import java.util.ArrayList;
import java.util.List;
import java.nio.file.*;

int squareSize = 50;
int x, y;  // Coordinates of the square
boolean squareClicked = false;
boolean isCtrlPressed = false;
boolean isRPressed = false;
long clickTime, reactionTime;
int squaresPerGroup = 2;
int squaresInCurrentGroup = 0;
int currentGroup = 0; // Start with the first group
Table table; // table
Path path; // path
int participantNum = 1;
int tasksCompleted = 0;

List<Integer> squareColors; // List to store square colors
boolean isWhiteBackground = true; // Flag to track background color
boolean started = false; // Program start bool

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
  squareColors = new ArrayList<>();
  squareColors.add(color(255, 0, 0)); // Red color
  squareColors.add(color(0, 255, 0)); // Green color
  squareColors.add(color(0, 0, 255)); // Blue color

  // Shuffle the list using Collections.shuffle
  Collections.shuffle(squareColors);

  // Randomly set the background color
  isWhiteBackground = random(1) > 0.5;
  
  x = (int) random(width - squareSize);
  y = (int) random(height - squareSize);
}


void draw() {
  if (started) {
    background(isWhiteBackground ? 255 : 0); // Set background color based on the flag
    if (!squareClicked) {
      fill(squareColors.get(currentGroup));
      rect(x, y, squareSize, squareSize);
    }
  } else {
    background(255);
    fill(0);
    textSize(20);
    text("In this experiment all you have to do is use the mouse", 500, 400);
    text("to click the colored squares as quickly as possible", 500, 420);
    text("Click to start", 500, 500);
    rect(650, 470, squareSize, squareSize);
  }
}

void mousePressed() {
  if (!squareClicked && started) {
    // Check if the mouse coordinates are within the square
    if (mouseX >= x && mouseX <= x + squareSize && mouseY >= y && mouseY <= y + squareSize) {
      reactionTime = millis() - clickTime;
      String colorName = getColorName(currentGroup);
      String backgroundColor = isWhiteBackground ? "white" : "black";
      println("Your reaction time to " + colorName + " square on " + backgroundColor + " background: " + reactionTime + " milliseconds");
      
      TableRow newRow = table.addRow();
      newRow.setInt("participant", participantNum);
      newRow.setString("background_color", backgroundColor);
      newRow.setString("button_color", colorName);
      newRow.setFloat("reaction_time", reactionTime);
      
      saveTable(table, "data/colors.csv");
      
      
      squareClicked = true;

      // Wait for a moment before showing the next square
      new java.util.Timer().schedule(
          new java.util.TimerTask() {
            @Override
            public void run() {
              nextSquare();
            }
          },
          1000
      );
    }
  } else if (!squareClicked && !started) {
    if (mouseX >= 650 && mouseX <= 650 + squareSize && mouseY >= 470 && mouseY <= 470 + squareSize) {
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
    tasksCompleted = squaresPerGroup * 6;
    participantNum = participantNum - 1;
    nextSquare();
  }
}

void nextSquare() {
  tasksCompleted++;
  if (tasksCompleted >= squaresPerGroup * 6) {
    tasksCompleted = 0;
    participantNum++;
    currentGroup = 0;
    squaresInCurrentGroup = 0;
    
    // Shuffle the list using Collections.shuffle
    Collections.shuffle(squareColors);
  
    // Randomly set the background color
    isWhiteBackground = random(1) > 0.5;
  
    // Start the first square
    x = (int) random(width - squareSize);
    y = (int) random(height - squareSize);
    squareClicked = false;
    
    started = false;
  } 
  else {
    x = (int) random(width - squareSize);
    y = (int) random(height - squareSize);
    squareClicked = false;
    clickTime = millis();
  
    squaresInCurrentGroup++;
  
    if (squaresInCurrentGroup >= squaresPerGroup) {
      currentGroup++;
      squaresInCurrentGroup = 0;
  
      // If all groups are shown, reshuffle the colors list and toggle background color
      if (currentGroup >= squareColors.size()) {
        Collections.shuffle(squareColors);
        currentGroup = 0;
        isWhiteBackground = !isWhiteBackground; // Toggle background color
      }
    }
  }
}

// Function to get color name based on shuffled index
String getColorName(int index) {
  if (index >= 0 && index < squareColors.size()) {
    int colorValue = squareColors.get(index);
    if (colorValue == color(255, 0, 0)) {
      return "Red";
    } else if (colorValue == color(0, 255, 0)) {
      return "Green";
    } else if (colorValue == color(0, 0, 255)) {
      return "Blue";
    }
  }
  return "Unknown";
}
