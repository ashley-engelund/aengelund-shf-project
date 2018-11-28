// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc.
//  javascripts have been loaded

//const SEARCH_NEAR_ME_IMG = 'assets/near-location-25x.jpg';

const STOCKHOLM_LAT = 59.3293235;
const STOCKHOLM_LONG = 18.068580;
const GOTHENBURG_LAT = 57.7089;
const GOTHENBURG_LONG = 11.9746;

const DEFAULT_LAT = STOCKHOLM_LAT;
const DEFAULT_LONG = STOCKHOLM_LONG;

const DEFAULT_DIST_KM = 20;

// FIXME: display a helpful message on the map if none were found.
//  do not change the center of the map

// TODO: refactor and clean up!
// TODO: retain the distance from the previous search

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
function initCenteredMap(centerCoordinates, markers, icon, nearMeCheckvalue,
                         isProduction) {

    if (markers.length === 0) {
        alert('Sorry.  No companies found.');
        return;
    }

    var mapCenter = {lat: DEFAULT_LAT, lng: DEFAULT_LONG};

    var marks = markers === null ? [] : markers;
    var optimize = isProduction === null ? false : isProduction;

    if (centerCoordinates === null) {
        mapCenter = getUserLocation(isProduction);
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

    if (!isProduction) {
        // add input boxes for setting the current location latitude & longitude
        var fakeCurrentLocationDiv = document.createElement('DIV');
        fakeCurrentLocationDiv.id = 'fake-current-location';
        FakeCurrentLocationInputs(fakeCurrentLocationDiv);
        fakeCurrentLocationDiv.index = 1;
        map.controls[google.maps.ControlPosition.LEFT_BOTTOM]
            .push(fakeCurrentLocationDiv);

    }

    // Create the DIV to hold the search near me button and call
    // the SearchNearMeCheckbox()
    // constructor passing in this DIV.
    var searchNearMeDiv = document.createElement('DIV');
    SearchNearMeButton(searchNearMeDiv, isProduction);
    searchNearMeDiv.index = 1;

    map.controls[google.maps.ControlPosition.TOP_LEFT].push(searchNearMeDiv);
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
 * The SearchNearMeCheckbox adds a checkbox to the given DIV (which should be
 * in a map)
 * that will
 * 1) geolocate the user and then
 * 2) send an AJAX request to the server to search near the user's location.
 *
 * If the user can not be geolocated (perhaps they have that option turned
 * off in
 * their browser), then....?
 *
 * When the checkbox is checked:
 * 1. The companies displayed on the map will be XXX km. from the user's
 * location
 * 2. Any futher filters (e.g. categories) will use that limited group of
 * companies
 *
 * When the checkbox is unchecked:
 * 1. The companies displayed on the map will not be limited by distance.
 * They may
 * still be limited/filtered by other conditions (e.g. categories, etc.)
 *
 * @param controlDiv - a DIV that the checkbox gets appended to
 * @param isChecked [Boolean] - whether or not the checkbox should be checked
 * @constructor
 */
function SearchNearMeCheckbox(controlDiv, isChecked, isProduction) {

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

    var distanceKM = document.createElement('INPUT');
    distanceKM.setAttribute('type', 'number');
    distanceKM.min = 0;
    distanceKM.value = DEFAULT_DIST_KM;
    distanceKM.id = 'distance-in-km';

    var withinDistanceLabel = document.createElement('LABEL');
    withinDistanceLabel.control = distanceKM;
    withinDistanceLabel.id = 'within-label';
    withinDistanceLabel.innerText = I18n
        .t('companies.index.search_near_me_within');

    searchNearMeDiv.appendChild(searchNearMeCheckbox);
    searchNearMeDiv.appendChild(checkboxLabel);
    searchNearMeDiv.appendChild(withinDistanceLabel);
    searchNearMeDiv.appendChild(distanceKM);
    controlDiv.appendChild(searchNearMeDiv);

    // Setup the click event listeners: simply set the map to Stockholm.
    searchNearMeCheckbox.addEventListener('click', function () {
        var nearParams = '';
        var parsedUrl = new URL(window.location.href);
        var searchParams = parsedUrl.searchParams.toString();

        if (this.checked) {
            nearCoords = getUserLocation(isProduction);
            distance = document.getElementById('distance-in-km').value;

            console_log_search(nearCoords.lat, nearCoords.lng, distance);
            nearParams = '&near=lat=' + nearCoords.lat + ',long=' +
                nearCoords.lng + ',dist=' + distance;
        }

        $.ajax({
            url: 'hundforetag',
            type: 'GET',
            data: searchParams + nearParams
        });

    });
}


/**
 * The SearchNearMeButton adds a checkbox to the given DIV (which should
 * be in a map)
 * that will
 * 1) geolocate the user and then
 * 2) send an AJAX request to the server to search near the user's location.
 *
 * If the user can not be geolocated (perhaps they have that option turned
 * off in
 * their browser), then....?
 *
 * When the checkbox is checked:
 * 1. The companies displayed on the map will be XXX km. from the user's
 * location
 * 2. Any futher filters (e.g. categories) will use that limited group of
 * companies
 *
 * When the checkbox is unchecked:
 * 1. The companies displayed on the map will not be limited by distance.
 * They may
 * still be limited/filtered by other conditions (e.g. categories, etc.)
 *
 * @param controlDiv - a DIV that the checkbox gets appended to
 * @package isProduction [Boolean] - whether or not the system is in production
 *              (vs. in development or testing)
 * @constructor
 */
function SearchNearMeButton(controlDiv, isProduction) {

    // outer box that holds the button and related text
    var searchNearMeDiv = document.createElement('DIV');
    searchNearMeDiv.id = 'search-near-me';

    // search near me text
    var searchNearMeText = document.createElement('SPAN');
    searchNearMeText.id = 'search-near-me-text';
    searchNearMeText.className = searchNearMeText.id;
    searchNearMeText.innerText = I18n.t('companies.index.search_near_me');

    var distanceKM = document.createElement('INPUT');
    distanceKM.setAttribute('type', 'number');
    distanceKM.min = 0;
    distanceKM.value = DEFAULT_DIST_KM;
    distanceKM.id = 'distance-in-km';
    distanceKM.className = distanceKM.id;

    var kmText = document.createElement('SPAN');
    kmText.id = 'km-text';
    kmText.className = searchNearMeText.className;
    kmText.innerText = 'km';

    var searchNearMeButton = document.createElement('INPUT');
    searchNearMeButton.setAttribute('type', 'submit');
    searchNearMeButton.id = 'search-near-me-button';
    searchNearMeButton.className = searchNearMeButton.id;
    searchNearMeButton.alt = 'Submit';
    searchNearMeButton.name = 'submit';
    // would be better as a FontAwesome icon!
    // searchNearMeButton.src = SEARCH_NEAR_ME_IMG;
    searchNearMeButton.innerText = I18n.t('search');
    searchNearMeButton.title = I18n.t('companies.index.search_near_me_title');



    searchNearMeDiv.appendChild(searchNearMeText);
    searchNearMeDiv.appendChild(distanceKM);
    searchNearMeDiv.appendChild(kmText);
    searchNearMeDiv.appendChild(searchNearMeButton);
    controlDiv.appendChild(searchNearMeDiv);

    // Setup the click event listeners: simply set the map to Stockholm.
    searchNearMeButton.addEventListener('click', function () {
        var nearParams = '';
        var parsedUrl = new URL(window.location.href);
        var searchParams = parsedUrl.searchParams.toString();

        nearCoords = getUserLocation(isProduction);
        distance = document.getElementById('distance-in-km').value;

        console_log_search(nearCoords.lat, nearCoords.lng, distance)
        nearParams = '&near=lat=' + nearCoords.lat + ',long=' +
            nearCoords.lng + ',dist=' + distance;

        $.ajax({
            url: 'hundforetag',
            type: 'GET',
            data: searchParams + nearParams
        });

    });
}


/**
 * @return boolean whether or not we can get the user's
 * current location from their browser
 */
function canGetUserLocation(isProduction) {
    var canGetIt = false;

    if (isProduction) {
        canGetIt = navigator.geolocation;
    } else {
        // get the location from the additional controls
        // shown only during development & test
        canGetIt = true;
    }

    return canGetIt;
}

/**
 * Show alert to the user saying we cannot get their location with a reminder
 * that they can allow us by changing their browser settings.
 */
function showAlertCantGetLocation() {
    alert(I18n.t('companies.index.cannot_get_location'));
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

    var currentCoordinates = new google.maps.LatLng(DEFAULT_LAT, DEFAULT_LONG);

    if (isProduction) {
        if (canGetUserLocation(isProduction)) {

            navigator.geolocation.getCurrentPosition(function (position) {
                currentCoordinates = new google.maps.LatLng(position.coords
                        .latitude,
                    position.coords.longitude);
            });
        } else {
            showAlertCantGetLocation();
        }

    } else { // is not Production so get the value from the UI
        currentCoordinates.lat = document
            .getElementById('fake-latitude-number')
            .value;
        currentCoordinates.lng = document
            .getElementById('fake-longitude-number')
            .value;
        console.log('fake latitude used:' + currentCoordinates.lat);
        console.log('fake longitude used:' + currentCoordinates.lng);
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
    fakeLocationTitle.innerText = I18n.t('companies.index.fake-location-title');

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
    fakeLatitudeTitle.innerText = I18n.t('companies.index.fake-latitude-title');

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
        .t('companies.index.fake-longitude-title');

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


function console_log_search(latitude, longitude, distance) {
    console.log('searching near lat:' + latitude +
        ' long:' + longitude +
        ' within: ' + distance);
}
