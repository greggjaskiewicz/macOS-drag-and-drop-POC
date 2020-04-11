# macOS-drag-and-drop-POC
Proof of concept, macOS drag and drop example. 

The idea behind this project, is to implement the template for Drag And Drop implementation of a document application. 

Trouble is, the Apple's own examples are lacking - in my experience. So here's an example, which should provide you with a template implementation of Drag And Drop. 

At the moment - there's one element of it, which does not work - and that's the drag and drop between the windows of the application. 


To recreate this problem:
- run the project
- create two windows
- in one of the windows, press the "+" button multiple times
- select one or more items drag and drop them to the other (blank) document window. 
- What should happen, is that the content is copied over. 

I'd appriciate any help with that. 


The bits that do work, is an implementation of file promise. This is useful, if creation of the file takes quite a long time - however you do want your UI to be smooth. 
The example document uses json serialisation, but please ignore that - it's just an example. 

Dragging and dropping to finder, and dragging from finder onto the document window works fully. 


