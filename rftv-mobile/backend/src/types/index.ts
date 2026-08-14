export interface Channel {
  id: string;
  name: string;
  category: "News" | "Series" | "Faith" | "Kids" | "Sports" | "All";
  description?: string;
  isLive: boolean;
  streamUrl?: string;
  thumbnailUrl?: string;
  viewerCount?: number;
  order?: number;
}

export interface Program {
  id: string;
  channelId: string;
  title: string;
  startTime: string; // ISO string
  endTime: string; // ISO string
  description?: string;
}

export interface RadioStatus {
  isLive: boolean;
  headline: string;
  message: string;
  launchLabel?: string;
  streamUrl?: string;
}

export interface DonationConfig {
  presetAmounts: number[];
  currency: string;
  paymentMethods: { id: string; name: string; sub: string; color: string; enabled: boolean }[];
}

export interface DonationRecord {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  paymentMethod: string;
  phoneNumber: string;
  status: "pending" | "completed" | "failed";
  createdAt: string;
}

export interface AppUser {
  uid: string;
  name: string;
  email?: string;
  phone?: string;
  isAdmin: boolean;
  createdAt: string;
}
