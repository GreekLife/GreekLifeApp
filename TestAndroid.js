var FCM = require('fcm-push');

var serverKey = 'AIzaSyBaIs2d7LS7xe6GQbxp1ltpzr5PmnsMM4w';
var fcm = new FCM(serverKey);

var message = {
    to: "fkVvQgdRVDg:APA91bHaYIhx7e7qZw0soFvc9DZCd8QHQtPBrqpDJxNKnyWqrFS3MkkIq5DuzhhYZFl14u0Qvv-1-fLT1FpiooruaX0pNvH9-Nprx9vovv3hoc437js7yn7zUJXV83uxKGc4v7z8tagf", // required fill with device token or topics
    collapse_key: 'your_collapse_key', 
    data: {
        your_custom_data_key: 'your_custom_data_value'
    },
    notification: {
        title: 'Title of your push notification',
        body: 'Body of your push notification'
    }
};

//callback style
fcm.send(message, function(err, response){
    if (err) {
        console.log("Something has gone wrong!");
    } else {
        console.log("Successfully sent with response: ", response);
    }
});

//promise style
fcm.send(message)
    .then(function(response){
        console.log("Successfully sent with response: ", response);
    })
    .catch(function(err){
        console.log("Something has gone wrong!");
        console.error(err);
    })
