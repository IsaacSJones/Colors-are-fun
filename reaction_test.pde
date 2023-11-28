import java.util.Collections;
import java.util.ArrayList;
import java.util.List;

int squareSize = 50;
int x, y;  // Coordinates of the square
boolean squareClicked = false;
long clickTime, reactionTime;
int squaresPerGroup = 2;
int squaresInCurrentGroup = 0;
int currentGroup = 0; // Start with the first group
Table table; // table
int participantNum = 0;
int tasksCompleted = 0;

List<Integer> squareColors; // List to store square colors
boolean isWhiteBackground = true; // Flag to track background color
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
  squareColors = new ArrayList<>();
  squareColors.add(color(255, 69, 0));   // Red color (Reddit)
  squareColors.add(color(77, 217, 100)); // Green color (iOS)
  squareColors.add(color(88, 101, 242)); // Blue color (Discord)


  // Shuffle the list using Collections.shuffle
  Collections.shuffle(squareColors);

  // Randomly set the background color
  isWhiteBackground = random(1) > 0.5;
  
  x = (int) random(width - squareSize);
  y = (int) random(height - squareSize);
}


void draw() {
  if (started) {
    color darkmodeColor = color(53,54,58);
    background(isWhiteBackground ? 255 : darkmodeColor); // Set background color based on the flag
    if (!squareClicked) {
      fill(squareColors.get(currentGroup));
      rect(x, y, squareSize, squareSize);
    }
  } else {
    background(200 , 210, 255);
    fill(200, 180, 255);
    rect(300, 200, 1400, 600);
    fill(0);
    textSize(60);
    textAlign(CENTER);
    text("COLORS ARE FUN", 950, 280);
    text("_______________", 950, 290);
    textSize(30);
    text("In this experiment you will be tested on your ability to locate and click on colored squares.", 1000, 360);
    text("Squares will appear on the screen in random positions, please click on squares as quickly as you are able.", 1000, 400);
    text("-- Click the SQUARE to start --", 950, 450);
    rect(930, 480, squareSize, squareSize);
    fill(255, 69, 0);
    rect(935, 485, (squareSize - 10), (squareSize - 10));
    fill(77, 217, 0);
    rect(940, 490, (squareSize - 20), (squareSize - 20));
    fill(88, 101, 242);
    rect(945, 495, (squareSize - 30), (squareSize - 30));
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
    if (mouseX >= 930 && mouseX <= 930 + squareSize && mouseY >= 480 && mouseY <= 480 + squareSize) {
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
