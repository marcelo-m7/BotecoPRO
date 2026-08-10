"use client";

import { useTheme } from "next-themes";

import { DepthLevel, DepthTokenVariant, depthTokens } from "./depth-tokens";

type ThemeVariant = "light" | "dark";

const resolveVariant = (theme?: string): ThemeVariant =>
  theme === "dark" ? "dark" : "light";

export const useDepthTokens = (
  depth: DepthLevel,
  themeOverride?: ThemeVariant,
): Record<keyof DepthTokenVariant, string> => {
  const { resolvedTheme } = useTheme();
  const variant = themeOverride ?? resolveVariant(resolvedTheme);

  return depthTokens[depth][variant];
};
