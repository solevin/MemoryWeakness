"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const firestore = admin.firestore();
exports.onUserStatusChange = functions.database
    .ref("/{uid}/presence")
    .onUpdate(async (change, context) => {
    // Realtime Databaseに書き込まれたデータを取得
    const isOnline = change.after.val();
    // DocumentReference
    const ref = firestore.doc(`users/${context.params.uid}`);
    console.log(`status: ${isOnline}`);
    // Firestoreの値を更新
    return ref.set({
        isOnline: isOnline,
        lastSeen: Date.now(),
    });
});
//# sourceMappingURL=index.js.map