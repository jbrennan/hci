$(document).ready(function () {
    start()
});

var count = 0;

function start() {
    $.getJSON('/' + site() + '/api/nextchunk/', function (data) {
        $('.password.entry img').css('display', 'none');
        var name = 'word' + count;
        count += 1;
        var chunk = "<span class='chunk'>$pre<span title='$clue'>" +
            "<input type='text' name='$name'></span>$post</span>";
        chunk = chunk.replace('$pre', data.pre).replace('$clue', data.clue)
            .replace('$post', data.post).replace('$name', name);
        $('.password.entry img').before(chunk);
        $('.password.entry input[type="image"]').css('display', 'inline');
    });
}

function site() {
    return document.location.pathname.split('/', 2)[1]
}

function next(tail) {
    // tail is the next/submit button
    $(tail).siblings('input[type="image"]').css('display', 'none');
    $(tail).siblings('img').css('display', 'inline');
    var input = $(tail).siblings().find('input[type="text"]').last();
    input.attr('disabled', true);
    
    var words = [];
    $(tail).siblings().find('input[type="text"]').each(function (i, elem) {
        words.push(elem.value);
    });
    words = words.join('/');

    $.getJSON('/' + site() + '/api/nextchunk/' + words, function (data) {
        $('.password.entry img').css('display', 'none');
        var name = 'word' + count;
        count += 1;
        var chunk = "<span class='chunk'>$pre<span title='$clue'>" +
            "<input type='text' name='$name'></span>$post</span>";
        chunk = chunk.replace('$pre', data.pre).replace('$clue', data.clue)
            .replace('$post', data.post).replace('$name', name);
        $('.password.entry img').before(chunk);
        $('.password.entry input[type="image"]').css('display', 'inline');
        $('.password.entry input[type="text"]').last().focus();
        if (data.last) {
            $('.password.entry input[type="image"]').replaceWith(
                "<input type='submit' value='Log In'>");
        }
    });
}

function form_cleanup() {
    // Before submitting the form, reenable the input boxes so they get
    // submitted.
    $('.password input[type="text"]').attr('disabled', false);
}

