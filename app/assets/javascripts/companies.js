$(function () {
    'use strict';

    $('#getDinkursEvents').on('ajax:success', function (e, data) {
        console.log('success!');
        html(data).appendTo("#dinkurs-events");
    });

});
