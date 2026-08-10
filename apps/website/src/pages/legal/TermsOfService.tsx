import React from 'react';
import { useTranslation } from 'react-i18next';
import { DepthSurface } from '@/components/design';
import Seo from '@/components/Seo'; // Importar o componente Seo

const TermsOfService: React.FC = () => {
  const { t, i18n } = useTranslation('terms');

  const contentSections = t('content', { returnObjects: true }) as { heading: string; text: string }[];

  const pageTitle = t('title');
  const pageDescription = t('content.0.text'); // Usar a introdução como descrição

  return (
    <>
      <Seo
        title={pageTitle}
        description={pageDescription}
        ogTitle={pageTitle}
        ogDescription={pageDescription}
        locale={i18n.language}
      />
      <div className="container mx-auto px-4 py-12 max-w-4xl">
        <h1 className="text-4xl font-bold text-center mb-4 text-boteco-wine dark:text-boteco-mustard-300">
          {t('title')}
        </h1>
        <p className="text-center text-boteco-brown/80 mb-12 dark:text-boteco-beige-300/80">
          {t('lastUpdatedLabel', { defaultValue: 'Última atualização' })}: {t('lastUpdated')}
        </p>

        <div className="space-y-6 text-boteco-brown dark:text-boteco-beige-200">
          {contentSections.map((section, index) => (
            <DepthSurface
              asChild
              key={index}
              depth={100}
              className="p-6 text-left"
            >
              <section>
                <h2 className="text-2xl font-semibold mb-4 text-boteco-brown dark:text-boteco-beige-100">
                  {section.heading}
                </h2>
                <p className="text-lg leading-relaxed dark:text-boteco-beige-300">
                  {section.text}
                </p>
              </section>
            </DepthSurface>
          ))}
        </div>
      </div>
    </>
  );
};

export default TermsOfService;