# leaflet-vb6
Embed leaflet-based maps within vintage desktop applications.

![screenshot](https://cdn.rawgit.com/oliverheilig/leaflet-vb6/baed5a65/screenshot.png)

## Purpose
This sample shows how vintage desktop applications can embed modern browser-based controls. The sample **routing-machine** implements a simple route-planner in VB6. It utilizes [this JavaScript sample](https://github.com/ptv-logistics/xserverjs/tree/master/premium-samples/lrm-xserver/xserver-1) to be controlled from within the VB6 code.

* To run the sample just start **routing-machine.exe**. Maybe you need to install the [VB6 run-time files](https://support.microsoft.com/en-us/help/192461/vbrun60-exe-installs-visual-basic-6-0-run-time-files) first.
* To build / debug this code you need a [PTV xServer-internet token](https://xserver.ptvgroup.com/en-uk/products/ptv-xserver-internet/test/) and of course some version of VB6. 

## The Problem
Windows desktop applications can embed modern web widgets with the Windows WebBrowser Control.
.NET comes with the ```System.Windows.Forms.WebBrowser``` class, which makes it very easy to communicate with the JavaScript page by using ```InvokeScript()``` and ```window.external()```. 

Other IDEs can use the WebBrowser OCX directly, but they need to support ```IDocHostUIHandler``` COM internafce on the host window to allow tow-way communication, [which is not easy to implement by your own](https://stackoverflow.com/questions/15160567/provide-a-vb6-object-for-window-external-in-a-webbrowser-hosted-page).

However, you can achieve the same result with some simple tricks.

* A VB helper method [InvokeJs](https://github.com/oliverheilig/leaflet-vb6/blob/master/Hello.frm#L82-L86) invokes a script on the WebBrowser document and uses the document attribute ```ExtData``` to pass input and output parameters.
* For JavaScript an ```invokeExternal``` helper method sets the ```window.status``` of the browser to a method name, after setting a document attribute ```ExtData``` for the method args.
* On the VB6 side, the ```StatusTextChange```  event can be used as method dispatcher with ```ExtData``` for input and outpout args. 

This method doesn't support true object arguments like the .NET control. You have to work with string separators, or you can work with JSON if you have a parser for your framework. But besides this litte caveat its doing the job quite well.
