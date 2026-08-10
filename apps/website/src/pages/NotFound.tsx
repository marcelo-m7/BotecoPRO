import { useLocation, Link, useParams } from "react-router-dom";
import { useEffect } from "react";
import { useTranslation } from "react-i18next";
import Seo from '@/components/Seo'; // Importar o componente Seo
import { Button } from '@/components/ui/button'; // Importar o componente Button

const NotFound = () => {
  const location = useLocation();
  const { locale } = useParams<{ locale: string }>();
  const { t, i18n } = useTranslation(['notFound', 'home']); // Usar namespace 'home' para o título da home
  const currentLocale = locale || 'pt';

  useEffect(() => {
    console.error(
      "404 Error: User attempted to access non-existent route:",
      location.pathname,
    );
  }, [location.pathname]);

  const pageTitle = t('notFound:title', { defaultValue: 'Página Não Encontrada' });
  const pageDescription = t('notFound:message', { defaultValue: 'A página que você está procurando não existe.' });

  return (
    <>
      <Seo
        title={pageTitle}
        description={pageDescription}
        ogTitle={pageTitle}
        ogDescription={pageDescription}
        locale={i18n.language}
      />
      <div className="min-h-[calc(100vh-150px)] flex flex-col items-center justify-center bg-background text-foreground p-4">
        <div className="text-center max-w-md">
          <h1 className="text-6xl md:text-8xl font-extrabold text-boteco-wine mb-4 dark:text-boteco-mustard-300">
            404
          </h1>
          <p className="text-2xl md:text-3xl font-semibold text-boteco-brown mb-4 dark:text-boteco-beige-100">
            {t('notFound:message', { defaultValue: 'Oops! Página não encontrada.' })}
          </p>
          <p className="text-lg text-boteco-brown/80 mb-8 dark:text-boteco-beige-300/80">
            {t('notFound:description', { defaultValue: 'Parece que a página que você tentou acessar não existe ou foi movida.' })}
          </p>
          <Link to={`/${currentLocale}`}>
            <Button className="bg-boteco-mustard text-boteco-mustard-foreground hover:bg-boteco-mustard/90 transition-colors duration-300 active:scale-98 dark:bg-boteco-mustard-400 dark:text-boteco-brown-900 dark:hover:bg-boteco-mustard-300">
              {t('notFound:returnHome', { defaultValue: 'Voltar para a Página Inicial' })}
            </Button>
          </Link>
        </div>
      </div>
    </>
  );
};

export default NotFound;