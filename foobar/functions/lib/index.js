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
    const doc = await ref.get();
    const data = doc.data();
    try {
        if (data.roomID != "" && data.roomID != null) {
            const roomRef = firestore.doc(`room/${data.roomID}`);
            const room = (await roomRef.get()).data();
            const memberList = room.members;
            const nameList = room.names;
            const leaveList = room.leaves;
            if (memberList.length > leaveList.length) {
                const leaveIndex = memberList.indexOf(context.params.uid);
                leaveList.push(memberList[leaveIndex]);
                let turn = room.turn;
                if (turn == nameList[leaveIndex]) {
                    let turnIndex = (leaveIndex + 1) % memberList.length;
                    let turnId = memberList[nameList.indexOf(turn)];
                    turn = nameList[turnIndex];
                    console.log("in");
                    console.log(`${leaveList}`);
                    while (leaveList.indexOf(turnId) > 0) {
                        console.log("while");
                        turnIndex = (turnIndex + 1) % memberList.length;
                        turn = nameList[turnIndex];
                        turnId = memberList[nameList.indexOf(turn)];
                    }
                }
                if (memberList.length > leaveList.length) {
                    roomRef.update({
                        turn: turn,
                        leaves: leaveList,
                    });
                }
                else {
                    roomRef.delete();
                }
            }
            else {
                roomRef.delete();
            }
        }
    }
    catch (e) {
        console.log(`エラー発生 ${e}`);
    }
    // Firestoreの値を更新
    return ref.set({
        isOnline: isOnline,
        lastSeen: Date.now(),
        roomID: "",
    });
});
//# sourceMappingURL=index.js.map