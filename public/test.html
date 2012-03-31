<!doctype html>
<meta charset='UTF-8'>
<title>JAPJ Password Test</title>

<style type='text/css'>
.password input[type=text] {
    border: none;
    border-bottom: 1px solid #666;
    font-family: sans-serif;
    width: 10em;
}

.chunk span { position: relative; }
.chunk span::before {
    position: absolute;
    top: 110%;
    display: inline-block;
    width: 100%;
    text-align: center;
    content: attr(title);
    font-family: sans-serif;
    font-size: 75%;
    color: gray;
}

.password img, .password input[type=image] {
    height: 16px;
    width: 16px;
    display: inline-block;
}

.chunk {
    -moz-animation-duration: 0.5s;
    -moz-animation-name: addchunk;
    position: relative;
}

.chunk:first-child {
    -moz-animation-duration: 0s;
}

@-moz-keyframes addchunk {
    from {
        opacity: 0;
        left: -15em;
    }

    to {
        opacity: 1;
        left: 0;
    }
}

</style>


<h1>${appname}</h1>
<p>Log in to your ${appname} account:
<form method='POST'>
<p>Username: <input type='text' name='user' required>
<p>The password gnome told me:
<p class='password'><span class='chunk'>
        The <span title='creature'>
            <input type='text' name='blank' required>
            </span>
    </span>
<input id=x type='image' src='next.png' alt='→' onclick='return next(this)'></p>

</form>

<script type='application/javascript'>
function next(tail) {
    // tail is the next/submit button (or throbber)
    var input = tail.previousElementSibling.firstElementChild.firstElementChild;
    input.setAttribute('type', 'hidden');
    input.parentElement.insertBefore(document.createTextNode(input.value),
                                     input);
    input.parentElement.removeAttribute('title');

    tail.setAttribute('src', 'throbber.png');
    tail.setAttribute('alt', "Working...");
    tail.setAttribute('disabled', 'disabled');
    tail.blur();
    asyncGetNextChunk(tail.parentElement);
    return false;
}

function asyncGetNextChunk(parent) {
    // Pretend to submit data and get the next chunk.
    var data = [ "went to the ", "place", " " ];
    setTimeout(function() {nextchunk(parent, data)}, 1000);
}

function nextchunk(parent, data) {
    var chunk = document.createElement('span');
    chunk.setAttribute('class', 'chunk');
    chunk.appendChild(document.createTextNode(data[0]));
    var span = document.createElement('span');
    span.setAttribute('title', data[1]);
    var blank = document.createElement('input');
    blank.setAttribute('type', 'text');
    blank.setAttribute('name', 'blank'); //XXX should be unique & sequential
    blank.setAttribute('required', 'required');
    span.appendChild(blank);
    chunk.appendChild(span);
    chunk.appendChild(document.createTextNode(data[2]));
   
    var tail = parent.lastElementChild;
    parent.insertBefore(chunk, tail);
    tail.setAttribute('src', 'next.png');
    tail.setAttribute('alt', '→');
    tail.removeAttribute('disabled');
    blank.focus();
}

</script>

