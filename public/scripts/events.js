//add days util
Date.prototype.addDays = function(days) {
    this.setDate(this.getDate() + parseInt(days));
    return this;
};

//checkfor theme cookie
function getUserTheme(){

if(document.cookie.length > 1){ 
 var themeString = document.cookie.substring(6,26)
 document.getElementById("theme").href= themeString;
}
}
//Theme button select handler + cookie setter
function onThemeSelection(element){
    var selection = element.id
    var styleSheetLink = "./css/"+selection+".css"
    document.getElementById("theme").href = styleSheetLink
    var currentDate = new Date()
    document.cookie = "theme="+styleSheetLink+"; expires="+currentDate.addDays(5)+";"
}

//get user session name
function setSessionName(ele){
    document.getElementById("sessionName").innerText = ele.value

    var answer = confirm("Once set, this value is tied to this session and cannot be changed. Are you sure you want to continue?")

    if(answer){
        sessionName = ele.value
        socket.sid = sessionName
        socket.emit('newSID',sessionName)
        

        document.getElementById("sessionInformText").style.display = "none";
        document.getElementById("sessionNameInput").style.display = "none";
        console.log("Session name set to :  "  + sessionName)
    }else{
        console.log("Session name not set");
    }

}

function updateSessionList(){
    socket.emit('requestSessionList',{Get:"Session List"})
};

socket.on('requestSessionListResponse',(sessionList)=>{
    var roomlist = document.getElementById('sessionList')
    sessionList.forEach(element => {
        var li = document.createElement('li')
        li.textContent = element
        roomlist.appendChild(li)
    });

})

socket.on('updateCount',(vitals)=>{
  document.getElementById('socketCount').textContent = vitals.socketCount
  conMetrics.ip = vitals.clientIP
  console.log(vitals);
})

socket.on('pong',(data)=>{
    conMetrics.latency = data
    ms.textContent = data+"ms"
    console.log(conMetrics)

})