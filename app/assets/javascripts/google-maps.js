// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc.
//  javascripts have been loaded

//var SEARCH_NEAR_ME_IMG = 'assets/near-location-25x.jpg';

var SWEDEN_CENTER_LAT = 59.6749712;
var SWEDEN_CENTER_LONG = 14.5208584;
var STOCKHOLM_LAT = 59.3293235;
var STOCKHOLM_LONG = 18.068580;
var GOTHENBURG_LAT = 57.7089;
var GOTHENBURG_LONG = 11.9746;

var DEFAULT_LAT = STOCKHOLM_LAT;
var DEFAULT_LONG = STOCKHOLM_LONG;

var SHOW_ZOOM_LEVEL = 8;

// TODO: refactor and clean up!



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
//  If it _is_ optimized, then the map is just a canvas and we will
//  not be able to
//  test for specific marker or other elements on it.
//  If it is _not_ optimized, then we will be able to test for
//  specific elements;
//  we need to do this if we are developing or testing.
//
//  @url https://mixandgo.com/learn/how-to-write-a-cucumber-test-for-google-maps
//
function initCenteredMap(centerCoordinates, markers, icon, showNearMeControl,
                         isProduction) {

    if (markers.length === 0) {
        alert(I18n.t('companies.index.no_search_results'));
        return;
    }

    // use the center of Sweden as the default location
    var mapCenter = new google.maps.LatLng(SWEDEN_CENTER_LAT, SWEDEN_CENTER_LONG);

    var marks = markers === null ? [] : markers;
    var optimize = isProduction === null ? false : isProduction;

    if (!(centerCoordinates === null)) {
        mapCenter =  centerCoordinates;
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


    if (showNearMeControl) {

        if (!isProduction) {
            // add input boxes for setting the current location latitude & longitude
            var fakeCurrentLocationDiv = document.createElement('DIV');
            fakeCurrentLocationDiv.id = 'fake-current-location';
            new FakeCurrentLocationInputs(fakeCurrentLocationDiv);
            fakeCurrentLocationDiv.index = 1;
            map.controls[google.maps.ControlPosition.LEFT_BOTTOM]
                .push(fakeCurrentLocationDiv);
        }

        // Create the DIV to hold the search near me button and call
        // the SearchNearMeButton()
        // constructor passing in this DIV.
        var searchNearMeDiv = document.createElement('DIV');
        new ShowNearMeButton(map, searchNearMeDiv, isProduction);
        searchNearMeDiv.index = 1;

        map.controls[google.maps.ControlPosition.TOP_LEFT].push(searchNearMeDiv);
    }

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
 * The ShowNearMeButton adds a button to the given DIV (which should
 * be in a map) that will:
 * 1) geolocate the user and then
 * 2) center the map on that location
 * 3) zoom to
 *
 * If the user can not be geolocated (perhaps they have that option turned
 * off in
 * their browser), then an alert is shown about that.
 *
 * @param map [Google map] - the Google map that we are using
 * @param controlDiv - a DIV that the button gets appended to
 * @param isProduction [Boolean] - whether or not the system is in production
 *              (vs. in development or testing)
 * @constructor
 */
function ShowNearMeButton(map, controlDiv, isProduction) {

    // outer box that holds the button and related text
    var showNearMeDiv = document.createElement('DIV');
    showNearMeDiv.id = 'show-near-me';

    // show near me text
    var showNearMeText = document.createElement('SPAN');
    showNearMeText.id = 'show-near-me-text';
    showNearMeText.className = showNearMeText.id;
    showNearMeText.innerText = I18n.t('companies.index.show_near_me');


    var showNearMeButton = document.createElement('INPUT');
    showNearMeButton.setAttribute('type', 'button');
    showNearMeButton.id = 'show-near-me-button';
    showNearMeButton.className = showNearMeButton.id;
    showNearMeButton.alt = I18n.t('companies.index.show_near_me');
    showNearMeButton.name = 'submit';

    showNearMeDiv.appendChild(showNearMeButton);
    showNearMeDiv.appendChild(showNearMeText);
    controlDiv.appendChild(showNearMeDiv);

    // Setup the click event listeners: center the map on their location
    showNearMeButton.addEventListener('click', function () {

        var nearCoords = getUserLocation(isProduction);

        map.setCenter(nearCoords);
        google.maps.event.addListenerOnce(map, 'bounds_changed', function() {
            map.setZoom(SHOW_ZOOM_LEVEL);
        });
    });
}


/**
 * Show alert to the user saying we cannot get their location with a reminder
 * that they can allow us by changing their browser settings.
 */
function showAlertCantGetLocation() {
    alert(I18n.t('companies.index.cannot_get_location'));
}


// error.code can be:
//   0: unknown error
//   1: permission denied
//   2: position unavailable (error response from location provider)
//   3: timed out
var geoError = function (error) {
    switch (error.code) {
        case error.PERMISSION_DENIED:
            showAlertCantGetLocation();
            break;
        case error.TIMEOUT:
            // The user didn't accept the callout
            //  showNudgeBanner();
            showAlertCantGetLocation();
            break;
        case error.POSITION_UNAVAILABLE:
            showAlertCantGetLocation();
            break;
    }
    console.log('geolocation Error occurred. Error code: ' + error.code);
};


/**
 * Get the current location of the user from their browser.

 * If we cannot get the current location,
 *  show an alert to the user and
 *  return the DEFAULT_LAT and DEFAULT_LONG
 *
 * @return google.maps.LatLng
 *          The current location for the user,
 *          either from their browser or, if testing or in development,
 *          values entered in the UI
 **/
function getUserLocation(isProduction) {

    var currentCoordinates = new google.maps.LatLng(DEFAULT_LAT, DEFAULT_LONG);


    if (isProduction) {

        navigator.geolocation.getCurrentPosition(function (position) {
                currentCoordinates = new google.maps.LatLng(position.coords
                        .latitude,
                    position.coords.longitude);
            },
            geoError);

    } else { // is not Production so get the value from the UI
        var lat = document
            .getElementById('fake-latitude-number')
            .value;
        var lng = document
            .getElementById('fake-longitude-number')
            .value;

        currentCoordinates = new google.maps.LatLng(lat, lng);

        console.log('fake latitude used:' + currentCoordinates.lat());
        console.log('fake longitude used:' + currentCoordinates.lng());
    }

    return currentCoordinates;
}


/**
 * Create elements for use in development and testing to enter a
 * faked current user location
 *
 * @param controlDiv - a DIV all of this gets appended to
 * @constructor
 */
function FakeCurrentLocationInputs(controlDiv) {

    // outer box that holds the inputs
    var fakeLocInputsDiv = document.createElement('DIV');
    fakeLocInputsDiv.id = 'fake-inputs';

    var fakeLocationTitle = document.createElement('P');
    fakeLocationTitle.className = 'fake-location-title';
    fakeLocationTitle.innerText = I18n.t('companies.index.fake_location_title');

    // radio buttons to automatically enter coords
    // for either Stockholm or Gothenburg
    var stockholmRadioButton = document.createElement('INPUT');
    stockholmRadioButton.setAttribute('type', 'radio');
    stockholmRadioButton.id = 'radio-button-stockholm';
    stockholmRadioButton.name = 'preset-coords';
    stockholmRadioButton.value = 'stockholm';
    stockholmRadioButton.checked = true;

    var stockholmLabel = document.createElement('LABEL');
    stockholmLabel.for = stockholmRadioButton;
    stockholmLabel.innerText = 'Stockholm';

    var gothenburgRadioButton = document.createElement('INPUT');
    gothenburgRadioButton.setAttribute('type', 'radio');
    gothenburgRadioButton.id = 'radio-button-gothenburg';
    gothenburgRadioButton.name = 'preset-coords';
    gothenburgRadioButton.value = 'gothenburg';
    var gothenburgLabel = document.createElement('LABEL');
    gothenburgLabel.for = gothenburgRadioButton;
    gothenburgLabel.innerText = 'Gothenburg';


    var fakeLatitudeInput = document.createElement('INPUT');
    fakeLatitudeInput.setAttribute('type', 'number');
    fakeLatitudeInput.id = 'fake-latitude-number';
    fakeLatitudeInput.name = fakeLatitudeInput.id;
    fakeLatitudeInput.className = 'fake-coordinate';
    fakeLatitudeInput.defaultValue = DEFAULT_LAT;
    fakeLatitudeInput.value = DEFAULT_LAT;

    var fakeLatitudeTitle = document.createElement('LABEL');
    fakeLatitudeTitle.for = fakeLatitudeInput.id;
    fakeLatitudeTitle.id = 'fake-latitude-title';
    fakeLatitudeTitle.className = 'fake-title';
    fakeLatitudeTitle.name = fakeLatitudeTitle.id;
    fakeLatitudeTitle.innerText = I18n.t('companies.index.fake_latitude_title');

    var fakeLongitudeInput = document.createElement('INPUT');
    fakeLongitudeInput.setAttribute('type', 'number');
    fakeLongitudeInput.id = 'fake-longitude-number';
    fakeLongitudeInput.name = fakeLongitudeInput.id;
    fakeLongitudeInput.className = 'fake-coordinate';
    fakeLongitudeInput.defaultValue = DEFAULT_LONG;
    fakeLongitudeInput.value = DEFAULT_LONG;

    var fakeLongitudeTitle = document.createElement('LABEL');
    fakeLongitudeTitle.for = fakeLongitudeTitle.id;
    fakeLongitudeTitle.id = 'fake-longitude-title';
    fakeLongitudeTitle.className = 'fake-title';
    fakeLongitudeTitle.name = fakeLongitudeTitle.id;
    fakeLongitudeTitle.innerText = I18n
        .t('companies.index.fake_longitude_title');

    fakeLocInputsDiv.appendChild(fakeLocationTitle);
    fakeLocInputsDiv.appendChild(stockholmLabel);
    fakeLocInputsDiv.appendChild(stockholmRadioButton);
    fakeLocInputsDiv.appendChild(gothenburgLabel);
    fakeLocInputsDiv.appendChild(gothenburgRadioButton);

    fakeLocInputsDiv.appendChild(document.createElement('BR'));

    fakeLocInputsDiv.appendChild(fakeLatitudeTitle);
    fakeLocInputsDiv.appendChild(fakeLatitudeInput);
    fakeLocInputsDiv.appendChild(fakeLongitudeTitle);
    fakeLocInputsDiv.appendChild(fakeLongitudeInput);
    controlDiv.appendChild(fakeLocInputsDiv);

    // Setup the click event for the radio buttons so they automatically enter
    // coordinates
    // when clicked

    stockholmRadioButton.addEventListener('click', function () {
        fakeLatitudeInput.value = STOCKHOLM_LAT;
        fakeLongitudeInput.value = STOCKHOLM_LONG;
    });

    gothenburgRadioButton.addEventListener('click', function () {
        fakeLatitudeInput.value = GOTHENBURG_LAT;
        fakeLongitudeInput.value = GOTHENBURG_LONG;
    });
}


function logSearchToConsole(latitude, longitude) {
    console.log('searching near lat:' + latitude +
        ' long:' + longitude );
}
