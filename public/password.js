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

