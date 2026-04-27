import type { TranscriptEntry } from "../types";

export const parseStdoutLine = (line: string, ts: string): TranscriptEntry[] => {
  if (!line) return [];
  const trimmed = line.replace(/\r?\n$/, "");
  if (trimmed.startsWith("[paperclip]")) {
    return [{ kind: "system", ts, text: trimmed }];
  }
  return [{ kind: "assistant", ts, text: trimmed, delta: true }];
};
