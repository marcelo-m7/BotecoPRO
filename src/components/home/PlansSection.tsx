"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { Crown } from "lucide-react";
import { useTranslation } from "react-i18next";
import { Link, useParams } from "react-router-dom";

import { DepthSpotlight, DepthStack } from "@/components/design";
import { Button } from "@/components/ui/button";

type Plan = { name: string; price: string; features: string[] };

const PlansSection: React.FC = () => {
  const { t } = useTranslation("home");
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || "pt";
  const shouldReduceMotion = useReducedMotion();

  const plans = (t("plans.options", { returnObjects: true }) as Plan[] | undefined) ?? [];
  const highlightedPlanIndex = plans.length > 1 ? 1 : 0;

  const getLocalizedPath = React.useCallback((path: string) => `/${currentLocale}${path}` as const, [currentLocale]);

  return (
    <section className="relative w-full overflow-hidden bg-boteco-beige-50 py-20 dark:bg-boteco-brown-950/80">
      <div className="container relative mx-auto flex flex-col gap-12 px-4">
        <div className="mx-auto max-w-3xl text-center">
          <motion.h2
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="text-3xl font-semibold tracking-tight text-boteco-brown-900 md:text-4xl dark:text-boteco-beige-50"
          >
            {t("plans.title")}
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 12 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut", delay: 0.1 }}
            className="mt-4 text-lg text-boteco-brown-700 dark:text-boteco-beige-200/90"
          >
            {t("plans.description")}
          </motion.p>
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          {plans.map((plan, index) => {
            const isHighlighted = index === highlightedPlanIndex;

            if (isHighlighted) {
              return (
                <motion.div
                  key={`${plan.name}-${index}`}
                  initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 24 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true, amount: 0.3 }}
                  transition={{ duration: 0.55, ease: "easeOut", delay: index * 0.05 }}
                  className="h-full"
                >
                  <DepthSpotlight
                    depth={300}
                    spotlightRadius="560px"
                    spotlightOpacity={0.28}
                    className="h-full rounded-3xl bg-gradient-to-br from-boteco-wine-500/85 via-boteco-wine-500/65 to-boteco-mustard-300/45 p-[1px]"
                  >
                    <div className="flex h-full flex-col justify-between rounded-3xl bg-boteco-beige-50/95 p-10 text-left shadow-lg dark:bg-boteco-brown-900/70">
                      <div className="space-y-4">
                        <span className="inline-flex items-center gap-2 rounded-full bg-boteco-wine-500/10 px-4 py-1 text-xs font-semibold uppercase tracking-wide text-boteco-wine-700 dark:text-boteco-mustard-300">
                          <Crown className="h-4 w-4" aria-hidden />
                          {t("plans.popular")}
                        </span>
                        <h3 className="text-3xl font-semibold text-boteco-brown-900 dark:text-boteco-beige-50">{plan.name}</h3>
                        <p className="text-2xl font-semibold text-boteco-wine-600 dark:text-boteco-mustard-300">{plan.price}</p>
                        <p className="text-base leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/80">
                          {t("hero.subtitle")}
                        </p>
                      </div>
                      <ul className="mt-6 space-y-3 text-sm text-boteco-brown-700 dark:text-boteco-beige-200/80">
                        {plan.features.map((feature, featureIndex) => (
                          <li key={`${feature}-${featureIndex}`} className="flex items-start gap-2">
                            <span aria-hidden className="mt-1 inline-block h-2 w-2 rounded-full bg-boteco-mustard-400" />
                            <span>{feature}</span>
                          </li>
                        ))}
                      </ul>
                      <Button asChild size="lg" className="mt-8 w-full bg-boteco-wine-500 text-boteco-wine-foreground hover:bg-boteco-wine-500/90 focus-visible:ring-boteco-mustard-300">
                        <Link to={getLocalizedPath("/contato")}>
                          {t("plans.choosePlan", { defaultValue: "Escolher Plano" })}
                        </Link>
                      </Button>
                    </div>
                  </DepthSpotlight>
                </motion.div>
              );
            }

            return (
              <motion.div
                key={`${plan.name}-${index}`}
                initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 18 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, amount: 0.3 }}
                transition={{ duration: 0.5, ease: "easeOut", delay: index * 0.05 }}
                className="h-full"
              >
                <DepthStack
                  depth={200}
                  layers={3}
                  layerDepth={100}
                  layerOffset={4}
                  className="flex h-full flex-col justify-between rounded-3xl bg-boteco-beige-100/90 p-8 text-left dark:bg-boteco-brown-900/60"
                >
                  <div className="space-y-3">
                    <h3 className="text-2xl font-semibold text-boteco-brown-900 dark:text-boteco-beige-50">{plan.name}</h3>
                    <p className="text-xl font-semibold text-boteco-wine-600 dark:text-boteco-mustard-300">{plan.price}</p>
                  </div>
                  <ul className="mt-4 flex-1 space-y-2 text-sm text-boteco-brown-700 dark:text-boteco-beige-200/80">
                    {plan.features.map((feature, featureIndex) => (
                      <li key={`${feature}-${featureIndex}`} className="flex items-start gap-2">
                        <span aria-hidden className="mt-1 inline-block h-2 w-2 rounded-full bg-boteco-wine-400" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>
                  <Button asChild variant="outline" className="mt-8 w-full border-boteco-brown-200 bg-boteco-beige-50 text-boteco-brown-800 hover:bg-boteco-beige-100 dark:border-boteco-brown-700 dark:bg-boteco-brown-900/40 dark:text-boteco-beige-100">
                    <Link to={getLocalizedPath("/contato")}>
                      {t("plans.choosePlan", { defaultValue: "Escolher Plano" })}
                    </Link>
                  </Button>
                </DepthStack>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default PlansSection;