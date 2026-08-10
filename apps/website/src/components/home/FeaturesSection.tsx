"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { useTranslation } from "react-i18next";

import { DepthSpotlight, DepthStack } from "@/components/design";
import { cn } from "@/lib/utils";

type Feature = { title: string; description: string };

type BentoCard = Feature & {
  layout: string;
  variant: "primary" | "secondary";
};

const FeaturesSection: React.FC = () => {
  const { t } = useTranslation("home");
  const shouldReduceMotion = useReducedMotion();

  const cards = React.useMemo<BentoCard[]>(() => {
    const translatedFeatures = (t("features", { returnObjects: true }) as Feature[] | undefined) ?? [];
    const baseCards = translatedFeatures.map<BentoCard>((feature) => ({
      ...feature,
      layout: "",
      variant: "secondary",
    }));

    return [
      {
        title: t("hero.title"),
        description: t("plans.description"),
        layout: "sm:col-span-2 md:col-span-2",
        variant: "primary",
      },
      ...baseCards,
    ];
  }, [t]);

  return (
    <section className="relative w-full overflow-hidden bg-boteco-beige-50/70 py-20 dark:bg-boteco-brown-950/80">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_center,_hsla(var(--boteco-mustard-300)/0.18),_transparent_55%)] dark:bg-[radial-gradient(circle_at_center,_hsla(var(--boteco-wine-500)/0.22),_transparent_60%)]" aria-hidden />
      <div className="container relative mx-auto flex flex-col gap-12 px-4">
        <div className="mx-auto max-w-3xl text-center">
          <motion.h2
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="text-3xl font-semibold tracking-tight text-boteco-brown-900 md:text-4xl dark:text-boteco-beige-50"
          >
            {t("featuresTitle", { defaultValue: "Nossas Funcionalidades" })}
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 12 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut", delay: 0.1 }}
            className="mt-4 text-lg text-boteco-brown-700 dark:text-boteco-beige-200/90"
          >
            {t("hero.subtitle")}
          </motion.p>
        </div>

        <div className="grid gap-6 sm:grid-cols-2 md:grid-cols-3">
          {cards.map((card, index) => {
            const isPrimary = card.variant === "primary";

            return (
              <motion.div
                key={`${card.title}-${index}`}
                initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 18 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, amount: 0.2 }}
                transition={{ duration: 0.5, ease: "easeOut", delay: index * 0.05 }}
                className={cn("h-full", card.layout)}
              >
                {isPrimary ? (
                  <DepthSpotlight
                    depth={300}
                    spotlightRadius="480px"
                    spotlightOpacity={0.28}
                    className="h-full rounded-3xl bg-gradient-to-br from-boteco-wine-500/90 via-boteco-wine-500/60 to-boteco-mustard-300/40 p-[1px]"
                  >
                    <div className="flex h-full flex-col justify-between rounded-3xl bg-boteco-beige-50/90 p-8 text-left dark:bg-boteco-brown-900/60">
                      <div className="space-y-4">
                        <span className="inline-flex items-center rounded-full bg-boteco-wine-500/10 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-boteco-wine-700 dark:text-boteco-mustard-300">
                          {t("plans.title")}
                        </span>
                        <h3 className="text-2xl font-semibold text-boteco-brown-900 dark:text-boteco-beige-50">{card.title}</h3>
                        <p className="text-base leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/80">{card.description}</p>
                      </div>
                    </div>
                  </DepthSpotlight>
                ) : (
                  <DepthStack
                    depth={index % 2 === 0 ? 200 : 300}
                    layers={3}
                    layerDepth={100}
                    layerOffset={4}
                    className="h-full rounded-3xl bg-boteco-beige-100/80 p-6 text-left dark:bg-boteco-brown-900/50"
                  >
                    <div className="flex h-full flex-col gap-3">
                      <h3 className="text-xl font-semibold text-boteco-brown-900 dark:text-boteco-beige-50">{card.title}</h3>
                      <p className="text-sm leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/80">{card.description}</p>
                    </div>
                  </DepthStack>
                )}
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;