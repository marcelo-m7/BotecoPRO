"use client";

import * as React from "react";
import { ArrowRight, Sparkles, Star } from "lucide-react";
import {
  motion,
  useReducedMotion,
  useScroll,
  useSpring,
  useTransform,
} from "framer-motion";
import { useTranslation } from "react-i18next";
import { Link, useParams } from "react-router-dom";

import { DepthSpotlight, DepthStack } from "@/components/design";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

type HighlightSource = {
  title: string;
  description: string;
};

type Highlight = HighlightSource & {
  tone: "feature" | "workflow";
};

const toneConfig: Record<Highlight["tone"], { icon: React.ReactNode; accent: string }> = {
  feature: {
    icon: <Sparkles className="h-4 w-4" aria-hidden />, 
    accent:
      "from-boteco-mustard-400/70 to-boteco-mustard-200/30 dark:from-boteco-mustard-500/30 dark:to-boteco-mustard-400/10",
  },
  workflow: {
    icon: <Star className="h-4 w-4" aria-hidden />, 
    accent:
      "from-boteco-wine-500/70 to-boteco-wine-400/20 dark:from-boteco-wine-500/40 dark:to-boteco-wine-400/10",
  },
};

const HeroSection: React.FC = () => {
  const { t } = useTranslation("home");
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || "pt";
  const getLocalizedPath = React.useCallback((path: string) => `/${currentLocale}${path}` as const, [currentLocale]);

  const heroHighlights = React.useMemo<Highlight[]>(() => {
    const translatedFeatures = (t("features", { returnObjects: true }) as HighlightSource[] | undefined) ?? [];
    const translatedSteps = (t("howItWorks.steps", { returnObjects: true }) as HighlightSource[] | undefined) ?? [];

    const selectedFeatures = translatedFeatures.slice(0, 3).map((feature) => ({
      ...feature,
      tone: "feature" as const,
    }));

    const selectedSteps = translatedSteps.slice(0, 2).map((step) => ({
      ...step,
      tone: "workflow" as const,
    }));

    return [...selectedFeatures, ...selectedSteps];
  }, [t]);

  const containerRef = React.useRef<HTMLElement | null>(null);
  const shouldReduceMotion = useReducedMotion();
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  const springConfig = React.useMemo(() => ({ stiffness: 140, damping: 28, mass: 1.1 }), []);
  const smoothProgress = useSpring(scrollYProgress, springConfig);
  const parallax = useTransform(
    smoothProgress,
    [0, 1],
    shouldReduceMotion ? [0, 0] : ["-12%", "12%"],
  );

  return (
    <section
      ref={containerRef}
      className="relative w-full overflow-hidden bg-[radial-gradient(circle_at_top,_hsla(var(--boteco-wine-500)/0.16),_transparent_60%)] py-20 md:py-32"
    >
      <div className="pointer-events-none absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-boteco-wine-500/20 to-transparent dark:from-boteco-wine-700/30" aria-hidden />
      <div className="container mx-auto grid gap-12 px-4 lg:grid-cols-[minmax(0,1fr)_minmax(0,520px)] lg:items-center">
        <div className="relative space-y-8 text-left">
          <DepthSpotlight
            depth={200}
            spotlightRadius="420px"
            spotlightOpacity={0.32}
            className="max-w-xl overflow-hidden bg-gradient-to-br from-boteco-beige-50 to-boteco-beige-200/80 p-10 text-boteco-brown shadow-lg dark:from-boteco-brown-900 dark:to-boteco-brown-800/70"
          >
            <div className="space-y-6">
              <div className="inline-flex items-center rounded-full border border-boteco-wine-200/50 bg-boteco-wine-50/60 px-4 py-1 text-sm font-medium text-boteco-wine-700 dark:border-boteco-wine-400/30 dark:bg-boteco-wine-900/40 dark:text-boteco-wine-100">
                {t("hero.badge")}
              </div>
              <h1 className="text-4xl font-semibold leading-tight tracking-tight text-boteco-brown-900 sm:text-5xl dark:text-boteco-beige-50">
                {t("hero.title")}
              </h1>
              <p className="max-w-2xl text-lg text-boteco-brown-700 dark:text-boteco-beige-200/90">
                {t("hero.subtitle")}
              </p>
              <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
                <Link to={getLocalizedPath("/contato")}>
                  <Button
                    size="lg"
                    className="group relative flex w-full items-center justify-center gap-2 overflow-hidden bg-boteco-wine-500 text-boteco-wine-foreground transition hover:bg-boteco-wine-500/90 focus-visible:ring-boteco-mustard-400 sm:w-auto"
                  >
                    <span className="relative z-10">{t("hero.cta")}</span>
                    <ArrowRight className="relative z-10 h-5 w-5 transition-transform group-hover:translate-x-0.5" aria-hidden />
                    <span
                      aria-hidden
                      className="absolute inset-0 bg-[radial-gradient(circle_at_top,_hsla(var(--boteco-mustard-400)/0.35),_transparent_70%)] opacity-0 transition-opacity group-hover:opacity-100"
                    />
                  </Button>
                </Link>
                <a
                  className="w-full sm:w-auto"
                  href="https://app.boteco.pt"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <Button
                    size="lg"
                    variant="outline"
                    className="w-full border-boteco-brown-200 bg-boteco-beige-50 text-boteco-brown-800 transition hover:bg-boteco-beige-100 dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60 dark:text-boteco-beige-100"
                  >
                    {t("hero.demoButton")}
                  </Button>
                </a>
              </div>
            </div>
          </DepthSpotlight>
        </div>

        <div className="relative flex justify-center lg:justify-end">
          <motion.ul
            style={{ y: parallax }}
            className="grid w-full max-w-xl grid-cols-1 gap-5 sm:grid-cols-2"
          >
            {heroHighlights.map((highlight, index) => {
              const tone = toneConfig[highlight.tone];

              return (
                <li key={`${highlight.title}-${index}`} className={cn(index === 0 && "sm:col-span-2")}> 
                  <DepthStack
                    depth={index % 2 === 0 ? 200 : 300}
                    layerDepth={100}
                    layers={index % 2 === 0 ? 2 : 3}
                    layerOffset={5}
                    className="h-full overflow-hidden rounded-3xl bg-boteco-beige-100/70 dark:bg-boteco-brown-800/80"
                  >
                    <div className={cn("relative flex h-full flex-col gap-3 rounded-3xl p-6", "bg-gradient-to-br", tone.accent)}>
                      <div className="flex items-center gap-2 text-sm font-semibold text-boteco-brown-700 dark:text-boteco-beige-200">
                        <span className="flex h-8 w-8 items-center justify-center rounded-full border border-white/40 bg-white/60 text-boteco-brown-700 shadow-sm backdrop-blur-sm dark:border-boteco-brown-600/50 dark:bg-boteco-brown-700/60 dark:text-boteco-beige-100">
                          {tone.icon}
                        </span>
                        <span>{highlight.title}</span>
                      </div>
                      <p className="text-sm leading-relaxed text-boteco-brown-800/90 dark:text-boteco-beige-200/80">
                        {highlight.description}
                      </p>
                    </div>
                  </DepthStack>
                </li>
              );
            })}
          </motion.ul>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;