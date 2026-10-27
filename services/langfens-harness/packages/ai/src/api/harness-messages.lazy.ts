import type { ProviderStreams } from "../types.ts";
import { lazyApi } from "./lazy.ts";

export const harnessMessagesApi = (): ProviderStreams => lazyApi(() => import("./harness-messages.ts"));
