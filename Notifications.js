var FCM = require('fcm-push');
var firebase = require('firebase');
var apn = require('apn');

//Android connection
var androidServerKey = 'AAAAnM9NExs:APA91bGvq70XEEDVAKBkp3MA99D88pISL3OITfDh6Us9_rjLla2eNW589iKGORHs8EEZn_IFq4QFJrBFqUvs4vHv9A8ugZsjvqGSrfdrQAc0v1Kb_hmY19AR8VqXxjD39kDbXcFSfZ-a';
var fcm = new FCM(androidServerKey);

function SendAndroidNotification(token, title, body){
    var message = {
        to: token, // required fill with device token or topics
        notification: {
            title: title +' \u270C',
            body: body
        }
    };
    var subToken = token.substring(0, 6);
    fcm.send(message)
        .then(function(response){
            console.log("Succesfully sent message to ", subToken);
        })
        .catch(function(error) {
            console.log("Something has gone wrong sending to ", subToken);
            console.error(err);
        })
}

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

    var subToken = token.substring(0, 6);
    console.log("Succesfully sent message to ", subToken);
    }).catch( function (error) {
            console.log("Faled to send message to ", subToken);
    })
}


//Firebase connection
var config = {
    apiKey: "AIzaSyDoOWPGkVYOx0dUZu8USGJGW00FAAyMwCk",
    authDomain: "greek-life-ios.firebaseapp.com",
    databaseURL: "https://greek-life-ios.firebaseio.com/"
};

var AndroidIds = [];
var IOSIds = [];
var UserIds = [];
var MasterId = "";
var MasterNotificationID = "";
var MasterNotificationType = "";
var NewsArray = [];
var IdAndNotification = [];

//get apple notification Ids
firebase.initializeApp(config);

var iosRef = firebase.database().ref("GammaLambda/NotificationIds/IOS");
iosRef.on('value', snapshot => {
    snapshot.forEach(function(id) {
        var wId = id.val().Id;
        IOSIds.push(wId);
        if(snapshot.child("Username") == "Master") {
            MasterNotificationID = id.val().Id;
            MasterNotificationType = "IOS";
        }
    }) 
    console.log("IOS");
    console.log(IOSIds);       
});

//get Android notification Ids
var androidRef = firebase.database().ref("GammaLambda/NotificationIds/Android");
androidRef.on('value', snapshot => {
    snapshot.forEach(function(id) {
        var wId = id.val().Id;
        AndroidIds.push(wId);
        if(snapshot.child("Username") == "Master") {
            MasterNotificationID = id.val().Id;
            MasterNotificationType = "Android";
        }
    })      
    console.log("Android");
    console.log(AndroidIds);
});

//Get User ids
//notif for new user
var FirstRoundNewUser = true;
var idRef = firebase.database().ref("GammaLambda/Users");
idRef.on('value', snapshot => {


 snapshot.forEach(snapshot => {
    var idStored = {
        NotificationId: snapshot.child("NotificationId").val(),
        Id: snapshot.child("UserID").val()
    }; 
        IdAndNotification.push(idStored);

    if(snapshot.child("Position").val() == "Master") {
            MasterId = snapshot.child("UserID").val();
            MasterNotificationID = snapshot.child("NotificationId");
            console.log("MasterID: " + MasterId);
        }                                                               
        });                        
    var ids = Object.keys(snapshot.val());
        ids.forEach(id =>{
            if(!FirstRoundNewUser) {
                if(UserIds.indexOf(id) < 0) {
                    //user doesnt already exist -> new user
                    if(MasterNotificationType == "IOS") {
                        SendIOSNotification(MasterNotificationID, "You have a new user to verify!", 'ping.aiff', 1, 3 );
                    }
                    if(MasterNotificationType == "Android") {
                        SendAndroidNotification(MasterNotificationID, "You have a new user to verify","");
                     }
                    UserIds.push(id);
                }
            }
            else {
            UserIds.push(id);
            }
        });
    console.log("User Ids");
    console.log(UserIds);
    FirstRoundNewUser = false;
});


//New news on home page
var FirstRoundNews = true;
var newsRef = firebase.database().ref("GammaLambda/News");
newsRef.on('value', snapshot => {
    snapshot.forEach(snapshot => {
        if(FirstRoundNews) {
             NewsArray.push(snapshot.key);
            }
        else {
            if(NewsArray.indexOf(snapshot.key) < 0) {
                //news is new
                NewsArray.push(snapshot.key);
                IOSIds.forEach(id => {
                    SendIOSNotification(id, "There is a new post on the home page!", 'ping.aiff', 1, 3 );
                });
                AndroidIds.forEach(id => {
                    SendAndroidNotification(id, "There is a new post on the home page!" ,"");
                });
            }
        }
    });
    FirstRoundNews = false;

});

 //Custom master notification.
var FirstRoundMaster = true; //skip over the first read
var masterRef = firebase.database().ref("GammaLambda/GeneralMessage/Master");
masterRef.on('value', snapshot => {
    if(!FirstRoundMaster) {
        if(snapshot.val() != "") {
        IOSIds.forEach(id => {
            SendIOSNotification(id, snapshot.val(), 'ping.aiff', 1, 3 );
        });
        AndroidIds.forEach(id => {
            SendAndroidNotification(id, snapshot.val(),"");
        });
     }
    }
    FirstRoundMaster = false;
});

//App notifications
var FirstRoundApp = true; //skip over the first read
var appRef = firebase.database().ref("GammaLambda/GeneralMessage/Message");
appRef.on('value', snapshot => {
    if(!FirstRoundApp) {
        IOSIds.forEach(id => {
            SendIOSNotification(id, snapshot.val(), 'ping.aiff', 2, 3 );
        });  
        AndroidIds.forEach(id => {
            SendAndroidNotification(id, snapshot.val(),"");
        });
    }
    FirstRoundApp = false;
});


//Keep track of forum posts
var FirstRoundForum = true; //skip over the first read
var forumRef = firebase.database().ref("GammaLambda/Forum/ForumIds");
forumRef.on('value', function(snapshot) {
    if(!FirstRoundForum) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, "A new Post has been added to the Forum!", 'ping.aiff', 1, 3 );
        }); 
        AndroidIds.forEach(function(id) {
            SendAndroidNotification(id, "A new Post has been added to the Forum!","");
        });       
    }
    FirstRoundForum = false;
});

//Keep track of polls
var FirstRoundPoll = true; //skip over the first read
var pollRef = firebase.database().ref("GammaLambda/Polls/PollIds");
pollRef.on('value', function(snapshot) {
    if(!FirstRoundPoll) {
        IOSIds.forEach(function(id) {
            SendIOSNotification(id, "A new Poll has been added!", 'ping.aiff', 3, 3 );
        });
        AndroidIds.forEach(function(id) {
            SendAndroidNotification(id, "A new Poll has been added!","");
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
    var pollOpRef = firebase.database().ref("GammaLambda/PollOptions");
    pollOpRef.once('value', snapshot => {
        var arrayOfVoters = [];
        snapshot.forEach(snapshot => {
            var ids = snapshot.child("\"0\"").child("Names");
                ids.forEach(id => {
                    arrayOfVoters.push(id.key);
                });
                IdAndNotification.forEach(idStored => {
                    if(arrayOfVoters.indexOf(idStored.Id) < 0) {
                        if(IOSIds.indexOf(idStored.NotificationId) == 0) {
                           SendIOSNotification(idStored.NotificationId, "There are existing polls you haven't answered", 'ping.aiff', 3, 3 );
                        }
                         if(AndroidIds.indexOf(idStored.NotificationId) == 0) {
                           SendAndroidNotification(idStored.NotificationId, "There are existing polls you haven't answered","");
                        }
                    }
                })
            });

       });

 }

//Let master know a user needs to be revalidated


//IM updates

































