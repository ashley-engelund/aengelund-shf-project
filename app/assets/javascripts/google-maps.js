/*global google, I18n*/
// ^^ this tells eslint that these globals are OK


// Don't load until after the code in the window has loaded.
//  because we have to be sure that jquery, google maps etc.
//  javascripts have been loaded

const SWEDEN_CENTER_LAT = 59.6749712;
const SWEDEN_CENTER_LONG = 14.5208584;

const STOCKHOLM_LAT = 59.3293235;
const STOCKHOLM_LONG = 18.068580;

const GOTHENBURG_LAT = 57.7089;
const GOTHENBURG_LONG = 11.9746;

const DEFAULT_LAT = SWEDEN_CENTER_LAT;
const DEFAULT_LONG = SWEDEN_CENTER_LONG;

const SHOW_ZOOM_LEVEL = 9;
const ZOOM_LEVEL_NO_MARKERS = 4;


const SHOW_NEAR_ME_DIV_ID = 'show-near-me';
const CANT_GET_LOC_CHECKBOX_ID = 'cant-get-location-checkbox';

/**
 *
 * Display a dynamic Google map
 *  centerCoordinates: the initial center for the map.
 *                     (= center of Sweden if none given)
 *  markers = an array of markers to display on the map
 *
 *  If there is only 1 marker for the map, center the map on that marker
 *  else display all of the markers,and so the center is automatically
 *   determined by the center of all of them.
 *
 *  Tell GoogleMaps whether or not we want it to be optimized or not.
 *  If it _is_ optimized, then the map is just a canvas and we will
 *  not be able to test for specific marker or other elements on it.
 *  If it is _not_ optimized, then we will be able to test for
 *  specific elements;
 *  we need to do this if we are developing or testing.
 *
 *  Helpful example code:
 *  @url https://bagja.net/blog/track-user-location-google-maps.html
 *
 *  @url https://mixandgo.com/learn/how-to-write-a-cucumber-test-for-google-maps
 *
 */
function initCenteredMap(centerCoordinates, markers, showNearMeControl,
                         isProduction) {

    // use the center of Sweden as the default location
    let mapCenter = new google.maps.LatLng(DEFAULT_LAT, DEFAULT_LONG);

    const marks = markers === null ? [] : markers;
    const optimize = isProduction === null ? false : isProduction;

    if (!(centerCoordinates === null)) {
        mapCenter = centerCoordinates;
    }

    const zoomLevel = (marks.length === 0) ? ZOOM_LEVEL_NO_MARKERS : SHOW_ZOOM_LEVEL;

    const map = createMap(mapCenter, zoomLevel, !showNearMeControl);

    const bounds = new google.maps.LatLngBounds();
    addMarkersToMap(map, marks, bounds, optimize);

    //now fit the map to the newly inclusive bounds
    // this will zoom in quite far if there's only 1 marker
    if (marks.length > 1) {
        map.fitBounds(bounds);
    }

    if (showNearMeControl) {

        if (!isProduction) {
            // add input boxes for faking the current location latitude & longitude
            const fakeCurrentLocationDiv = makeFakeLocationControlDiv();

            fakeCurrentLocationDiv.style.zIndex = 1;
            map.controls[google.maps.ControlPosition.LEFT_BOTTOM]
                .push(fakeCurrentLocationDiv);
        }

        // Create the DIV to hold the search near me button
        const searchNearMeDiv = document.createElement('DIV');
        showNearMeButton(map, searchNearMeDiv, isProduction);
        searchNearMeDiv.index = 1;

        map.controls[google.maps.ControlPosition.TOP_LEFT].push(searchNearMeDiv);
    }

}


function createMap({lat, lng}, zoomLevel, showMapTypeControl) {
    return new google.maps.Map(document.getElementById('map'), {
        center: {lat, lng},
        zoom: zoomLevel,
        mapTypeControl: showMapTypeControl
    });
}


// add the markers to the map that is defined on the page with id = 'map'
function addMarkersToMap(map, markers, bounds, optimize) {

    // if the map doesn't exist, do nothing
    if (document.getElementById('map') !== null) {

        const marks = markers === null ? [] : markers;
        const bound = bounds === null ? new google.maps.LatLngBounds() : bounds;


        let i = 0;
        const len = marks.length;
        for (; i < len; i++) {

            const position = {
                lat: marks[i].latitude,
                lng: marks[i].longitude
            };

            addMarker(position, map, marks[i].text, optimize);

            //extend the bounds to include the position for this marker
            bound.extend(position);
        }
    }
}


// get the text from element with id = element_id
//  if there is no element_id in the document, return an empty string
function getMarkerText(elementId) {
    let text = '';

    if (document.getElementById(elementId) !== null) {
        text = document.getElementById(elementId).childNodes[0].nodeValue;
    }
    return text.trim();
}


// Create a marker.
// When it's clicked, pop-up a box with text in it
function addMarker(coordinates, map, text, optimize) {
    let marker;

    marker = new google.maps.Marker({
        position: coordinates,
        map: map,
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
 * off in their browser), then an alert is shown.
 *
 * @param map [Google map] - the Google map that we are using
 * @param controlDiv - a DIV that the button gets appended to
 * @param isProduction [Boolean] - whether or not the system is in production
 *              (vs. in development or testing).  Needed to get the user's
 *              location
 */
function showNearMeButton(map, controlDiv, isProduction) {

    // outer box that holds the button and related text
    const showNearMeDiv = document.createElement('DIV');
    showNearMeDiv.id = SHOW_NEAR_ME_DIV_ID;

    // show near me text
    const showNearMeText = document.createElement('SPAN');
    showNearMeText.id = SHOW_NEAR_ME_DIV_ID + '-text';
    showNearMeText.className = showNearMeText.id;
    showNearMeText.innerText = I18n.t('companies.index.show_near_me');

    const showNearMeButton = document.createElement('INPUT');
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

        let currentLocCoords;

        if (isProduction) {

            // browser does not support geolocation
            if ('geolocation' in navigator === false) {
                alert( I18n.t('companies.index.geolocation_unsupported') );
            }

            // getCurrentPosition( function to call on success,
            //                      [optional] function to call on failure )
            navigator.geolocation.getCurrentPosition(
                // On success:
                position => {
                    console.log(`Lat: ${position.coords.latitude} Lng: ${position.coords.longitude}`);

                    currentLocCoords = new google.maps.LatLng(position.coords.latitude,
                        position.coords.longitude);

                    zoomMapTo(map, currentLocCoords, SHOW_ZOOM_LEVEL);
                },

                // On error
                err => alert(`Error (${err.code}): ${getPositionErrorMessage(err.code)}`)
            );

        }
        else {
            currentLocCoords = setFakeCoordinates();
            zoomMapTo(map, currentLocCoords, SHOW_ZOOM_LEVEL);
        }
    });
}


function zoomMapTo(map, centerCoords, zoomLevel) {
    map.setCenter(centerCoords);
    google.maps.event.addListenerOnce(map, 'bounds_changed', function () {
        map.setZoom(zoomLevel);
    });
}


/**
 * Get position error message from the given error code.
 * @param {number} code
 * @return {String} the error message to display, based on the code
 */
const getPositionErrorMessage = code => {
    switch (code) {
        case 1: // permission denied
            return I18n.t('companies.index.location_permission_denied');
        case 2: // position unavailable (error response from location provider)
            return I18n.t('companies.index.cannot_get_location');
        case 3: // request timed out
            return I18n.t('companies.index.cannot_get_location');
        default:
            return I18n.t('companies.index.cannot_get_location');
    }
};


/**
 * Create elements for use in development and testing to enter a
 * faked current user location.
 *
 *
 * @return DIV - a div with the fake location controls added as child nodes
 */
function makeFakeLocationControlDiv() {


    function makeCannotGetLocationCheckboxAndLabel() {

        const cantGetCheckbox = document.createElement('INPUT');
        cantGetCheckbox.type = "checkbox";
        cantGetCheckbox.id = CANT_GET_LOC_CHECKBOX_ID;
        cantGetCheckbox.className = cantGetCheckbox.id;
        cantGetCheckbox.value = false;

        const cantGetLabel = document.createElement('LABEL');
        cantGetLabel.for = cantGetCheckbox;
        cantGetLabel.innerText = I18n.t('companies.index.fake_cant_get_location');

        return [cantGetCheckbox, cantGetLabel];
    }


    /**
     *  Make and add radio buttons, titles, etc. to select the coordinates
     *  used for the fake location.
     *  Add them to the parent DIV passed in
     *
     *  @param parentDiv - the DIV to add all of these elements to
     *  @return the updated parentDiv with the radio button element added to it
     */
    function addFakeLocationRadioButtons(parentDiv) {

        function makeRadioButtonFor(rbName, rbValue, isChecked) {
            const newRadioButton = document.createElement('INPUT');
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
            const newRadioButton = makeRadioButtonFor(rbName, (labelText.toLowerCase()), isChecked);
            const newLabel = document.createElement('LABEL');
            newLabel.for = newRadioButton;
            newLabel.innerText = labelText;
            newLabel.className = 'radio-button-label-' + labelText.toLowerCase();
            return [newRadioButton, newLabel];
        }


        const buttonGroupName = 'preset-coords';

        // radio buttons to automatically enter coords
        // for  Stockholm, Gothenburg, or a custom location
        const [stockholmRadioButton, stockholmLabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Stockholm', true);

        const [gothenburgRadioButton, gothenburgLabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Gothenburg', false);

        const [customLocationRadioButton, customLocationlabel] = makeRadioButtonAndLabel(buttonGroupName,
            'Custom', false);


        function makeCoodinateInput(labelText, basename, value) {

            const newInput = document.createElement('INPUT');
            newInput.setAttribute('type', 'number');
            newInput.id = numberInputName('fake-' + basename);
            newInput.name = newInput.id;
            newInput.className = 'fake-coordinate';
            newInput.defaultValue = value;
            newInput.value = value;

            const newInputTitle = document.createElement('LABEL');
            newInputTitle.for = newInput.id;
            newInputTitle.id = 'fake-' + basename + '-title';
            newInputTitle.name = newInputTitle.id;
            newInputTitle.className = 'fake-title';
            newInputTitle.innerText = labelText;

            return [newInput, newInputTitle];
        }

        const [fakeLatitudeInput, fakeLatitudeTitle] = makeCoodinateInput(I18n.t('companies.index.fake_latitude_title'),
            'latitude', STOCKHOLM_LAT);

        const [fakeLongitudeInput, fakeLongitudeTitle] = makeCoodinateInput(I18n.t('companies.index.fake_longitude_title'),
            'longitude', STOCKHOLM_LONG);


        stockholmRadioButton.addEventListener('click', function () {
            fakeLatitudeInput.value = STOCKHOLM_LAT;
            fakeLongitudeInput.value = STOCKHOLM_LONG;
        });

        gothenburgRadioButton.addEventListener('click', function () {
            fakeLatitudeInput.value = GOTHENBURG_LAT;
            fakeLongitudeInput.value = GOTHENBURG_LONG;
        });


        const fakeInputValsDiv = document.createElement('DIV');
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
        let fakeControlDiv = document.createElement('DIV');
        fakeControlDiv.id = 'fake-inputs';

        const fakeLocationTitle = document.createElement('P');
        fakeLocationTitle.className = 'fake-location-title';
        fakeLocationTitle.innerText = I18n.t('companies.index.fake_location_title');

        fakeControlDiv.appendChild(fakeLocationTitle);

        const [cantGetLocCheckbox,
            cantGetLocLabel] = makeCannotGetLocationCheckboxAndLabel(fakeControlDiv);

        fakeControlDiv.appendChild(cantGetLocCheckbox);
        fakeControlDiv.appendChild(cantGetLocLabel);
        fakeControlDiv.appendChild(document.createElement('BR'));

        fakeControlDiv = addFakeLocationRadioButtons(fakeControlDiv);

        return fakeControlDiv;
    }


    const fakeCurrentLocationDiv = document.createElement('DIV');
    fakeCurrentLocationDiv.id = 'fake-current-location';

    fakeCurrentLocationDiv.appendChild(buildFakeControlDiv());

    return fakeCurrentLocationDiv;

}


function setFakeCoordinates() {

    //if checkbox is checked,error.
    const cantGetCheckbox = document.getElementById(CANT_GET_LOC_CHECKBOX_ID);

    if (cantGetCheckbox.checked) {
        alert( I18n.t('companies.index.location_permission_denied') );
        return null;

    } else {
        // else get the coordinates and set them
        const lat = document
            .getElementById(numberInputName('fake-latitude'))
            .value;
        const lng = document
            .getElementById(numberInputName('fake-longitude'))
            .value;

        const currentCoordinates = new google.maps.LatLng(lat, lng);

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
