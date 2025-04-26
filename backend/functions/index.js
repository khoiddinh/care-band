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
        const { name, dob, ssn, allergies, history } = req.body;

        if (!name || !dob || !ssn) {
            return res.status(400).json({ error: "Missing required patient fields (name, dob, ssn)" });
        }

        const patientsRef = db.collection("patients");
        const existingQuery = await patientsRef
            .where("name", "==", name)
            .where("dob", "==", dob)
            .where("ssn", "==", ssn)
            .get();

        const today = new Date();
        const dateStr = today.toISOString().split('T')[0];
        const newHistoryEntry = `[${dateStr}] ${history}`;

        // 🔵 Normalize incoming allergies
        let newAllergiesList = [];
        if (typeof allergies === "string") {
            newAllergiesList = allergies.split(";").map(a => a.trim()).filter(a => a.length > 0);
        } else if (Array.isArray(allergies)) {
            newAllergiesList = allergies.map(a => a.trim()).filter(a => a.length > 0);
        }

        if (!existingQuery.empty) {
            const existingDoc = existingQuery.docs[0];
            const oldData = existingDoc.data();

            const newUUID = db.collection("patients").doc().id;

            // 🔵 Normalize old allergies
            let oldAllergiesList = [];
            if (typeof oldData.allergies === "string") {
                oldAllergiesList = oldData.allergies.split(";").map(a => a.trim()).filter(a => a.length > 0);
            } else if (Array.isArray(oldData.allergies)) {
                oldAllergiesList = oldData.allergies.map(a => a.trim()).filter(a => a.length > 0);
            }

            // 🔵 Merge allergies uniquely
            const mergedAllergiesSet = new Set([...oldAllergiesList, ...newAllergiesList]);
            const mergedAllergiesString = Array.from(mergedAllergiesSet).join("; ");

            const updatedHistory = oldData.history
                ? oldData.history + "\n" + newHistoryEntry
                : newHistoryEntry;

            await db.collection("patients").doc(newUUID).set({
                name,
                dob,
                ssn,
                allergies: mergedAllergiesString,
                history: updatedHistory,
                createdAt: today
            });

            res.status(200).json({ message: "Existing patient found. New version created.", newUUID });
        } else {
            const uuid = db.collection("patients").doc().id;

            await db.collection("patients").doc(uuid).set({
                name,
                dob,
                ssn,
                allergies: newAllergiesList.join("; "),
                history: newHistoryEntry,
                createdAt: today
            });

            res.status(201).json({ message: "New patient created.", uuid });
        }
    } catch (e) {
        console.error("Error in addOrUpdatePatient function:", e);
        res.status(500).json({ error: e.message });
    }
});

  

// No auth checking
exports.findPatient = onRequest(async (req, res) => {
    try {
        const { ssn, dob, uuid } = req.body;
        console.log("SSN received:", req.body.ssn);
        console.log("DOB received:", req.body.dob);
        console.log("UUID received:", req.body.uuid);
        console.log("Request body:", req.body);
        if (!ssn && !dob && !uuid) {
            return res.status(400).json({ error: "At least one of ssn, dob, or uuid must be provided" });
        }
        let doc;
  
        if (uuid) {
            doc = await db.collection("patients").doc(uuid).get();
      } else if (ssn && dob) {
        const querySnapshot = await db.collection("patients")
            .where("ssn", "==", ssn)
            .where("dob", "==", dob)
            .limit(1)
            .get();
        if (!querySnapshot.empty) {
            doc = querySnapshot.docs[0];
        }
      } else if (ssn) {
        const querySnapshot = await db.collection("patients")
            .where("ssn", "==", ssn)
            .limit(1)
            .get();
        if (!querySnapshot.empty) {
            doc = querySnapshot.docs[0];
        }
      } else if (dob) {
        const querySnapshot = await db.collection("patients")
            .where("dob", "==", dob)
            .limit(1)
            .get();
        if (!querySnapshot.empty) {
            doc = querySnapshot.docs[0];
        }
      } else {
            return res.status(400).json({ error: "At least one of ssn, dob, or uuid must be provided" });
      }
  
      if (!doc || !doc.exists) {
        return res.status(404).json({ error: "Patient not found" });
      }
  
      const data = doc.data();
      return res.status(200).json({
        uuid: doc.id,
        name: data.name,
        dob: data.dob,
        ssn: data.ssn,
        allergies: data.allergies,
        history: data.history || ""
      });
    } catch (e) {
      console.error("Error in findPatient function:", e);
      return res.status(500).json({ error: e.message });
    }
  });
  