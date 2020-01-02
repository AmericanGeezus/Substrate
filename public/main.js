
var container = document.getElementById('cardContainer');
const longValueLength = 15
var longKeys = []
var sessionName = ""
var longValues = false
var cardCount = 0


function handleDblClick(element){
    const selection = window.getSelection()
    selection.removeAllRanges();
    const range = document.createRange()
    range.selectNodeContents(element)
    selection.addRange(range)
}
function handleClick(element){
    const selection = window.getSelection()
    selection.removeAllRanges();
    const range = document.createRange()
    range.selectNodeContents(element)
    selection.addRange(range)
}


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
        newDataCard.id = "DataCard_" + cardCount
        //registerMouseEvents(newDataCard)
        container.appendChild(newDataCard);
        cardCount++
    } else {

        newDataCard.classList = "itemCard"
        newDataCard.appendChild(makeItem(data))
        cardCount++
        //registerMouseEvents(newDataCard)
        container.appendChild(newDataCard);
    
    }
   
    if(longKeys.length > 0){
        longKeys = [...new Set(longKeys)]
      
        longKeys.forEach(setLongValueClass)
    }

});