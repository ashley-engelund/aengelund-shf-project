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

var SHOW_NEAR_ME_DIV_ID = 'show-near-me';
var CANT_GET_LOC_CHECKBOX_ID = 'cant-get-location-checkbox';

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


    if (showNearMeControl) {

        if (!isProduction) {
            // add input boxes for setting the current location latitude & longitude
            var fakeCurrentLocationDiv = makeFakeLocationControl();

            fakeCurrentLocationDiv.index = 1;
            map.controls[google.maps.ControlPosition.LEFT_BOTTOM]
                .push(fakeCurrentLocationDiv);
        }

        // Create the DIV to hold the search near me button and call
        // the SearchNearMeButton() method passing in this DIV.
        var searchNearMeDiv = document.createElement('DIV');
        showNearMeButton(map, searchNearMeDiv, isProduction);
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
 * The showNearMeButton adds a button to the given DIV (which should
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
 */
function showNearMeButton(map, controlDiv, isProduction) {

    // outer box that holds the button and related text
    var showNearMeDiv = document.createElement('DIV');
    showNearMeDiv.id = SHOW_NEAR_ME_DIV_ID;

    // show near me text
    var showNearMeText = document.createElement('SPAN');
    showNearMeText.id = SHOW_NEAR_ME_DIV_ID + '-text';
    showNearMeText.className = showNearMeText.id;
    showNearMeText.innerText = I18n.t('companies.index.show_near_me');


    var showNearMeButton = document.createElement('INPUT');
    showNearMeButton.setAttribute('type', 'button');
    showNearMeButton.id = SHOW_NEAR_ME_DIV_ID + '-button';
    showNearMeButton.className = showNearMeButton.id;
    showNearMeButton.alt = I18n.t('companies.index.show_near_me');
    showNearMeButton.name = 'submit';

    showNearMeDiv.appendChild(showNearMeButton);
    showNearMeDiv.appendChild(showNearMeText);
    controlDiv.appendChild(showNearMeDiv);

    // Setup the click event listeners: center the map on their location
    showNearMeButton.addEventListener('click', function () {

        var nearCoords = getUserLocation(isProduction);

        if (!(nearCoords === null)) {

            map.setCenter(nearCoords);
            google.maps.event.addListenerOnce(map, 'bounds_changed', function () {
                map.setZoom(SHOW_ZOOM_LEVEL);
            });
        }
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
var geoError = function () {
    showAlertCantGetLocation();
    console.log('geolocation Error occurred.');
};


/**
 * Create elements for use in development and testing to enter a
 * faked current user location,.
 *
 * @return DIV - a div with the fake location controls added as child nodes
 */
function makeFakeLocationControl() {


    function makeCannotGetLocationCheckboxAndLabel() {

        var cantGetCheckbox = document.createElement('INPUT');
        cantGetCheckbox.type = "checkbox";
        cantGetCheckbox.id = CANT_GET_LOC_CHECKBOX_ID;
        cantGetCheckbox.className = cantGetCheckbox.id;
        cantGetCheckbox.value = false;

        var cantGetLabel = document.createElement('LABEL');
        cantGetLabel.for = cantGetCheckbox;
        cantGetLabel.innerText = I18n.t('companies.index.fake_cant_get_location');

        return [cantGetCheckbox, cantGetLabel];
    }


    /**
     *  Make radio buttons, titles, etc. to select the coordinates used for the
     *  fake location.
     *  Add them to the parent DIV passed in
     *
     *  @param parentDiv - the DIV to add all of these elements to
     *  @return the updated parentDiv with the radio button element added to it
     */
    function makeFakeLocationRadioButtons(parentDiv) {

        function makeRadioButtonFor(rbName, rbValue, isChecked) {
            var newRadioButton = document.createElement('INPUT');
            newRadioButton.setAttribute('type', 'radio');
            newRadioButton.name = rbName;
            newRadioButton.id = radioButtonName(rbValue);
            newRadioButton.className = newRadioButton.id;
            newRadioButton.value = rbValue;
            newRadioButton.checked = isChecked;
            newRadioButton.className = newRadioButton.id;
            return newRadioButton;
        }


        function makeRadioButtonAndLabel(rbName, labelText, isChecked) {
            var newRadioButton = makeRadioButtonFor(rbName, (labelText.toLowerCase()), isChecked);
            var newLabel = document.createElement('LABEL');
            newLabel.for = newRadioButton;
            newLabel.innerText = labelText;
            newLabel.className = 'radio-button-label-' + labelText.toLowerCase();
            return [newRadioButton, newLabel];
        }


        var buttonGroupName = 'preset-coords';

        // radio buttons to automatically enter coords
        // for  Stockholm, Gothenburg, or a custom location
        var [stockholmRadioButton, stockholmLabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Stockholm', true);

        var [gothenburgRadioButton, gothenburgLabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Gothenburg', false);

        var [customLocationRadioButton, customLocationlabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Custom', false);


        function makeCoodinateInput(labelText, basename, value) {

            var newInput = document.createElement('INPUT');
            newInput.setAttribute('type', 'number');
            newInput.id = numberInputName('fake-' + basename);
            newInput.name = newInput.id;
            newInput.className = 'fake-coordinate';
            newInput.defaultValue = value;
            newInput.value = value;

            var newInputTitle = document.createElement('LABEL');
            newInputTitle.for = newInput.id;
            newInputTitle.id = 'fake-' + basename + '-title';
            newInputTitle.name = newInputTitle.id;
            newInputTitle.className = 'fake-title';
            newInputTitle.innerText = labelText;

            return [newInput, newInputTitle];
        }

        var [fakeLatitudeInput, fakeLatitudeTitle] = makeCoodinateInput(I18n.t('companies.index.fake_latitude_title'),
            'latitude', DEFAULT_LAT);

        var [fakeLongitudeInput, fakeLongitudeTitle] = makeCoodinateInput(I18n.t('companies.index.fake_longitude_title'),
            'longitude', DEFAULT_LONG);


        stockholmRadioButton.addEventListener('click', function () {
            fakeLatitudeInput.value = STOCKHOLM_LAT;
            fakeLongitudeInput.value = STOCKHOLM_LONG;
        });

        gothenburgRadioButton.addEventListener('click', function () {
            fakeLatitudeInput.value = GOTHENBURG_LAT;
            fakeLongitudeInput.value = GOTHENBURG_LONG;
        });


        var fakeInputValsDiv = document.createElement('DIV');
        fakeInputValsDiv.id = 'fake-input-values-div';
        fakeInputValsDiv.className = fakeInputValsDiv.id;

        fakeInputValsDiv.appendChild(stockholmRadioButton);
        fakeInputValsDiv.appendChild(stockholmLabel);

        fakeInputValsDiv.appendChild(gothenburgRadioButton);
        fakeInputValsDiv.appendChild(gothenburgLabel);

        fakeInputValsDiv.appendChild(document.createElement('BR'));

        fakeInputValsDiv.appendChild(customLocationRadioButton);
        fakeInputValsDiv.appendChild(customLocationlabel);

        fakeInputValsDiv.appendChild(fakeLatitudeTitle);
        fakeInputValsDiv.appendChild(fakeLatitudeInput);
        fakeInputValsDiv.appendChild(fakeLongitudeTitle);
        fakeInputValsDiv.appendChild(fakeLongitudeInput);

        parentDiv.appendChild(fakeInputValsDiv);
        return parentDiv;
    }


    // The controls that are used to set a 'fake' location or 'fake' that the
    // browser cannot provide the location (buttons, etc)
    function buildFakeControlDiv() {

        // outer box that holds the inputs
        var fakeControlDiv = document.createElement('DIV');
        fakeControlDiv.id = 'fake-inputs';

        var fakeLocationTitle = document.createElement('P');
        fakeLocationTitle.className = 'fake-location-title';
        fakeLocationTitle.innerText = I18n.t('companies.index.fake_location_title');

        fakeControlDiv.appendChild(fakeLocationTitle);

        var [cantGetLocCheckbox,
            cantGetLocLabel] = makeCannotGetLocationCheckboxAndLabel(fakeControlDiv);

        fakeControlDiv.appendChild(cantGetLocCheckbox);
        fakeControlDiv.appendChild(cantGetLocLabel);
        fakeControlDiv.appendChild(document.createElement('BR'));

        fakeControlDiv = makeFakeLocationRadioButtons(fakeControlDiv);

        return fakeControlDiv;
    }


    var fakeCurrentLocationDiv = document.createElement('DIV');
    fakeCurrentLocationDiv.id = 'fake-current-location';

    fakeCurrentLocationDiv.appendChild(buildFakeControlDiv());

    return fakeCurrentLocationDiv;

}


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

    var currentCoordinates;

    if (isProduction) {

        navigator.geolocation.getCurrentPosition(function (position) {
                currentCoordinates = new google.maps.LatLng(position.coords
                        .latitude,
                    position.coords.longitude);
            },
            geoError);

    } else { // is not Production so get the fake values from the UI
        currentCoordinates = setFakeCoordinates();

        return currentCoordinates;
    }

}


    function setFakeCoordinates() {

        //if checkbox is checked,error.
        var cantGetCheckbox = document.getElementById(CANT_GET_LOC_CHECKBOX_ID);

        if (cantGetCheckbox.checked) {
            geoError();
            return null;

        } else {
            // else get the coordinates and set them
            var lat = document
                .getElementById(numberInputName('fake-latitude'))
                .value;
            var lng = document
                .getElementById(numberInputName('fake-longitude'))
                .value;

            currentCoordinates = new google.maps.LatLng(lat, lng);

            console.log('fake latitude used:' + currentCoordinates.lat());
            console.log('fake longitude used:' + currentCoordinates.lng());

            return currentCoordinates;
        }

    }

    function numberInputName(basename) {
        return 'input-number-' + basename;
    }


    function radioButtonName(basename) {
        return 'radio-button-' + basename;
    }


    function logSearchToConsole(latitude, longitude) {
        console.log('searching near lat:' + latitude +
            ' long:' + longitude);
    }
