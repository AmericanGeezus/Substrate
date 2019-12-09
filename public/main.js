
var container = document.getElementById('cardContainer');

var sessionName = ""

socket.on('console', function (data) {

    var newDataCard = document.createElement('div')
    if (Array.isArray(data)) {
        if (Object.keys(data[0]).length <= 3 ) {
            newDataCard.classList = "itemCard"
        } else {
            if (data.length >= 15) {
                newDataCard.classList = "tableCard tall"
            } else {
                newDataCard.classList = "tableCard"
            }
        }

        newDataCard.appendChild(makeTable(data))
        container.appendChild(newDataCard);
    } else {

        newDataCard.classList = "itemCard"
        newDataCard.appendChild(makeItem(data))
        container.appendChild(newDataCard);
    }



});