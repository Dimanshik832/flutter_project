const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

async function sendToToken(token, payload) {
  if (!token) return;
  await messaging.send({
    token,
    android: { priority: "high" },
    apns: { headers: { "apns-priority": "10" } },
    ...payload,
  });
}

async function sendToUser(userId, payload) {
  if (!userId) return;

  const snap = await db.collection("users").doc(userId).get();
  if (!snap.exists) return;

  const user = snap.data();

  if (user.notificationSettings?.push === false) {
    return;
  }

  const token = user.fcmToken;
  if (!token) return;

  await sendToToken(token, payload);
}

function adminRoleQuery(snapQuery) {
  
  return snapQuery.where("role", "in", ["admin", "Admin", "ADMIN"]);
}






function isSentToFirmsTransition(before, after) {
  const beforeStatus = (before?.status || "").toLowerCase();
  const afterStatus = (after?.status || "").toLowerCase();

  const statusTriggered =
    beforeStatus !== afterStatus &&
    (afterStatus === "senttofirms" ||
      afterStatus === "sent to firms");

  const flagTriggered =
    Boolean(before?.sentToFirms) === false &&
    Boolean(after?.sentToFirms) === true;

  const timestampTriggered =
    !before?.sentToFirmsAt && Boolean(after?.sentToFirmsAt);

  return statusTriggered || flagTriggered || timestampTriggered;
}





exports.notifyAdminsOnReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const report = event.data?.data();
    if (!report) return;

    const admins = await adminRoleQuery(db.collection("users")).get();

    if (admins.empty) return;

    const tasks = [];

    admins.forEach((doc) => {
      tasks.push(
        sendToUser(doc.id, {
          notification: {
            title: "New report created",
            body: report.title ?? "A new maintenance report was created",
          },
          data: {
            type: "REPORT_CREATED",
            reportId: event.params.reportId,
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);





exports.notifyStudentOnReportStatusChanged = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;
    if (before.status === after.status) return;

    const userId = after.createdBy || after.userId;
    if (!userId) return;

    await sendToUser(userId, {
      notification: {
        title: "Report status updated",
        body: `New status: ${after.status}`,
      },
      data: {
        type: "REPORT_STATUS_CHANGED",
        reportId: event.params.reportId,
      },
    });
  }
);





exports.notifyFirmsOnReportSent = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;
    if (!isSentToFirmsTransition(before, after)) return;

    const category = after.category;
    if (!category) return;

    const firms = await db
      .collection("firms")
      .where("categories", "array-contains", category)
      .get();

    if (firms.empty) return;

    const tasks = [];

    firms.forEach((firmDoc) => {
      const firm = firmDoc.data();

      if (firm.ownerId) {
        tasks.push(
          sendToUser(firm.ownerId, {
            notification: {
              title: "New report available",
              body: after.title ?? `Category: ${category}`,
            },
            data: {
              type: "REPORT_SENT_TO_FIRMS",
              reportId: event.params.reportId,
              firmId: firmDoc.id,
              open: "detail",
            },
          })
        );
      }

      if (Array.isArray(firm.workerIds)) {
        firm.workerIds.forEach((workerId) => {
          tasks.push(
            sendToUser(workerId, {
              notification: {
                title: "New job available",
                body: after.title ?? `Category: ${category}`,
              },
              data: {
                type: "REPORT_SENT_TO_FIRMS",
                reportId: event.params.reportId,
                firmId: firmDoc.id,
              },
            })
          );
        });
      }
    });

    await Promise.all(tasks);
  }
);






exports.notifyAdminsOnFirmApplication = onDocumentCreated(
  "firmApplications/{applicationId}",
  async (event) => {
    const application = event.data?.data();
    if (!application) return;

    const admins = await adminRoleQuery(db.collection("users")).get();

    if (admins.empty) return;

    let reportTitle = "A report";
    let firmName = "A firm";

    
    if (application.reportId) {
      const reportSnap = await db
        .collection("reports")
        .doc(application.reportId)
        .get();

      if (reportSnap.exists) {
        reportTitle = reportSnap.data().title || reportTitle;
      }
    }

    
    if (application.firmId) {
      const firmSnap = await db
        .collection("firms")
        .doc(application.firmId)
        .get();

      if (firmSnap.exists) {
        firmName = firmSnap.data().name || firmName;
      }
    }

    const tasks = [];

    admins.forEach((doc) => {
      tasks.push(
        sendToUser(doc.id, {
          notification: {
            title: "New firm application",
            body: `${firmName} applied for "${reportTitle}"`,
          },
          data: {
            type: "FIRM_APPLIED_TO_REPORT",
            applicationId: event.params.applicationId,
            reportId: application.reportId || "",
            firmId: application.firmId || "",
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);





exports.notifyFirmOnSelected = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    
    
    const beforeSelected = before.selectedApplicationId || null;
    const afterSelected = after.selectedApplicationId || null;
    if (beforeSelected === afterSelected) return;
    if (!afterSelected) return;

    const appSnap = await db
      .collection("firmApplications")
      .doc(afterSelected)
      .get();
    if (!appSnap.exists) return;

    const app = appSnap.data();
    const firmId = app?.firmId || after.assignedFirmId;
    if (!firmId) return;

    const firmSnap = await db.collection("firms").doc(firmId).get();
    if (!firmSnap.exists) return;

    const firm = firmSnap.data();
    const tasks = [];

    
    if (firm.ownerId) {
      tasks.push(
        sendToUser(firm.ownerId, {
          notification: {
            title: "Your firm was selected",
            body: after.title
              ? `Your firm was selected for "${after.title}"`
              : "Your firm was selected for a report",
          },
          data: {
            type: "FIRM_SELECTED",
            reportId: event.params.reportId,
            firmId,
          },
        })
      );
    }



    await Promise.all(tasks);
  }
);






exports.notifyWorkersOnAssigned = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    

    const beforeWorkers = Array.isArray(before.assignedWorkerIds)
      ? before.assignedWorkerIds
      : [];

    const afterWorkers = Array.isArray(after.assignedWorkerIds)
      ? after.assignedWorkerIds
      : [];

    
    const newlyAssigned = afterWorkers.filter(
      (id) => !beforeWorkers.includes(id)
    );

    if (newlyAssigned.length === 0) return;

    const tasks = [];

    newlyAssigned.forEach((workerId) => {
      tasks.push(
        sendToUser(workerId, {
          notification: {
            title: "New job assigned",
            body: after.title
              ? `You were assigned to "${after.title}"`
              : "You were assigned to a new job",
          },
          data: {
            type: "WORKER_ASSIGNED",
            reportId: event.params.reportId,
            firmId: after.assignedFirmId || "",
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);







exports.notifyAdminsOnWorkCancelled = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    
    if (before.cancelledAt && after.cancelledAt) return;
    if (!after.cancelledAt) return;

    const adminsSnap = await adminRoleQuery(db.collection("users")).get();

    if (adminsSnap.empty) return;

    const tasks = [];

    adminsSnap.forEach((doc) => {
      tasks.push(
        sendToUser(doc.id, {
          notification: {
            title: "Work cancelled by firm",
            body: after.title
              ? `Cancelled: ${after.title}`
              : "A firm cancelled the work on a report",
          },
          data: {
            type: "WORK_CANCELLED",
            reportId: event.params.reportId,
            firmId: after.assignedFirmId || "",
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);







exports.notifyAdminsOnWorkCompleted = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    
    if (before.completedAt && after.completedAt) return;
    if (!after.completedAt) return;

    const studentId = after.createdBy || after.userId;

    const adminsSnap = await adminRoleQuery(db.collection("users")).get();

    const tasks = [];

    if (!adminsSnap.empty) {
      adminsSnap.forEach((doc) => {
        tasks.push(
          sendToUser(doc.id, {
            notification: {
              title: "Work completed",
              body: after.title
                ? `Completed: ${after.title}`
                : "A firm marked a job as completed",
            },
            data: {
              type: "WORK_COMPLETED",
              reportId: event.params.reportId,
              firmId: after.assignedFirmId || "",
            },
          })
        );
      });
    }

    if (studentId) {
      tasks.push(
        sendToUser(studentId, {
          notification: {
            title: "Work completed",
            body: after.title
              ? `Completed: ${after.title}`
              : "Work on your report was completed",
          },
          data: {
            type: "WORK_COMPLETED",
            reportId: event.params.reportId,
            firmId: after.assignedFirmId || "",
          },
        })
      );
    }

    await Promise.all(tasks);
  }
);






exports.notifyUsersOnAnnouncementCreated = onDocumentCreated(
  "announcements/{announcementId}",
  async (event) => {
    const announcement = event.data?.data();
    if (!announcement) return;

    const title = announcement.title || "New announcement";
    const text = (announcement.text || "").toString();

    const body =
      text.length > 120 ? text.substring(0, 117) + "..." : text;

    const level = announcement.type || "info"; 

    
    const roleVariants = [
      "user",
      "User",
      "usernau",
      "userNAU",
      "user_nau",
      "user nau",
    ];

    const usersSnap = await db
      .collection("users")
      .where("role", "in", roleVariants.slice(0, 10))
      .get();

    if (usersSnap.empty) return;

    const tasks = [];

    usersSnap.forEach((doc) => {
      const user = doc.data() || {};
      if (user.notificationSettings?.push === false) return;
      if (user.notificationSettings?.news === false) return;
      if (!user.fcmToken) return;

      tasks.push(
        sendToToken(user.fcmToken, {
          notification: {
            title,
            body,
          },
          data: {
            type: "ANNOUNCEMENT",
            level, 
            announcementId: event.params.announcementId,
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);






exports.notifyAdminsOnWhitelistApplication = onDocumentCreated(
  "whitelistApplications/{userId}",
  async (event) => {
    const application = event.data?.data();
    if (!application) return;

    const fullName = application.fullName || "Unknown user";
    const email = application.email || "No email";
    const album = application.album || "-";

    const adminsSnap = await adminRoleQuery(db.collection("users")).get();

    if (adminsSnap.empty) return;

    const tasks = [];

    adminsSnap.forEach((doc) => {
      tasks.push(
        sendToUser(doc.id, {
          notification: {
            title: "New whitelist request",
            body: `${fullName} (${album}) requested whitelist access`,
          },
          data: {
            type: "WHITELIST_REQUEST",
            userId: event.params.userId,
            email,
          },
        })
      );
    });

    await Promise.all(tasks);
  }
);






exports.notifyUserOnWhitelistApproved = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    
    if (before.applicationStatus === "approved") return;
    if (after.applicationStatus !== "approved") return;

    await sendToUser(event.params.userId, {
      notification: {
        title: "Whitelist approved",
        body: "Your account has been approved. Welcome!",
      },
      data: {
        type: "WHITELIST_APPROVED",
      },
    });
  }
);






exports.notifyUserOnWhitelistRejected = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    
    if (before.applicationStatus === "rejected") return;
    if (after.applicationStatus !== "rejected") return;

    await sendToUser(event.params.userId, {
      notification: {
        title: "Whitelist request rejected",
        body: "Unfortunately, your whitelist request was rejected.",
      },
      data: {
        type: "WHITELIST_REJECTED",
      },
    });
  }
);






exports.sendDebugPush = onDocumentCreated(
  "debugPushQueue/{docId}",
  async (event) => {
    const data = event.data?.data();
    if (!data?.userId) return;

    await sendToUser(data.userId, {
      notification: {
        title: data.title || "Debug",
        body: data.body || "Debug push",
      },
      data: { type: "DEBUG_PUSH" },
    });

    await event.data.ref.delete();
  }
);
