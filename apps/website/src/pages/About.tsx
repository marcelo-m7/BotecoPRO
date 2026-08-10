"use client";

import React from 'react';
import { useTranslation } from 'react-i18next';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Lightbulb, Users, ShieldCheck } from 'lucide-react';
import Seo from '@/components/Seo';
import { motion, Variants, Easing } from 'framer-motion'; // Importar motion e Variants

const About: React.FC = () => {
  const { t, i18n } = useTranslation('about');

  const values = t('values', { returnObjects: true }) as string[];

  const pageTitle = t('title');
  const pageDescription = t('mission');

  // Variantes para as seções
  const sectionVariants: Variants = {
    hidden: { opacity: 0, y: 50 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: "easeInOut" as Easing } },
  };

  // Variantes para os itens dentro das seções (cards, parágrafos)
  const itemVariants: Variants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease: "easeInOut" as Easing } },
  };

  return (
    <>
      <Seo
        title={pageTitle}
        description={pageDescription}
        ogTitle={pageTitle}
        ogDescription={pageDescription}
        locale={i18n.language}
      />
      <div className="container mx-auto px-4 py-12">
        <motion.h1
          initial="hidden"
          animate="visible"
          variants={itemVariants}
          className="text-4xl font-bold text-center mb-12 text-boteco-wine dark:text-boteco-mustard-300"
        >
          {t('title')}
        </motion.h1>

        <motion.section
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          variants={sectionVariants}
          className="mb-12 text-center max-w-3xl mx-auto"
        >
          <motion.p variants={itemVariants} className="text-xl text-boteco-brown/90 mb-4 dark:text-boteco-beige-200/90">
            {t('mission')}
          </motion.p>
          <motion.p variants={itemVariants} className="text-lg text-boteco-brown/80 dark:text-boteco-beige-300/80">
            {t('vision')}
          </motion.p>
        </motion.section>

        <motion.section
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          variants={sectionVariants}
          className="mb-12"
        >
          <motion.h2 variants={itemVariants} className="text-3xl font-bold text-center mb-8 text-boteco-brown dark:text-boteco-beige-200">
            {t('valuesTitle', { defaultValue: 'Nossos Valores' })}
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            <motion.div variants={itemVariants}>
              <Card className="text-center p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-boteco-beige dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60">
                <CardHeader>
                  <Lightbulb className="h-12 w-12 text-boteco-mustard mx-auto mb-4 dark:text-boteco-mustard-300" />
                  <CardTitle className="text-xl font-semibold text-boteco-wine dark:text-boteco-mustard-300">{values[0]}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-boteco-brown/80 dark:text-boteco-beige-300/80">{t('valueDescription1', { defaultValue: 'Celebramos a individualidade e a riqueza das diferentes perspectivas.' })}</p>
                </CardContent>
              </Card>
            </motion.div>
            <motion.div variants={itemVariants}>
              <Card className="text-center p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-boteco-beige dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60">
                <CardHeader>
                  <ShieldCheck className="h-12 w-12 text-boteco-mustard mx-auto mb-4 dark:text-boteco-mustard-300" />
                  <CardTitle className="text-xl font-semibold text-boteco-wine dark:text-boteco-mustard-300">{values[1]}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-boteco-brown/80 dark:text-boteco-beige-300/80">{t('valueDescription2', { defaultValue: 'Buscamos constantemente novas formas de superar desafios e inovar.' })}</p>
                </CardContent>
              </Card>
            </motion.div>
            <motion.div variants={itemVariants}>
              <Card className="text-center p-6 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-boteco-beige dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60">
                <CardHeader>
                  <Users className="h-12 w-12 text-boteco-mustard mx-auto mb-4 dark:text-boteco-mustard-300" />
                  <CardTitle className="text-xl font-semibold text-boteco-wine dark:text-boteco-mustard-300">{values[2]}</CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-boteco-brown/80 dark:text-boteco-beige-300/80">{t('valueDescription3', { defaultValue: 'Trabalhamos juntos, com honestidade, para alcançar nossos objetivos.' })}</p>
                </CardContent>
              </Card>
            </motion.div>
          </div>
        </motion.section>

        <motion.section
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.3 }}
          variants={sectionVariants}
          className="max-w-4xl mx-auto text-boteco-brown dark:text-boteco-beige-200"
        >
          <motion.h2 variants={itemVariants} className="text-3xl font-bold text-center mb-8 text-boteco-brown dark:text-boteco-beige-200">
            {t('storyTitle', { defaultValue: 'Nossa História' })}
          </motion.h2>
          <motion.p variants={itemVariants} className="text-lg leading-relaxed mb-6 dark:text-boteco-beige-300">
            {t('story')}
          </motion.p>
        </motion.section>
      </div>
    </>
  );
};

export default About;