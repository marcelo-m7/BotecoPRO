import type { Config } from "tailwindcss";
import plugin from "tailwindcss/plugin";
import tailwindcssAnimate from "tailwindcss-animate";

const depthPlugin = plugin(({ addUtilities }) => {
  const depthLevels = ["100", "200", "300"] as const;

  const depthUtilities = Object.fromEntries(
    depthLevels.map((level) => [
      `.depth-${level}`,
      {
        "--boteco-depth-surface": `var(--depth-${level}-surface)`,
        "--boteco-depth-border": `var(--depth-${level}-border)`,
        "--boteco-depth-shadow": `var(--depth-${level}-shadow)`,
        "background-color": "var(--boteco-depth-surface)",
        "border-color": "var(--boteco-depth-border)",
        "box-shadow": "var(--boteco-depth-shadow)",
      },
    ]),
  );

  addUtilities(depthUtilities, {
    variants: ["responsive", "hover", "focus", "active"],
  });

  addUtilities({
    ".depth-transition": {
      "transition-property": "transform, box-shadow, background-color, border-color",
      "transition-duration": "200ms",
      "transition-timing-function": "cubic-bezier(0.2, 0.8, 0.2, 1)",
    },
    "@media (prefers-reduced-motion: reduce)": {
      ".depth-transition": {
        "transition-duration": "1ms",
        "transition-timing-function": "linear",
      },
    },
  });
});

export default {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./app/**/*.{ts,tsx}",
    "./src/**/*.{ts,tsx}",
  ],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        sidebar: {
          DEFAULT: "hsl(var(--sidebar-background))",
          foreground: "hsl(var(--sidebar-foreground))",
          primary: "hsl(var(--sidebar-primary))",
          "primary-foreground": "hsl(var(--sidebar-primary-foreground))",
          accent: "hsl(var(--sidebar-accent))",
          "accent-foreground": "hsl(var(--sidebar-accent-foreground))",
          border: "hsl(var(--sidebar-border))",
          ring: "hsl(var(--sidebar-ring))",
        },
        boteco: {
          wine: {
            50: "hsl(var(--boteco-wine-50))",
            100: "hsl(var(--boteco-wine-100))",
            200: "hsl(var(--boteco-wine-200))",
            300: "hsl(var(--boteco-wine-300))",
            400: "hsl(var(--boteco-wine-400))",
            500: "hsl(var(--boteco-wine-500))",
            600: "hsl(var(--boteco-wine-600))",
            700: "hsl(var(--boteco-wine-700))",
            800: "hsl(var(--boteco-wine-800))",
            900: "hsl(var(--boteco-wine-900))",
            DEFAULT: "hsl(var(--boteco-wine-500))",
            foreground: "hsl(var(--boteco-wine-foreground))",
          },
          mustard: {
            50: "hsl(var(--boteco-mustard-50))",
            100: "hsl(var(--boteco-mustard-100))",
            200: "hsl(var(--boteco-mustard-200))",
            300: "hsl(var(--boteco-mustard-300))",
            400: "hsl(var(--boteco-mustard-400))",
            500: "hsl(var(--boteco-mustard-500))",
            600: "hsl(var(--boteco-mustard-600))",
            700: "hsl(var(--boteco-mustard-700))",
            800: "hsl(var(--boteco-mustard-800))",
            900: "hsl(var(--boteco-mustard-900))",
            DEFAULT: "hsl(var(--boteco-mustard-500))",
            foreground: "hsl(var(--boteco-mustard-foreground))",
          },
          beige: {
            50: "hsl(var(--boteco-beige-50))",
            100: "hsl(var(--boteco-beige-100))",
            200: "hsl(var(--boteco-beige-200))",
            300: "hsl(var(--boteco-beige-300))",
            400: "hsl(var(--boteco-beige-400))",
            500: "hsl(var(--boteco-beige-500))",
            600: "hsl(var(--boteco-beige-600))",
            700: "hsl(var(--boteco-beige-700))",
            800: "hsl(var(--boteco-beige-800))",
            900: "hsl(var(--boteco-beige-900))",
            DEFAULT: "hsl(var(--boteco-beige-400))",
            foreground: "hsl(var(--boteco-beige-foreground))",
          },
          brown: {
            50: "hsl(var(--boteco-brown-50))",
            100: "hsl(var(--boteco-brown-100))",
            200: "hsl(var(--boteco-brown-200))",
            300: "hsl(var(--boteco-brown-300))",
            400: "hsl(var(--boteco-brown-400))",
            500: "hsl(var(--boteco-brown-500))",
            600: "hsl(var(--boteco-brown-600))",
            700: "hsl(var(--boteco-brown-700))",
            800: "hsl(var(--boteco-brown-800))",
            900: "hsl(var(--boteco-brown-900))",
            DEFAULT: "hsl(var(--boteco-brown-500))",
            foreground: "hsl(var(--boteco-brown-foreground))",
          },
          neutral: {
            50: "hsl(var(--boteco-neutral-50))",
            100: "hsl(var(--boteco-neutral-100))",
            200: "hsl(var(--boteco-neutral-200))",
            300: "hsl(var(--boteco-neutral-300))",
            400: "hsl(var(--boteco-neutral-400))",
            500: "hsl(var(--boteco-neutral-500))",
            600: "hsl(var(--boteco-neutral-600))",
            700: "hsl(var(--boteco-neutral-700))",
            800: "hsl(var(--boteco-neutral-800))",
            900: "hsl(var(--boteco-neutral-900))",
            DEFAULT: "hsl(var(--boteco-neutral-500))",
            foreground: "hsl(var(--boteco-neutral-foreground))",
          },
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: {
            height: "0",
          },
          to: {
            height: "var(--radix-accordion-content-height)",
          },
        },
        "accordion-up": {
          from: {
            height: "var(--radix-accordion-content-height)",
          },
          to: {
            height: "0",
          },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [tailwindcssAnimate, depthPlugin],
} satisfies Config;

