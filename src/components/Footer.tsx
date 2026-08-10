import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { MadeWithDyad } from './made-with-dyad';

const Footer: React.FC = () => {
  const { t } = useTranslation();
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || 'pt';

  const getLocalizedPath = (path: string) => `/${currentLocale}${path}`;

  return (
    <footer className="bg-boteco-wine text-boteco-wine-foreground p-4 shadow-inner mt-8 dark:bg-boteco-wine-800">
      <div className="container mx-auto flex flex-col md:flex-row justify-between items-center text-sm">
        <div className="flex space-x-4 mb-2 md:mb-0">
          <Link to={getLocalizedPath('/legal/privacidade')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
            {t('privacy:title', { ns: 'privacy' })}
          </Link>
          <Link to={getLocalizedPath('/legal/termos')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
            {t('terms:title', { ns: 'terms' })}
          </Link>
        </div>
        <p className="text-center md:text-right mb-2 md:mb-0">
          &copy; {new Date().getFullYear()} Monynha Softwares. Todos os direitos reservados.
        </p>
        <MadeWithDyad />
      </div>
    </footer>
  );
};

export default Footer;