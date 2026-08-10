"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { Link, useParams } from "react-router-dom";

import { DepthSpotlight } from "@/components/design";
import { Button } from "@/components/ui/button";

const FinalCtaSection: React.FC = () => {
  const { t } = useTranslation("home");
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || "pt";
  const shouldReduceMotion = useReducedMotion();

  const getLocalizedPath = React.useCallback((path: string) => `/${currentLocale}${path}` as const, [currentLocale]);

  return (
    <section className="relative w-full overflow-hidden bg-gradient-to-br from-boteco-wine-600 via-boteco-wine-500 to-boteco-mustard-500/50 py-24 text-boteco-wine-foreground">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_hsla(var(--boteco-mustard-300)/0.28),_transparent_65%)] opacity-80 mix-blend-screen" aria-hidden />
      <div className="container relative mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.4 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
        >
          <DepthSpotlight
            depth={300}
            spotlightRadius="640px"
            spotlightOpacity={0.32}
            className="mx-auto max-w-4xl rounded-[2.5rem] bg-boteco-beige-50/95 px-10 py-14 text-center text-boteco-brown-900 shadow-2xl dark:bg-boteco-brown-900/80 dark:text-boteco-beige-50"
          >
            <div className="space-y-6">
              <h2 className="text-3xl font-semibold leading-tight tracking-tight md:text-4xl">
                {t("finalCta.title")}
              </h2>
              <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
                <Button
                  asChild
                  size="lg"
                  className="w-full max-w-xs bg-boteco-wine-500 text-boteco-wine-foreground hover:bg-boteco-wine-500/90 focus-visible:ring-boteco-mustard-300 sm:w-auto"
                >
                  <Link to={getLocalizedPath("/contato")}>
                    {t("finalCta.button")}
                  </Link>
                </Button>
                <Button
                  asChild
                  variant="outline"
                  size="lg"
                  className="w-full max-w-xs border-boteco-brown-200 bg-boteco-beige-50 text-boteco-brown-800 hover:bg-boteco-beige-100 dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60 dark:text-boteco-beige-100 sm:w-auto"
                >
                  <Link to={getLocalizedPath("/sobre")}>
                    {t("finalCta.aboutButton")}
                  </Link>
                </Button>
              </div>
            </div>
          </DepthSpotlight>
        </motion.div>
      </div>
    </section>
  );
};

export default FinalCtaSection;