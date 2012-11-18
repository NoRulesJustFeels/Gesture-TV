/*
 * Copyright (C) 2012 ENTERTAILION, LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

// Original code: https://groups.google.com/forum/?fromgroups=#!searchin/simple-openni-discuss/XnVSwipeDetector/simple-openni-discuss/dDV8UZDpTgg/nTlOZOk9MMAJ

import SimpleOpenNI.*;
import com.entertailion.java.anymote.client.*;
import com.entertailion.java.anymote.connection.*;
import com.entertailion.java.anymote.util.*;
import com.google.anymote.*;

SimpleOpenNI context;
XnVSessionManager sessionManager;
SwipeDetector swipeDetector;
AnymoteClientService anymoteClientService;
AnymoteListener anymoteListener;
PointDrawer pointDrawer;

String instructions = new String();
String currentInput = new String();
boolean hasIpAddress = false;
boolean hasPin = true;
PinListener pinListener;
boolean kinectReady = false;
boolean autoCalibrate = true;
PVector rightHand = new PVector(); // track hand positions
PVector rightElbow = new PVector();
PVector leftHand = new PVector();
PVector leftElbow = new PVector();
boolean rightUp = false;
boolean leftUp = false;

void setup() {
  size(640, 480);
  smooth();
  PFont font = createFont("FFScala", 32);
  textFont(font);
  textAlign(CENTER);
  
  instructions = "Enter Google TV device IP address:";
  currentInput = "192.168.0.51";  // TODO debugging
}

void startKinect() {
  context = new SimpleOpenNI(this);
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  context.setMirror(true);
  context.enableHands();
  context.enableGesture();
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  sessionManager = context.createSessionManager("Wave", "RaiseHand"); // context.createSessionManager("Click,Wave", "RaiseHand");
  swipeDetector = new SwipeDetector();
  pointDrawer = new PointDrawer();
  sessionManager.AddListener(swipeDetector);
  sessionManager.AddListener(pointDrawer);
  
  pointDrawer.anymoteSender = anymoteListener.anymoteSender;
  swipeDetector.anymoteSender = anymoteListener.anymoteSender;
  
  size(context.depthWidth(), context.depthHeight()); 
  kinectReady = true;
}

// see https://github.com/entertailion/Android-Anymote
boolean startAnymote(String ip) {
  anymoteClientService = AnymoteClientService.getInstance(new JavaPlatform());
  anymoteListener = new AnymoteListener(this);
  anymoteClientService.attachClientListener(anymoteListener);  // client service callback
  anymoteClientService.attachInputListener(anymoteListener);  // user interaction callback
  try {
    Inet4Address address = (Inet4Address) InetAddress.getByName(ip);
    anymoteClientService.connectDevice(new TvDevice(ip, address));
    return true;
  } catch (Exception e) {
  }
  return false;
}

void draw() {
  if (kinectReady) { // kinect output
    context.update();
    context.update(sessionManager);
    image(context.depthImage(), 0, 0, width, height);
    pointDrawer.draw();
    
    // draw the skeleton if it's available
    int[] userList = context.getUsers();
    for(int i=0;i<userList.length;i++)
    {
      if(context.isTrackingSkeleton(userList[i]))
        drawSkeleton(userList[i]);
    }    
  } else {  // initial input screen
    background(255, 255, 255);
    fill(0);
    text(instructions, width/2, height/2);
    fill(255, 0, 0);
    text(currentInput, width/2, height*.75);
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);  // TODO support multiple users
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  rightUp = rightHand.y > rightElbow.y;
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
  leftUp = leftHand.y > leftElbow.y;
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

void keyPressed()
{
 if(key == ENTER || key==RETURN)
 {
   if (!hasIpAddress) {
     hasIpAddress = startAnymote(currentInput);
     if (hasIpAddress) {
       instructions = "";
     }
   } else if (!hasPin) {
     if (pinListener!=null) {
       pinListener.onSecretEntered(currentInput);
     }
     instructions = "";
     hasPin = true;
     pinListener = null;
   }
   currentInput = "";
 }
 else if(key == BACKSPACE && currentInput.length() > 0)
 {
   currentInput = currentInput.substring(0, currentInput.length() - 1);
 }
 else
 {
   currentInput = currentInput + key;
 }
}


//////////////////////////////////////////////////
///////////////////////////////////////////////////
// session callbacks

void onStartSession(PVector pos)
{
  println("onStartSession: " + pos);
  context.removeGesture("Wave");
}

void onEndSession()
{
  println("onEndSession: ");
  context.addGesture("Wave");
}

void onFocusSession(String strFocus, PVector pos, float progress)
{
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}

/////////////////
// HANDS

// -----------------------------------------------------------------
// hand events

void onCreateHands(int handId, PVector pos, float time)
{
  println("onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time);
}

void onUpdateHands(int handId, PVector pos, float time)
{
  // println("onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time);
}

void onDestroyHands(int handId, float time)
{
  println("onDestroyHandsCb - handId: " + handId + ", time:" + time);
}

// -----------------------------------------------------------------
// gesture events

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  println("onRecognizeGesture - strGesture: " + strGesture + 
    ", idPosition: " + idPosition + ", endPosition:" + endPosition);
}

void onProgressGesture(String strGesture, PVector position, float progress)
{
  println("onProgressGesture - strGesture: " + strGesture + 
    ", position: " + position + ", progress:" + progress);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  if(autoCalibrate)
    context.requestCalibrationSkeleton(userId, true);
  else    
    context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


