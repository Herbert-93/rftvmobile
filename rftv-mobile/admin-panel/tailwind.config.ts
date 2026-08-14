import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        navy: "#0A2E44",
        navy2: "#0B3852",
        ocean: "#0E5A82",
        sky: "#1FA6DB",
        cyan: "#6FE0FF",
        ember: "#E8481D",
        amber: "#FF8A3D",
        cream: "#FBF7F1",
        cream2: "#F3ECE1",
        ink: "#122633",
        slate: "#64707D",
        slateLight: "#93A0AC",
        line: "rgba(10,46,68,0.10)",
      },
      fontFamily: {
        sora: ["var(--font-sora)", "sans-serif"],
        inter: ["var(--font-inter)", "sans-serif"],
      },
    },
  },
  plugins: [],
};
export default config;
