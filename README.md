# PropFinder
###Udacity Nanodegree - Capstone Project

This is a property finder app for UK properties where you can search for specific parameters (location, bedroom number, price) and display the results on a map view using annotation views.

The app starts up with 3 tab views: MapViewController, SearchViewController and FavouriteViewController.

#### Screens

<img src="https://github.com/nhimkova/PropFinder/blob/master/ReadMe/mapviewcontroller.png" width="300" height="500" />
<img src="https://github.com/nhimkova/PropFinder/blob/master/ReadMe/searchviewcontroller.png" width="300" height="500" />
<img src="https://github.com/nhimkova/PropFinder/blob/master/ReadMe/favouriteviewcontroller.png" width="300" height="500" />
<img src="https://github.com/nhimkova/PropFinder/blob/master/ReadMe/propdetailviewcontroller.png" width="300" height="500" />
<img src="https://github.com/nhimkova/PropFinder/blob/master/ReadMe/launchscreen.PNG" width="300" height="500" />

#### MapViewController
This view controller displays the search results and saved properties. Search results are the orange color houses and saved properties are green color houses.
When tapping on a house, an annotation callout is displayed with an image of the property, the price. 
When tapping on the annotation callout, the property details are displayed in a new view controller.
When tapping on the Clear button on the navigation bar, the search results are removed from the map view. 
Search results are persisted in a temporary context.

#### SearchViewController
You can search for a spefific location name such as "Soho" or "Brighton". If you click on the arrow button, you can use the current map view location for the search.
Tap on the parameters you want to choose. When tapping the search button, the API request is sent and search results will be displayed on the MapViewController.
The map will zoom to the area of the new search results. When there are no results, an alert view controller pops up. 

#### FavouriteViewController
This screen shows the saved properties. When clicking on an item the PropDetailViewController will show, where we can delete the item if we wanted to.

#### PropDetailViewController
This screen shows the property details. When the property is not yet saved, we can save it by clicking on the heart on the right bottom corner of the image (it will turn red).
When the property is already favourited and we want to delete it, click on the heart again (it will turn grey). 
