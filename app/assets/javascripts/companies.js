$(document).ready(function () {

    $('.dinkurs-fetch').on('ajax:before',  function(event, data) {
        // show some sort of spinner or message to let them know the fetch is happening...
    });

    $('.dinkurs-fetch').on('ajax:complete',  function(event, data) {
        // hide the spinner or message to let them know the fetch is happening...
    });

    $('.dinkurs-fetch').on('ajax:success',  function(event, data) {
        $('#dinkurs-events').html(data);
    });

});
