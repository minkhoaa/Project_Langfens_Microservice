import type { ProviderStreams } from "../types.ts";
import { lazyApi } from "./lazy.ts";

export const generationMessagesApi = (): ProviderStreams => lazyApi(() => import("./generation-messages.ts"));
