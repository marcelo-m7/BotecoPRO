"use client";

import * as React from "react";
import { motion, useReducedMotion } from "framer-motion";

import { DepthSpotlight, DepthStack } from "@/components/design";

interface TestimonialsBentoProps {
  testimonials: { text: string; author: string }[];
}

const TestimonialsCarousel: React.FC<TestimonialsBentoProps> = ({ testimonials }) => {
  const shouldReduceMotion = useReducedMotion();

  const [highlight, ...rest] = testimonials;

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,340px)]">
      {highlight && (
        <motion.blockquote
          initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.4 }}
          transition={{ duration: 0.55, ease: "easeOut" }}
          className="h-full"
        >
          <DepthSpotlight
            depth={300}
            spotlightRadius="520px"
            spotlightOpacity={0.28}
            className="flex h-full flex-col justify-between rounded-3xl bg-gradient-to-br from-boteco-wine-500/85 via-boteco-wine-500/60 to-boteco-mustard-300/40 p-[1px]"
          >
            <div className="flex h-full flex-col justify-between rounded-3xl bg-boteco-beige-50/95 p-10 text-left dark:bg-boteco-brown-900/70">
              <p className="text-lg font-medium leading-relaxed text-boteco-brown-800/95 dark:text-boteco-beige-100/95">
                “{highlight.text}”
              </p>
              <footer className="mt-8 text-right text-sm font-semibold text-boteco-wine-600 dark:text-boteco-mustard-300">
                {highlight.author}
              </footer>
            </div>
          </DepthSpotlight>
        </motion.blockquote>
      )}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-1">
        {rest.map((testimonial, index) => (
          <motion.blockquote
            key={`${testimonial.author}-${index}`}
            initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 18 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.45, ease: "easeOut", delay: index * 0.05 }}
            className="h-full"
          >
            <DepthStack
              depth={200}
              layers={3}
              layerDepth={100}
              layerOffset={3}
              className="flex h-full flex-col justify-between rounded-3xl bg-boteco-beige-100/90 p-6 text-left dark:bg-boteco-brown-900/60"
            >
              <p className="text-sm leading-relaxed text-boteco-brown-700 dark:text-boteco-beige-200/85">“{testimonial.text}”</p>
              <footer className="mt-6 text-right text-xs font-semibold uppercase tracking-wide text-boteco-wine-600 dark:text-boteco-mustard-300">
                {testimonial.author}
              </footer>
            </DepthStack>
          </motion.blockquote>
        ))}
      </div>
    </div>
  );
};

export default TestimonialsCarousel;