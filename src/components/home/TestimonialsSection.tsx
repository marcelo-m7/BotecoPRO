"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";
import { useTranslation } from "react-i18next";

import TestimonialsBento from "./TestimonialsCarousel";

type Testimonial = { text: string; author: string };

const TestimonialsSection: React.FC = () => {
  const { t } = useTranslation("home");
  const shouldReduceMotion = useReducedMotion();

  const testimonials = (t("testimonials.quotes", { returnObjects: true }) as Testimonial[] | undefined) ?? [];

  return (
    <section className="relative w-full overflow-hidden bg-boteco-beige-100/70 py-20 dark:bg-boteco-brown-900/80">
      <div className="pointer-events-none absolute inset-x-0 top-0 h-48 bg-gradient-to-b from-boteco-wine-500/15 via-transparent to-transparent dark:from-boteco-wine-600/20" aria-hidden />
      <div className="container relative mx-auto flex flex-col gap-12 px-4">
        <div className="mx-auto max-w-3xl text-center">
          <motion.h2
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="text-3xl font-semibold tracking-tight text-boteco-brown-900 md:text-4xl dark:text-boteco-beige-50"
          >
            {t("testimonials.title")}
          </motion.h2>
        </div>

        <TestimonialsBento testimonials={testimonials} />
      </div>
    </section>
  );
};

export default TestimonialsSection;