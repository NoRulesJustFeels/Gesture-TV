Gesture-TV
==========

<p>Gesture-TV allows you to control your Google TV with a <a href="http://www.xbox.com/en-US/KINECT">Kinect</a> sensor.
You need a computer and a Microsoft Kinect sensor with a power adapter.</p>

<p>Gesture-TV is based on the <a href="https://code.google.com/p/simple-openni/">simple OpenNI wrapper</a> for <a href="http://processing.org/download/">Processing</a>.
Follow the <a href="https://code.google.com/p/simple-openni/wiki/Installation">installation instructions</a> for your operating system.
Download a copy of Gesture-TV and open the GestureTV.pde file in Processing development environment.
</p>

<p>When you run Gesture-TV, it requires that you enter the IP address of the Google TV device you want to control. 
Once that is entered and the connection made, you need to do the surrendering pose (aka stand like a cactus) for calibration. 
When the calibration is done you will see a skeleton line figure. You can drop both hands now.
Lift up one hand and wave it until you see red dots. Now everything is ready to control your Google TV.
</p>

<p>There are two input modes:
<ol>
<li>Pointer mode: If you hold up one hand and keep the other down to your side. Move your hand to position the pointer. Push to select.</li>
<li>Gesture mode: If you hold up one hand and then the other. For the first hand, swipe down to go home or swipe left to go back.</li>
</ol></p>

<p>The mapping of hand movements to pointer positioning is very primitive and you might get into a situation where the location you want to reach on the screen is out of reach.
You can reset the pointer position by dropping your hand and then lifting it up again. You can also move the pointer against one of the screen edges to adjust the mapping.</p>

<p>Note for developers: The Gesture-TV project includes the jar file for the <a href="https://github.com/entertailion/Anymote-for-Java">Anymote-for-Java</a> library in its lib directory. 
Developers should check out that project and export a jar file for the latest version of the code. 
When you export the Anymote-for-Java project as a jar file, do not include its lib directory since this project already includes those jar files.</p>

<p>References:
<ul>
<li><a href="http://www.openni.org/">OpenNI</a></li>
<li><a href="http://www.primesense.com/?p=515">NITE</a></li>
<li><a href="http://kinectcar.ronsper.com/docs/nite/index.html">NITE API Reference</a></li>
<li><a href="http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/dist/all/SimpleOpenNI/documentation/index.html">Simple OpenNI Java Docs</a></li>
<li><a href="https://developers.google.com/tv/remote/docs/pairing">Google TV Pairing Protocol</a></li>
<li><a href="https://code.google.com/p/anymote-protocol/">Anymote Protocol</a></li>
<li><a href="https://developers.google.com/tv/remote/docs/developing">Building Second-screen Applications for Google TV</a></li>
<li>The ultimate Google TV remote: <a href="https://play.google.com/store/apps/details?id=com.entertailion.android.remote">Able Remote</a></li>
</ul>
</p>