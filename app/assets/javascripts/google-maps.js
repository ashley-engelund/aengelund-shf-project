// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc. javascripts have been loaded


// Display a dynamic Google map
//  centerCoordinates: the initial center for the map.
//   (= Stockholm if none given  [59.32932349999999, 18.0685808])
//  markers = an array of markers to display on the map
//  icon = the icon to use for each of the markers
//
//  If there is only 1 marker for the map, center the map on that marker
//  else display all of the markers,and so the center is automatically
//   determined by the center of all of them.
//
//  We need to tell GoogleMaps whether or not we want it to be optimized or not.
//  If it _is_ optimized, then the map is just a canvas and we will not be able to
//  test for specific marker or other elements on it.
//  If it is _not_ optimized, then we will be able to test for specific elements;
//  we need to do this if we are developing or testing.
//
//  @url https://mixandgo.com/learn/how-to-write-a-cucumber-test-for-google-maps
//
function initCenteredMap(centerCoordinates, markers, icon, nearMeCheckvalue, doOptimize) {

    var mapCenter = {lat: 59.3293235, lng: 18.0685808};

    var marks = markers === null ? [] : markers;
    var optimize = doOptimize === null ? false : doOptimize;

    if (centerCoordinates === null) {
        // try to get the user's coordinates
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                mapCenter = new google.maps.LatLng(position.coords.latitude,
                    position.coords.longitude);
            });
        }
    } else {
        mapCenter = centerCoordinates;
    }

    var map = new google.maps.Map(document.getElementById('map'), {
        center: mapCenter,
        zoom: 13,

        mapTypeControl: false  // hide this control to save space.

    });

    var bounds = new google.maps.LatLngBounds();

    addMarkersToMap(map, marks, bounds, icon, optimize);

    //now fit the map to the newly inclusive bounds
    // this will zoom in too far if there's only 1 marker
    if (marks.length > 1) {
        map.fitBounds(bounds);
    }

    // Create the DIV to hold the search near me button and call the SearchNearMeCheckbox()
    // constructor passing in this DIV.
    var searchNearMeCheckboxDiv = document.createElement('div');
    SearchNearMeCheckbox(searchNearMeCheckboxDiv, nearMeCheckvalue);
    searchNearMeCheckboxDiv.index = 1;

    map.controls[google.maps.ControlPosition.TOP_LEFT].push(searchNearMeCheckboxDiv);
}


// add the markers to the map that is defined on the page with id = 'map'
function addMarkersToMap(map, markers, bounds, icon, optimize) {

    // if the map doesn't exist, do nothing
    if (document.getElementById('map') !== null) {

        var marks = markers === null ? [] : markers;
        var bound = bounds === null ? new google.maps.LatLngBounds() : bounds;


        for (var i = 0, len = marks.length; i < len; i++) {

            var position = {
                lat: marks[i].latitude,
                lng: marks[i].longitude
            };

            addMarker(position, map, marks[i].text, icon, optimize);

            //extend the bounds to include the position for this marker
            bound.extend(position);
        }
    }

}


// get the text from element with id = element_id
//  if there is no element_id in the document, return an empty string
function getMarkerText(elementId) {
    var text = '';

    if (document.getElementById(elementId) !== null) {
        text = document.getElementById(elementId).childNodes[0].nodeValue;
    }
    return text.trim();
}


// get the value for the element with id element_id and convert it to a Number
//  If there is no element_id in the document, show an error on the console
function getNumber(elementId) {

    if (document.getElementById(elementId) !== null) {
        return parseFloat(document.getElementById(elementId).childNodes[0].nodeValue);
    } else {
        console.error("Expected document to have an element with id '" + elementId + "' but it did not.");
    }

}


// Create a marker. Optionally, set the icon to be used for it
// When it's clicked, pop-up a box with text in it
function addMarker(coordinates, map, text, icon, optimize) {
    var marker;

    marker = new google.maps.Marker({
        position: coordinates,
        map: map,
        icon: icon,
        optimized: optimize
    });

    // don't create a pop-up box if there's no text to display
    if (text !== '') {
        google.maps.event.addListener(marker, 'click', function () {
            createInfoWindow(text).open(map, marker);
        });
    }

    return marker;
}


// pop-up window with text
function createInfoWindow(text) {
    return new google.maps.InfoWindow({
        content: text
    });
}


/**
 * The SearchNearMeCheckbox adds a checkbox to the given DIV (which should be in a map)
 * that will
 * 1) geolocate the user and then
 * 2) send an AJAX request to the server to search near the user's location.
 *
 * If the user can not be geolocated (perhaps they have that option turned off in
 * their browser), then....?
 *
 * When the checkbox is checked:
 * 1. The companies displayed on the map will be XXX km. from the user's location
 * 2. Any futher filters (e.g. categories) will use that limited group of companies
 *
 * When the checkbox is unchecked:
 * 1. The companies displayed on the map will not be limited by distance.  They may
 * still be limited/filtered by other conditions (e.g. categories, etc.)
 *
 * @param controlDiv - a DIV that the checkbox gets appended to
 * @param isChecked [Boolean] - whether or not the checkbox should be checked
 * @constructor
 */
function SearchNearMeCheckbox(controlDiv, isChecked) {

    // outer box that holds the checkbox
    var searchNearMeDiv = document.createElement('DIV');
    searchNearMeDiv.id = 'search-near-me';

    var searchNearMeCheckbox = document.createElement('INPUT');
    searchNearMeCheckbox.setAttribute('type', 'checkbox');
    searchNearMeCheckbox.id = 'search-near-me-checkbox';
    searchNearMeCheckbox.className = 'search-near-me';
    searchNearMeCheckbox.title = I18n.t('companies.index.search_near_me_title');

    searchNearMeCheckbox.checked = isChecked;

    // text for the checkbox
    var checkboxLabel = document.createElement('LABEL');
    checkboxLabel.control = searchNearMeCheckbox;
    checkboxLabel.id = 'checkbox-label';
    checkboxLabel.innerText = I18n.t('companies.index.search_near_me');

    searchNearMeDiv.appendChild(searchNearMeCheckbox);
    searchNearMeDiv.appendChild(checkboxLabel);
    controlDiv.appendChild(searchNearMeDiv);

    // Setup the click event listeners: simply set the map to Stockholm.
    searchNearMeCheckbox.addEventListener('click', function () {
        var nearParams = '';
        var parsedUrl = new URL(window.location.href);
        var searchParams = parsedUrl.searchParams.toString();

        if ( this.checked ) {
            nearParams = '&near=lat=59.3293235,long=18.0685808,dist=100';
        }

        $.ajax({
            url: 'hundforetag',
            type: 'GET',
            data: searchParams + nearParams
        });

    });
}
