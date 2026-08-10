"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { useTranslation } from "react-i18next";

import { DepthSpotlight } from "@/components/design";

type Step = { title: string; description: string };

const HowItWorksSection: React.FC = () => {
  const { t } = useTranslation("home");
  const shouldReduceMotion = useReducedMotion();

  const steps = (t("howItWorks.steps", { returnObjects: true }) as Step[] | undefined) ?? [];

  return (
    <section className="relative w-full overflow-hidden bg-boteco-beige-100/80 py-20 dark:bg-boteco-brown-900/80">
      <div className="container relative mx-auto flex flex-col gap-12 px-4">
        <div className="mx-auto max-w-3xl text-center">
          <motion.h2
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.5 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="text-3xl font-semibold tracking-tight text-boteco-brown-900 md:text-4xl dark:text-boteco-beige-50"
          >
            {t("howItWorks.title")}
          </motion.h2>
        </div>

        <ol className="grid gap-6 md:grid-cols-3" aria-label={t("howItWorks.title")}>
          {steps.map((step, index) => (
            <motion.li
              key={`${step.title}-${index}`}
              initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.4 }}
              transition={{ duration: 0.45, ease: "easeOut", delay: index * 0.08 }}
              className="h-full"
            >
              <DepthSpotlight
                depth={200}
                spotlightRadius="420px"
                spotlightOpacity={0.24}
                className="h-full rounded-3xl bg-boteco-beige-50/90 p-6 text-left dark:bg-boteco-brown-900/70"
              >
                <div className="flex h-full flex-col gap-4">
                  <span className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-boteco-mustard-400 text-base font-semibold text-boteco-brown-900 shadow-sm dark:bg-boteco-mustard-400/90">
                    {index + 1}
                  </span>
                  <h3 className="text-xl font-semibold text-boteco-brown-900 dark:text-boteco-beige-50">{step.title}</h3>
                  <p className="text-sm leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/80">{step.description}</p>
                </div>
              </DepthSpotlight>
            </motion.li>
          ))}
        </ol>
      </div>
    </section>
  );
};

export default HowItWorksSection;