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

/////////////////////////////////////////////////////////////////////////////////////////////////////
// PointDrawer keeps track of the handpoints

import com.entertailion.java.anymote.client.*;
import com.entertailion.java.anymote.connection.*;
import com.entertailion.java.anymote.util.*;
import com.google.anymote.Key.*;

// see http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/dist/all/SimpleOpenNI/documentation/SimpleOpenNI/XnVPushDetector.html
class PointDrawer extends XnVPushDetector
{
  HashMap    _pointLists;
  int        _maxPoints;
  color[]    _colorList = { 
    color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0)
  };
  int pushed = 0;
  AnymoteSender anymoteSender = null;
  float lastX = -1; 
  float lastY = -1;

  public PointDrawer()
  {
    _maxPoints = 30;
    _pointLists = new HashMap();

    RegisterPush(this);
  }

  public void OnPointCreate(XnVHandPointContext cxt)
  {
    println("OnPointCreate");
    lastX = -1;
    lastY = -1;
    // create a new list
    addPoint(cxt.getNID(), new PVector(cxt.getPtPosition().getX(), cxt.getPtPosition().getY(), cxt.getPtPosition().getZ()));
  }

  public void OnPointUpdate(XnVHandPointContext cxt)
  {  
    addPoint(cxt.getNID(), new PVector(cxt.getPtPosition().getX(), cxt.getPtPosition().getY(), cxt.getPtPosition().getZ()));
  }

  public void OnPointDestroy(long nID)
  {
    if (_pointLists.containsKey(nID))
      _pointLists.remove(nID);
  }

  void onPush(float vel, float angle) {
    println(">>>>>>>>> PUSH v:" + vel + "a: " + angle);
    pushed = 10;
    if (anymoteSender!=null) {
      anymoteSender.sendKeyPress(Code.BTN_MOUSE);
    }
  }

  public ArrayList getPointList(long handId)
  {
    ArrayList curList;
    if (_pointLists.containsKey(handId))
      curList = (ArrayList)_pointLists.get(handId);
    else
    {
      curList = new ArrayList(_maxPoints);
      _pointLists.put(handId, curList);
    }
    return curList;
  }

  public void addPoint(long handId, PVector handPoint)
  {
    ArrayList curList = getPointList(handId);

    curList.add(0, handPoint);      
    if (curList.size() > _maxPoints)
      curList.remove(curList.size() - 1);
  }

  public void draw()
  {
   
    if (_pointLists.size() <= 0)
      return;

    pushStyle();
    noFill();

    PVector vec;
    PVector firstVec;
    PVector screenPos = new PVector();
    int colorIndex=0;

    // draw the hand lists
    Iterator<Map.Entry> itrList = _pointLists.entrySet().iterator();
    while (itrList.hasNext ()) 
    {
      strokeWeight(2);
      stroke(_colorList[colorIndex % (_colorList.length - 1)]);

      ArrayList curList = (ArrayList)itrList.next().getValue();     

      // draw line
      firstVec = null;
      Iterator<PVector> itr = curList.iterator();
      beginShape();
      while (itr.hasNext ()) 
      {
        vec = itr.next();
        if (firstVec == null)
          firstVec = vec;
        // calc the screen pos
        context.convertRealWorldToProjective(vec, screenPos);
        vertex(screenPos.x, screenPos.y);
      } 
      endShape();   

      // draw current pos of the hand
      if (firstVec != null)
      {
        strokeWeight(8);
        context.convertRealWorldToProjective(firstVec, screenPos);
        point(screenPos.x, screenPos.y);

        if (pushed > 0) {
          rect(screenPos.x, screenPos.y, 10, 10);
          pushed --;
        }
        //println("x="+screenPos.x+" y="+screenPos.y);
        if (anymoteSender!=null) {
          // map Kinect 640x480 resolution to TV resolution
          float dx = screenPos.x/640.0f;
          float dy = screenPos.y/480.0f;
          
          if (lastX==-1 && lastY==-1) {
            float mx = 1920*dx;
            float my = 1080*dy;
            mx = 1920/2;
            my = 1080/2;
            // move pointer to top left corner
            anymoteSender.sendMoveRelative(-10000, -10000);
            // match current position
            anymoteSender.sendMoveRelative((int)mx, (int)my);
            lastX = mx;
            lastY = my;
          } else {
            float mx = 1920*dx*3;
            float my = 1080*dy*3;
            anymoteSender.sendMoveRelative((int)(mx-lastX), (int)(my-lastY));
            lastX = mx;
            lastY = my;
          }
         
        }
      }
      colorIndex++;
    }

    popStyle();
  }
}

