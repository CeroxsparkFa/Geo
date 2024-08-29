/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
import * as admin from 'firebase-admin';
admin.initializeApp();

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const fcm = admin.messaging();


let baseUrl = "http://localhost/proyectos/GeoBlastWeb/public/"
let states = {}
setInterval(async () => {
    await fetch(baseUrl + "usuarios/get", {
        method: "GET",
        headers: {
            'Content-Type': 'application/json'
        },
    })
    .then(response => response.json())
    .then(data => {
        data.forEach(element => {
            if (states.hasOwnProperty(element.id) && states[element.id] == 0 && element.user_estado == 1) {
                let tokens = element.tokens.split(" ")
                tokens.forEach((token) => {
                    const message = {
                        notification: {
                            title: 'Tienes un pedido disponible!',
                            body: 'Accede al formulario de la app para reclamarlo'
                        },
                        token: token
                    };
                    fcm.send(message)
                })
            
            }
            states[element.id] = element.user_estado
        });
    });

},
180000)
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
