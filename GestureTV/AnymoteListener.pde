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

import com.entertailion.java.anymote.client.*;
import com.entertailion.java.anymote.connection.*;
import com.entertailion.java.anymote.util.*;
import com.google.anymote.*;

// see https://github.com/entertailion/Anymote-for-Java
class AnymoteListener implements ClientListener, InputListener {
  AnymoteSender anymoteSender;
  GestureTV gestureTV;
  
  public AnymoteListener(GestureTV gestureTV) {
    this.gestureTV = gestureTV;
  }
  
  /**
   * ClientListener callback when attempting a connecion to a Google TV device
   * @see com.entertailion.java.anymote.client.ClientListener#attemptToConnect(com.entertailion.java.anymote.connection.TvDevice)
   */
  public void attemptToConnect(TvDevice device) {
    println("Attempting to connecting to "+device.toString());
  }
  
  /** 
   * ClientListener callback when Anymote is conneced to a Google TV device
   * @see com.entertailion.java.anymote.client.ClientListener#onConnected(com.entertailion.java.anymote.client.AnymoteSender)
   */
  public void onConnected(final AnymoteSender anymoteSender) {
    if (anymoteSender != null) {
      // Send events to Google TV using anymoteSender.
      // save handle to the anymoteSender instance.
      this.anymoteSender = anymoteSender;
      this.gestureTV.startKinect();
    } else {
      println("Connection failed");
    }
  }
  
  /**
   * ClientListener callback when the Anymote service is disconnected from the Google TV device
   * @see com.entertailion.java.anymote.client.ClientListener#onDisconnected()
   */
  public void onDisconnected() {
    println("Disconnected");
    anymoteSender = null;
  	
    System.exit(1);
  }
  
  /**
   * ClientListener callback when the connection to the Google TV device failed
   * @see com.entertailion.java.anymote.client.ClientListener#onConnectionFailed()
   */
  public void onConnectionFailed() {
    println("Connection failed");
  
    anymoteSender = null;
  	
    System.exit(1);
  }
  
  /**
   * Cleanup
   */
  private void destroy() {
    if (this.gestureTV.anymoteClientService != null) {
  	this.gestureTV.anymoteClientService.detachClientListener(this);
  	this.gestureTV.anymoteClientService.detachInputListener(this);
  	anymoteSender = null;
    }
  }
  
  /** 
   * InputListener callback for feedback on starting the device discovery process
   * @see com.entertailion.java.anymote.client.InputListener#onDiscoveringDevices()
   */
  public void onDiscoveringDevices() {
    println("Finding devices...");
  }
  
  /** 
   * InputListener callback when a Google TV device needs to be selected
   * @see com.entertailion.java.anymote.client.InputListener#onSelectDevice(java.util.List, com.entertailion.java.anymote.client.DeviceSelectListener)
   */
  public void onSelectDevice(List<TvDevice> trackedDevices, DeviceSelectListener listener) {
    println("onSelectDevice...");
  }
  
  /**
   * InputListener callback when PIN required to pair with Google TV device
   * @see com.entertailion.java.anymote.client.InputListener#onPinRequired(com.entertailion.java.anymote.client.PinListener)
   */
  public void onPinRequired(PinListener listener) {
    this.gestureTV.hasPin = false;
    this.gestureTV.instructions = "Enter PIN:";
    this.gestureTV.pinListener = listener;
  }
}
