
function makeTable(data){

    var newTable = document.createElement('table')
    newTable.classList = 'table'
    var newTHead = document.createElement('thead')
    var thRow = document.createElement('tr')
    var newTbody = document.createElement('tbody')

    for(var k = 0;k < Object.keys(data[0]).length;k++){
        var th = document.createElement("th")
        th.textContent =Object.keys(data[0])[k];
        thRow.appendChild(th);
    }
    newTHead.appendChild(thRow)
    newTable.appendChild(newTHead)

    for(var i =0;i< data.length;i++){
     var newRow = document.createElement('tr')
        
        for(d = 0;d <Object.values(data[i]).length;d++){
            var td = document.createElement('td')
            td.textContent = Object.values(data[i])[d]
            newRow.appendChild(td)
        }
     newTbody.appendChild(newRow)
    }

    newTable.append(newTbody)

    return newTable
}

function makeItem(data) {
    var newTable = document.createElement('table')
    newTable.classList = 'itemTable'
    var newColGroup =document.createElement('colgroup')
    newColGroup.innerHTML = '<col class="itemHeader"> <col class="itemData">'
    newTable.append(newColGroup)

    dataLength = Object.keys(data).length

    for(var i = 0; i < dataLength;i++){
        var newRow = document.createElement('tr')
        var newTH = document.createElement('th')
        var newTD = document.createElement('td')
        newTH.textContent = Object.keys(data)[i]
        newRow.appendChild(newTH)
        newTD.textContent = Object.values(data)[i]
        newRow.appendChild(newTD)

    newTable.appendChild(newRow)
    }
    return newTable
}