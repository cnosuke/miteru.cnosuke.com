$(function() {
    $('*')
        .ajaxStart    (function() { 
            $('#tweet_bt').attr('value', '送信中...');
            $('#tweet_bt').css('color', 'red');
        } );
    /* .ajaxComplete (function() { $('#progress').html('') } ); */
});
