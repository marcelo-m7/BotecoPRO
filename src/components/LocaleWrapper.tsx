import React, { useEffect } from 'react';
import { useParams, Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Layout from './Layout';

const supportedLocales = ['pt', 'en', 'es', 'fr'];
const defaultLocale = 'pt';

const LocaleWrapper: React.FC = () => {
  const { locale } = useParams<{ locale: string }>();
  const { i18n } = useTranslation();

  useEffect(() => {
    const currentLocale = locale && supportedLocales.includes(locale) ? locale : defaultLocale;
    if (i18n.language !== currentLocale) {
      i18n.changeLanguage(currentLocale);
    }
  }, [locale, i18n]);

  return (
    <Layout>
      <Outlet />
    </Layout>
  );
};

export default LocaleWrapper;