/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

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

// No auth checking
exports.getPatientRecord = onRequest(async (req, res) => {
    try {
        const { uuid } = req.body;
        if (!uuid) {
            return res.status(400).json({ error: "Missing UUID" });
        }

        const doc = await db.collection("patients").doc(uuid).get();
        if (!doc.exists) {
            return res.status(404).json({ error: "Patient not found" });
        }

        const data = doc.data();

        res.status(200).json({
            uuid: doc.id, 
            name: data.name,
            dob: data.dob,
            ssn: data.ssn,
            allergies: data.allergies,
            history: data.history || ""
        });
    } catch (e) {
        console.error("Error fetching patient record:", e);
        res.status(500).json({ error: e.message });
    }
});


// No auth checking
exports.addOrUpdatePatient = onRequest(async (req, res) => {
    try {
        const { uuid, name, dob, ssn, allergies, history } = req.body;

        if (!name || !dob || !ssn) {
            return res.status(400).json({ error: "Missing required patient fields (name, dob, ssn)" });
        }

        const today = new Date();
        const dateStr = today.toISOString().split('T')[0];

        let newHistoryEntry = "";

        if (history && history.trim() !== "") {
            newHistoryEntry = `[${dateStr}] ${history.trim()}`;
        }

        // 🔵 Normalize allergies
        let newAllergiesList = [];
        if (typeof allergies === "string") {
            newAllergiesList = allergies.split(";").map(a => a.trim()).filter(a => a.length > 0);
        } else if (Array.isArray(allergies)) {
            newAllergiesList = allergies.map(a => a.trim()).filter(a => a.length > 0);
        }

        const patientsRef = db.collection("patients");

        if (uuid) {
            // ✅ If uuid is provided, update the patient directly
            const patientDoc = patientsRef.doc(uuid);
            const docSnapshot = await patientDoc.get();

            if (!docSnapshot.exists) {
                return res.status(404).json({ error: "Patient not found" });
            }

            const oldData = docSnapshot.data();

            // Merge allergies
            let oldAllergiesList = [];
            if (typeof oldData.allergies === "string") {
                oldAllergiesList = oldData.allergies.split(";").map(a => a.trim()).filter(a => a.length > 0);
            } else if (Array.isArray(oldData.allergies)) {
                oldAllergiesList = oldData.allergies.map(a => a.trim()).filter(a => a.length > 0);
            }

            const mergedAllergiesSet = new Set([...oldAllergiesList, ...newAllergiesList]);
            const mergedAllergiesString = Array.from(mergedAllergiesSet).join("; ");

            let updatedHistory = oldData.history || "";

            if (newHistoryEntry.length > 0) {
                updatedHistory = updatedHistory ? (updatedHistory + "\n" + newHistoryEntry) : newHistoryEntry;
            }

            await patientDoc.update({
                name,
                dob,
                ssn,
                allergies: mergedAllergiesString,
                history: updatedHistory,
                updatedAt: today
            });

            return res.status(200).json({ message: "Patient updated successfully." });
        } else {
            // ❗ No uuid provided → fallback to creating new patient
            const uuid = patientsRef.doc().id;

            await patientsRef.doc(uuid).set({
                name,
                dob,
                ssn,
                allergies: newAllergiesList.join("; "),
                history: newHistoryEntry,
                createdAt: today
            });

            return res.status(201).json({ message: "New patient created.", uuid });
        }
    } catch (e) {
        console.error("Error in addOrUpdatePatient function:", e);
        res.status(500).json({ error: e.message });
    }
});
