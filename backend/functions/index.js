/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.getPatientRecord = onRequest(async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader?.startsWith("Bearer ")) {
            return res.status(401).json({ error: "Missing or invalid auth header" });
        }

        const idToken = authHeader.split("Bearer ")[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const hospitalId = decodedToken.hospital_id;

        if (!hospitalId) return res.status(403).json({ error: "Missing hospital_id" });

        const { uuid } = req.body;
        if (!uuid) return res.status(400).json({ error: "Missing UUID" });

        const doc = await db.collection("patients").doc(uuid).get();
        if (!doc.exists) return res.status(404).json({ error: "Patient not found" });

        const data = doc.data();
        if (!data.assignedHospitals.includes(hospitalId)) {
            return res.status(403).json({ error: "Unauthorized hospital" });
        }

        res.status(200).json({
            name: data.name,
            dob: data.dob,
            allergies: data.allergies,
            history: data.history || ""
        });
    } catch (e) {
        console.error("Error:", e);
        res.status(500).json({ error: e.message });
    }
});
