const functions = require('firebase-functions');
const firebase = require('firebase')
const admin = require('firebase-admin');
const schedule = require('node-schedule');


admin.initializeApp({
  databaseURL: 'https://pickskip-12241.firebaseio.com/'

});
const ref = firebase.database().ref()

exports.updateAvailableMessages = functions.https.onRequest((req, res) => {
	const currentTime = new Date().getTime()

	ref.child('users').once('value', function(snapshot) {
		console.log(snapshot.val());
	})
	response.send('Notifying users of open messages')
	
});

