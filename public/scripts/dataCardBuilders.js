

function setLongValueClass(item,index){
    document.getElementById(item).classList = "longValue"
}


function makeTable(data){

    var newTable = document.createElement('table')
    newTable.classList = 'table'
    var newTHead = document.createElement('thead')
    var thRow = document.createElement('tr')
    var newTbody = document.createElement('tbody')

    for(var k = 0;k < Object.keys(data[0]).length;k++){
        var th = document.createElement("th")
        th.textContent = Object.keys(data[0])[k]
        th.id = Object.keys(data[0])[k] + "_" + cardCount
        thRow.appendChild(th);
    }
    newTHead.appendChild(thRow)
    newTable.appendChild(newTHead)

    for(var i =0;i< data.length;i++){
     var newRow = document.createElement('tr')
        for(d = 0;d <Object.values(data[i]).length;d++){
            var value =  Object.values(data[i])[d]
            var header = Object.keys(data[i])[d] +"_"+ cardCount
            var td = document.createElement('td')
            td.onclick = function () {handleClick(this)}
            td.textContent = value
            if(value != null && value.length >= longValueLength ){
                longKeys.push(header)
                td.className = "longValue"
                newRow.className = "longValue"
                longValues = true
            }
            
            newRow.appendChild(td)
        }
        newRow.ondblclick = function () {handleDblClick(this)}
     newTbody.appendChild(newRow)
    }

    newTable.append(newTbody)
    return newTable

}



function makeItem(data) {
    
    var newTable = document.createElement('table')
    newTable.classList = 'itemTable'
    var newColGroup = document.createElement('colgroup')
    newColGroup.innerHTML = '<col class="itemHeader"> <col class="itemData">'
    newTable.append(newColGroup)

    dataLength = Object.keys(data).length
    
    for(var i = 0; i < dataLength;i++){
        var newRow = document.createElement('tr')
        var newTH = document.createElement('th')
        var newTD = document.createElement('td')
        newTH.textContent = Object.keys(data)[i]
        newRow.appendChild(newTH)
        newTD.onclick = function () {handleClick(this)}
        newTD.textContent = Object.values(data)[i]
        newRow.appendChild(newTD)
        newRow.ondblclick = function () {handleDblClick(this)}
    newTable.appendChild(newRow)
    }

    return newTable
}

function makeMetricLI(metrics){
var ol = document.getElementById("metricsList")
var li = document.createElement("li")
var sp = document.createElement("span")
sp.id = metrics.ident
sp.textContent = metrics.latency+"ms"
li.textContent = metrics.ip + " : "
li.appendChild(sp)
li.id = metrics.SID
ol.appendChild(li)
}