int mapWidth = 12;
int mapHeight = 21;
int[] map = new int[mapWidth * mapHeight];
int tileWidth = 32;
int tileHeight = 32;

color[] targetBgColors =
{ 
#0000EE,
#00EE00,
#660198,
#EE0000,
#EEEE00,
#FF34B3,
#FFE600
};

color backgroundColor = targetBgColors[0];
color[] tileColors = new color[mapWidth * mapHeight]; // Keeps track of the color of all tiles
int targetColorIndex = 0;
boolean changeTargetNextFrame = false;
boolean waitedSomeFrames = false;
int bgChangeFrameCounter = 0;

// DISCLAIMER: the rendering code is horribly inefficient, enter at your own risk

void createMap() 
{
    targetColorIndex = int(random(0, targetBgColors.length));
    
    //Create map border
    for(int y = 0; y < mapHeight; y++) 
    {
        
        for(int x = 0; x < mapWidth; x++)
        {
                
            if(x == 0 || x == mapWidth - 1 || y == mapHeight - 1) 
            {
                map[y * mapWidth + x] = 1;
                continue;
            }
            
            map[y * mapWidth + x] = 0;
        }
        
    }
    
    //Set tile colors
    for(int y = 0; y < mapHeight; y++) 
    {
        
        for(int x = 0; x < mapWidth; x++)
        {
            tileColors[y * mapWidth + x] = color(0, 0, 0, 255);
        }
        
    }
    
}

// Just the background color
void drawBackground()
{   
    background(backgroundColor);
    gradualChangeTo(targetBgColors[targetColorIndex]);
}
    
// Draw the map foreground, only the non-moving blocks
void drawForeground()
{
    pushMatrix();
    translate(resX/2 - ((tileWidth * mapWidth) / 2), 68);
    translate(tileWidth/2, tileHeight/2);
    
    for(int y = 0; y < mapHeight; y++) 
    {
        
        for(int x = 0; x < mapWidth; x++) 
        {
            
            if(map[y * mapWidth + x] == 0) 
            {
                mapFillerShape.setStroke(color(0, 0, 0, 255));
                mapFillerShape.setFill(color(100, 100, 100, 100));
                shape(mapFillerShape);
            } 
            else 
            {
                push();
                boxShape.setStroke(color(0, 0, 0, 255));
                boxShape.setStrokeWeight(4);
                
                if(map[y * mapWidth + x] == 1) 
                {
                    boxShape.setFill(color(0, 0, 0, 255));
                } 
                else
                {
                    boxShape.setFill(tileColors[y * mapWidth + x]);
                }
                
                if(blocksToRemove.size() > 0) 
                {
                    
                    for(int j = 0; j < blocksToRemove.size(); j++)
                    {
                        
                        if((y * mapWidth + x) == blocksToRemove.get(j)) 
                        {
                            color curTileColor = tileColors[y * mapWidth + x];
                            
                            // A formula with random numbers to create the effect when clearing rows
                            curTileColor += (cos(curTileColor) * 3.14 * (2.71 - curTileColor) + (curTileColor * 4.66)) * 0.0001; 

                            boxShape.setFill(curTileColor);
                            tileColors[y * mapWidth + x] = curTileColor;
                        }
                        
                    }
                    
                }
                
                // Textures can be applied here
                //boxShape.setTexture(textures[map[y * mapWidth + x] - 1]);
                shape(boxShape);
                pop();
            }
            
            translate(tileWidth, 0);
        }
        
        translate(0, tileHeight);
        translate(-(tileWidth * mapWidth), 0);
    }
    
    popMatrix();
}

// This controls the gradual change to another color for the background
// The background will slowly shift to a specific target color while the game plays
void gradualChangeTo(color targetColor)
{
    int changeSpeed = 10; // Higher is slower
    int dr = 0;
    int dg = 0;
    int db = 0;
    
    if(changeTargetNextFrame) 
    {
        targetColorIndex = int(random(0, targetBgColors.length));
        changeTargetNextFrame = false;
    } 
    else if(waitedSomeFrames)
    {
        dr = (red(targetColor) > red(backgroundColor)) ? 1 : (red(targetColor) == red(backgroundColor) ? 0 : -1);
        dg = (green(targetColor) > green(backgroundColor)) ? 1 : (green(targetColor) == green(backgroundColor) ? 0 : -1);
        db = (blue(targetColor) > blue(backgroundColor)) ? 1 : (blue(targetColor) == blue(backgroundColor) ? 0 : -1);
        
        if(backgroundColor == targetColor)
        {
            changeTargetNextFrame = true;
        }
        
        backgroundColor = color(red(backgroundColor) + dr, green(backgroundColor) + dg, blue(backgroundColor) + db);
        
        waitedSomeFrames = false;
        bgChangeFrameCounter = 0;
    } 
    else
    {
        
        if(bgChangeFrameCounter > changeSpeed) 
        {
            waitedSomeFrames = true;
        } 
        else 
        {
            bgChangeFrameCounter++;
        }
        
    }
  
}

void drawPauseScreen()
{
    pushMatrix();
    translate(resX/2 - ((tileWidth) / 2), resY / 2 - (tileHeight * 3), 50);
    translate(tileWidth/2, tileHeight/2);
    shape(pauseTextBgShape);
    text("Press space \n to start", 0, 0, 51);
    popMatrix();
}

void drawGameOverScreen()
{
    pushMatrix();
    translate(resX/2 - ((tileWidth) / 2), resY / 2 - (tileHeight * 3), 50);
    translate(tileWidth/2, tileHeight/2);
    shape(pauseTextBgShape);
    push();
    fill(200, 0, 0);
    textSize(30);
    text("GAME OVER!", 0, -10, 51);
    fill(255, 255, 255);
    textSize(15);
    text("Press space \n to continue", -2, 30, 51);
    pop();
    popMatrix();
}

void drawInterface() 
{
    pushMatrix();
    
    translate(resX/2 - (tileWidth * 9), 72);
    translate(tileWidth/2, tileHeight/2);
    shape(scoreTextBgShape);
    
    push();
    text("Score", 20, -5, 51);
    textAlign(RIGHT);
    textSize(20);
    text("" + score, 80, 28, 51);
    pop();
    
    push();
    textSize(40);
    text(currSecret, 20, 100, 100);
    pop();
    
    popMatrix();
    
    pushMatrix();
    
    translate(resX/2 + (tileWidth * 8), 72);
    translate(tileWidth/2, tileHeight/2);
    shape(timerTextBgShape);
    
    push();
    text("Time", -20, -5, 51);
    textSize(20);
    textAlign(LEFT);
    text("" + secondsSinceStart, -80, 28, 51);
    pop();
    
    popMatrix();
    
    pushMatrix();
    translate(resX/2 + (tileWidth * 8), 130);
    translate(tileWidth/2 + 20, tileHeight/2 + 10);
    push();
    text("Upcoming Piece", -20, -5, 51);
    textSize(20);
    textAlign(LEFT);
    pop();
    
    popMatrix();
}
    
