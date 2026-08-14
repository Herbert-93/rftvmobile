import { db } from "../config/firebase";
import { Channel, Program, RadioStatus, DonationConfig, DonationRecord } from "../types";

const channelsCol = db.collection("channels");
const programsCol = db.collection("programs");
const usersCol = db.collection("users");
const donationsCol = db.collection("donations");
const settingsCol = db.collection("settings"); // singleton docs: "radio", "donationConfig"

export const ChannelsService = {
  async list(): Promise<Channel[]> {
    const snap = await channelsCol.orderBy("order", "asc").get();
    return snap.docs.map((d) => ({ id: d.id, ...(d.data() as any) }));
  },
  async get(id: string): Promise<Channel | null> {
    const doc = await channelsCol.doc(id).get();
    return doc.exists ? ({ id: doc.id, ...(doc.data() as any) } as Channel) : null;
  },
  async create(data: Omit<Channel, "id">): Promise<Channel> {
    const ref = await channelsCol.add(data);
    return { id: ref.id, ...data };
  },
  async update(id: string, data: Partial<Channel>): Promise<void> {
    await channelsCol.doc(id).update(data as any);
  },
  async remove(id: string): Promise<void> {
    await channelsCol.doc(id).delete();
  },
};

export const ProgramsService = {
  async list(channelId?: string): Promise<Program[]> {
    let q: FirebaseFirestore.Query = programsCol.orderBy("startTime", "asc");
    if (channelId) q = programsCol.where("channelId", "==", channelId).orderBy("startTime", "asc");
    const snap = await q.get();
    return snap.docs.map((d) => ({ id: d.id, ...(d.data() as any) }));
  },
  async create(data: Omit<Program, "id">): Promise<Program> {
    const ref = await programsCol.add(data);
    return { id: ref.id, ...data };
  },
  async update(id: string, data: Partial<Program>): Promise<void> {
    await programsCol.doc(id).update(data as any);
  },
  async remove(id: string): Promise<void> {
    await programsCol.doc(id).delete();
  },
};

export const RadioService = {
  async get(): Promise<RadioStatus> {
    const doc = await settingsCol.doc("radio").get();
    if (!doc.exists) {
      return {
        isLive: false,
        headline: "RF Radio is coming soon",
        message:
          "Music, talk shows and family programming, streaming live to your phone. We're putting the final touches on it.",
        launchLabel: "Launching soon",
      };
    }
    return doc.data() as RadioStatus;
  },
  async update(data: Partial<RadioStatus>): Promise<void> {
    await settingsCol.doc("radio").set(data, { merge: true });
  },
};

export const DonationConfigService = {
  async get(): Promise<DonationConfig> {
    const doc = await settingsCol.doc("donationConfig").get();
    if (!doc.exists) {
      return {
        presetAmounts: [5000, 10000, 20000, 50000, 100000],
        currency: "UGX",
        paymentMethods: [
          { id: "mtn", name: "MTN Mobile Money", sub: "Pay with your MTN MoMo wallet", color: "#FFC700", enabled: true },
          { id: "airtel", name: "Airtel Money", sub: "Pay with your Airtel Money wallet", color: "#E8181A", enabled: true },
        ],
      };
    }
    return doc.data() as DonationConfig;
  },
  async update(data: Partial<DonationConfig>): Promise<void> {
    await settingsCol.doc("donationConfig").set(data, { merge: true });
  },
};

export const DonationsService = {
  async create(data: Omit<DonationRecord, "id">): Promise<DonationRecord> {
    const ref = await donationsCol.add(data);
    return { id: ref.id, ...data };
  },
  async listForUser(userId: string): Promise<DonationRecord[]> {
    const snap = await donationsCol.where("userId", "==", userId).orderBy("createdAt", "desc").get();
    return snap.docs.map((d) => ({ id: d.id, ...(d.data() as any) }));
  },
  async listAll(): Promise<DonationRecord[]> {
    const snap = await donationsCol.orderBy("createdAt", "desc").limit(200).get();
    return snap.docs.map((d) => ({ id: d.id, ...(d.data() as any) }));
  },
};

export const UsersService = {
  async get(uid: string) {
    const doc = await usersCol.doc(uid).get();
    return doc.exists ? { uid: doc.id, ...(doc.data() as any) } : null;
  },
  async list() {
    const snap = await usersCol.orderBy("createdAt", "desc").limit(200).get();
    return snap.docs.map((d) => ({ uid: d.id, ...(d.data() as any) }));
  },
};
