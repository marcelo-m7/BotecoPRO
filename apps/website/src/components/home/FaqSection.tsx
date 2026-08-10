"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { useTranslation } from "react-i18next";

import { DepthSpotlight, DepthStack } from "@/components/design";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

type FaqItem = { question: string; answer: string };

const FaqSection: React.FC = () => {
  const { t } = useTranslation("home");
  const shouldReduceMotion = useReducedMotion();

  const faqItems = (t("faq.items", { returnObjects: true }) as FaqItem[] | undefined) ?? [];

  return (
    <section className="relative w-full overflow-hidden bg-boteco-beige-50/90 py-20 dark:bg-boteco-brown-950/80">
      <div className="container relative mx-auto flex flex-col gap-12 px-4">
        <div className="mx-auto max-w-3xl text-center">
          <motion.h2
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="text-3xl font-semibold tracking-tight text-boteco-brown-900 md:text-4xl dark:text-boteco-beige-50"
          >
            {t("faq.title")}
          </motion.h2>
        </div>

        <DepthSpotlight
          depth={200}
          spotlightRadius="520px"
          spotlightOpacity={0.22}
          className="mx-auto w-full max-w-3xl rounded-3xl bg-boteco-beige-50/90 p-2 dark:bg-boteco-brown-900/70"
        >
          <Accordion
            type="single"
            collapsible
            className="rounded-[inherit] bg-boteco-beige-100/80 p-2 text-left dark:bg-boteco-brown-900/40"
          >
            {faqItems.map((item, index) => (
              <DepthStack
                key={`${item.question}-${index}`}
                depth={100}
                layers={2}
                layerDepth={100}
                layerOffset={2}
                className="mb-3 rounded-2xl bg-boteco-beige-50/90 text-left last:mb-0 dark:bg-boteco-brown-900/60"
              >
                <AccordionItem value={`faq-${index}`} className="border-0">
                  <AccordionTrigger className="px-5 py-4 text-base font-semibold text-boteco-brown-900 hover:no-underline focus:outline-none focus-visible:ring-0 dark:text-boteco-beige-100">
                    {item.question}
                  </AccordionTrigger>
                  <AccordionContent className="px-5 pb-5 text-sm leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/80">
                    {item.answer}
                  </AccordionContent>
                </AccordionItem>
              </DepthStack>
            ))}
          </Accordion>
        </DepthSpotlight>
      </div>
    </section>
  );
};

export default FaqSection;