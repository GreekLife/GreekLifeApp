var firebase = require('firebase');
var apn = require('apn');
 
//IOS connection
 var options = {
    token: {
    key: "AuthKey_3Z6SEF7GE5.p8",
    keyId: "3Z6SEF7GE5",
    teamId: "ASQJ3L7765"
    },
    production: false
};

var apnProvider = new apn.Provider(options);

//IOS notif function
function SendIOSNotification(token, message, sound, payload, badge){
var deviceToken = token; //phone notification id
var notification = new apn.Notification(); //prepare notif
notification.topic = 'com.GL.Greek-Life'; // Specify your iOS app's Bundle ID (accessible within the project editor)
notification.expiry = Math.floor(Date.now() / 1000) + 3600; // Set expiration to 1 hour from now (in case device is offline)
notification.badge = badge; //selected badge
notification.sound = sound; //sound is configurable
notification.alert = message +' \u270C'; //supports emoticon codes
notification.payload = {id: payload}; // Send any extra payload data with the notification which will be accessible to your app in didReceiveRemoteNotification
apnProvider.send(notification, deviceToken).then(function(result) {  //send actual notifcation
    // Check the result for any failed devices
    console.log(result);
});
}


//Firebase connection
var config = {
    apiKey: "AIzaSyDoOWPGkVYOx0dUZu8USGJGW00FAAyMwCk",
    authDomain: "greek-life-ios.firebaseapp.com",
    databaseURL: "https://greek-life-ios.firebaseio.com/"
};

var IOSIds = [];
var UserIds = [];

//get apple notification Ids
firebase.initializeApp(config);
var rootRef = firebase.database().ref("NotificationIds/IOS");
rootRef.on('value', function(snapshot) {
    snapshot.forEach(function(id) {
        var wId = id.val().Id;
        IOSIds.push(wId);
    })        
});

//Get User ids
var idRef = firebase.database().ref("Users");
idRef.on('value', function(snapshot) {
    var ids = Object.keys(snapshot.val());
        ids.forEach(function(id) {
            UserIds.push(id);
        });
});
//var masterIdRef = firebase.database().ref("Users/Master/UserId");
//masterIdRef.on('value', function(snapshot) {
//    UserIds.push(snapshot.val());
//    var index = UserIds.indexOf('Master');
//    UserIds.splice(index, 1);
//});

 //Custom master notification.
var FirstRoundMaster = true; //skip over the first read
var masterRef = firebase.database().ref("GeneralMessage/Master");
masterRef.on('value', function(snapshot) {
    console.log(IOSIds);
    if(!FirstRoundMaster) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, snapshot.val(), 'ping.aiff', 1, 3 );
        });
    }
    FirstRoundMaster = false;
});

//App notifications
var FirstRoundApp = true; //skip over the first read
var appRef = firebase.database().ref("GeneralMessage/Message");
appRef.on('value', function(snapshot) {
    if(!FirstRoundApp) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, snapshot.val(), 'ping.aiff', 2, 3 );
        });  
    }
    FirstRoundApp = false;
});

//Keep track of forum posts
var FirstRoundForum = true; //skip over the first read
var forumRef = firebase.database().ref("Forum/ForumIds");
forumRef.on('value', function(snapshot) {
    if(!FirstRoundForum) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, "A new Post has been added to the Forum!", 'ping.aiff', 1, 3 );
        });        
    }
    FirstRoundForum = false;
});

var FirstRoundPoll = true; //skip over the first read
var pollRef = firebase.database().ref("Polls/PollIds");
pollRef.on('value', function(snapshot) {
    if(!FirstRoundPoll) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, "A new Poll has been added!", 'ping.aiff', 3, 3 );
        });
    }
    FirstRoundPoll = false;
});

/*
Added calendar events
*/

//Check who hasnt answered a poll yet.

//Query PollOptions and iterate through to get ids.
setTimeout(function() {
    CheckForUnansweredPolls();
}, (21600000*2)); //check if polls have been answered every 12h 
function CheckForUnansweredPolls() {
    var hasntAnsweredAPoll = [];
    var pollOpRef = firebase.database().ref("PollOptions");
    pollOpRef.on('value', function(snapshot) {
        var options = Object.keys(snapshot.val());
         var index = options.indexOf('PollIds');
        options.splice(index, 1); //gotta eliminate pollids key

        options.forEach(function(id) {
            var pollOpIdRef = firebase.database().ref("PollOptions/"+id+"/\"0\"/Names");
            pollOpIdRef.on('value', function(snap) {
                var idHasVoted = Object.keys(snap.val());
                UserIds.forEach(function(exists) {
                    if (idHasVoted.indexOf(exists) < 0) {
                         var userIdRef = firebase.database().ref("Users/"+exists+"/NotificationId"); 
                         userIdRef.on('value', function(snap) { 
                             if(snap.val() != null) {
                                 if (hasntAnsweredAPoll.indexOf(snap.val()) < 0) {
                                    hasntAnsweredAPoll.push(snap.val());
                                 }
                             }
                         });
                    }
                });
            });
        });

        console.log("Hasnt Voted:");
        console.log(hasntAnsweredAPoll);
        hasntAnsweredAPoll.forEach(function(notif) {
                SendIOSNotification(notif, "You have an unanswered poll.", 'ping.aiff', 4, 3 ); 
         });
    });
}

































