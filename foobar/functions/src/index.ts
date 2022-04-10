import functions = require("firebase-functions");
import admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

type User = {
  isOnline: boolean;
  lastSeen: number;
  roomID: string;
  name: string;
};

type Room = {
  members: Array<string>;
  names: Array<string>;
  maxMembers: number;
  questionQuantity: number;
  values: Array<string>;
  openIds: Array<string>;
  visibleList: Array<boolean>;
  turn: string;
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
          const nameList = room.members;
          if (memberList.length > 1) {
            const deleteIndex = memberList.indexOf(context.params.uid);
            let turn = room.turn;
            if (room.turn == context.params.uid) {
              const turnIndex = (deleteIndex + 1) % memberList.length;
              turn = memberList[turnIndex];
            }
            memberList.splice(deleteIndex, 1);
            nameList.splice(deleteIndex, 1);
            roomRef.update({
              members: memberList,
              name: nameList,
              turn: turn,
            });
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
        name: "",
      });
    });
