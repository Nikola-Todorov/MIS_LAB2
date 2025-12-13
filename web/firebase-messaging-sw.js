importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
apiKey: "AIzaSyB-giAOBriYsDUkxLcf0itDqO0GWL393F0",
      authDomain: "recipe-app-f7c7e.firebaseapp.com",
      projectId: "recipe-app-f7c7e",
      storageBucket: "recipe-app-f7c7e.firebasestorage.app",
      messagingSenderId: "1003942639352",
      appId: "1:1003942639352:web:0ac2d45fd082e9b5c52d0d",
      measurementId: "G-RZ8DKLZEQW"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background Message:', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});