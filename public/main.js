
var container = document.getElementById('cardContainer');

var sessionName = ""

const markLongValue = function (element){
    element.classList = element.classList + " longValue"
} 
socket.on('console', function (data) {

    var longValue = false
    var longKey 


    var newDataCard = document.createElement('div')
    if (Array.isArray(data)) {
    for (let [key,value] of Object.entries(...data)){   
        console.log(key + " : " + value)
        if(value.length >= 14 || key.length >=14 ){
            console.log("Long value : " + key)
            longValue = true
            longKey = key
        }
    }


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

        if(longValue = true){
            markLongValue(newDataCard)
        }
        container.appendChild(newDataCard);
    } else {

        newDataCard.classList = "itemCard"
        newDataCard.appendChild(makeItem(data))
       
        if(longValue = true){
            markLongValue(newDataCard)
        }

        container.appendChild(newDataCard);
       
    }
    
    longKey = ""
    longValue = false

});