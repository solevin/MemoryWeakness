import functions = require("firebase-functions");
import admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

type User = {
  isOnline: boolean;
  lastSeen: number;
  roomID: string;
};

type Room = {
  members: Array<string>;
  names: Array<string>;
  points: Array<number>;
  HPs: Array<number>;
  standbyList: Array<boolean>;
  leaves: Array<string>;
  grayList: Array<string>;
  maxMembers: number;
  questionQuantity: number;
  values: Array<string>;
  openIds: Array<string>;
  visibleList: Array<boolean>;
  turn: string;
  isDisplay: boolean;
};

exports.onUserStatusChange = functions.database
    .ref("/{uid}/presence")
    .onUpdate(async (change: any, context: any) => {
    // Realtime Databaseに書き込まれたデータを取得
      const isOnline = change.after.val();

      // DocumentReference
      const ref = firestore.doc(`users/${context.params.uid}`);
      console.log(`status: ${isOnline}`);

      const doc = await ref.get();
      const data = doc.data() as User;
      try {
        if (data.roomID != "" && data.roomID != null) {
          const roomRef = firestore.doc(`room/${data.roomID}`);
          const room = (await roomRef.get()).data() as Room;
          const memberList = room.members;
          const nameList = room.names;
          const leaveList = room.leaves;
          const grayList = room.grayList;
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
            if (grayList.indexOf(memberList[leaveIndex]) < 0) {
              grayList.push(memberList[leaveIndex]);
            }
            if (memberList.length > leaveList.length) {
              roomRef.update({
                turn: turn,
                leaves: leaveList,
                grayList: grayList,
              });
            } else {
              roomRef.delete();
            }
          } else {
            roomRef.delete();
          }
        }
      } catch (e) {
        console.log(`エラー発生 ${e}`);
      }

      // Firestoreの値を更新
      return ref.set({
        isOnline: isOnline,
        lastSeen: Date.now(),
        roomID: "",
      });
    });
