export type DepthLevel = 100 | 200 | 300;

export type DepthTokenVariant = {
  surface: string;
  border: string;
  shadow: string;
};

export type DepthToken = {
  light: DepthTokenVariant;
  dark: DepthTokenVariant;
  className: string;
};

export const depthLevels: DepthLevel[] = [100, 200, 300];

export const depthTokens: Record<DepthLevel, DepthToken> = {
  100: {
    light: {
      surface: "var(--depth-100-surface)",
      border: "var(--depth-100-border)",
      shadow: "var(--depth-100-shadow)",
    },
    dark: {
      surface: "var(--depth-100-surface)",
      border: "var(--depth-100-border)",
      shadow: "var(--depth-100-shadow)",
    },
    className: "depth-100",
  },
  200: {
    light: {
      surface: "var(--depth-200-surface)",
      border: "var(--depth-200-border)",
      shadow: "var(--depth-200-shadow)",
    },
    dark: {
      surface: "var(--depth-200-surface)",
      border: "var(--depth-200-border)",
      shadow: "var(--depth-200-shadow)",
    },
    className: "depth-200",
  },
  300: {
    light: {
      surface: "var(--depth-300-surface)",
      border: "var(--depth-300-border)",
      shadow: "var(--depth-300-shadow)",
    },
    dark: {
      surface: "var(--depth-300-surface)",
      border: "var(--depth-300-border)",
      shadow: "var(--depth-300-shadow)",
    },
    className: "depth-300",
  },
};

export const getDepthClassName = (depth: DepthLevel): string => depthTokens[depth].className;
