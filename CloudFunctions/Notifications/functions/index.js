const functions = require('firebase-functions');
const admin = require('firebase-admin');
const schedule = require('node-schedule');

admin.initializeApp(functions.config().firebase);

exports.scheduleNotification = functions.database.ref('/users/{pn}/unopened/{mediaID}').onCreate(event => {
	const phoneNumber = event.params.pn;
	const mediaID = event.params.mediaID;

	console.log("Phone number: " + phoneNumber);
	console.log("Media ID: " + mediaID);

	const releaseDate = event.data.child("releaseDate").val() * 1000;
	const mediaType = event.data.child("mediaType").val();

	const notification = {
		notification: {
			title: "Pickskip Notifiaction",
			body: "You have a new " + mediaType + " that you can open at " + new Date(releaseDate) + "!",
			badge: "1",
			sound: "1"
		}
	};

	console.log("Notification: " + JSON.stringify(notification));

	if (releaseDate < Date.now()) {
		console.log("Skipping..");
		return;
	}

	console.log("Getting to scheduling");

	return new Promise(function(resolve, reject) {
		//schedule.scheduleJob(new Date(releaseDate), function() {
			admin.database().ref('/users/'+phoneNumber+'/profile/NotificationToken').once('value').then(allTokens => {
				if (allTokens.val()) {
					const token = allTokens.val();
					console.log(allTokens);
					console.log("Token Value: "+ token);
					return admin.messaging().sendToDevice(token, notification);
				}
				reject(Error("Not token val.."));
			}).then(function() {
				resolve();
			});
		//});

		console.log("Scheduled sending notification to phone number: " + phoneNumber + " at time: " + new Date(releaseDate));

	});

	
});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
