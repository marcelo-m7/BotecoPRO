import React from 'react';
import { useTranslation } from 'react-i18next';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useUser } from '@clerk/clerk-react';
import { Package, Utensils, DollarSign, AlertTriangle } from 'lucide-react';
import Seo from '@/components/Seo'; // Importar o componente Seo

const Painel: React.FC = () => {
  const { t, i18n } = useTranslation('painel');
  const { user } = useUser();

  const userName = user?.firstName || t('guest', { defaultValue: 'Usuário' });
  const cards = t('cards', { returnObjects: true }) as { title: string; value: string; description: string }[];

  const getIcon = (title: string) => {
    switch (title) {
      case t('cards.0.title'): // Pedidos Recentes
        return <Package className="h-8 w-8 text-boteco-mustard dark:text-boteco-mustard-300" />;
      case t('cards.1.title'): // Mesas Abertas
        return <Utensils className="h-8 w-8 text-boteco-mustard dark:text-boteco-mustard-300" />;
      case t('cards.2.title'): // Estoque Baixo
        return <AlertTriangle className="h-8 w-8 text-boteco-mustard dark:text-boteco-mustard-300" />;
      case t('cards.3.title'): // Vendas Hoje
        return <DollarSign className="h-8 w-8 text-boteco-mustard dark:text-boteco-mustard-300" />;
      default:
        return null;
    }
  };

  const pageTitle = t('title');
  const pageDescription = t('demoNotice');

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
        <h1 className="text-4xl font-bold mb-4 text-boteco-wine dark:text-boteco-mustard-300">
          {t('greeting', { userName })}
        </h1>
        <p className="text-xl text-boteco-brown/90 mb-8 dark:text-boteco-beige-200/90">
          {t('title')}
        </p>
        <p className="text-sm text-boteco-brown/80 mb-12 italic dark:text-boteco-beige-300/80">
          {t('demoNotice')}
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {cards.map((card, index) => (
            <Card key={index} className="shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-boteco-beige dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg font-medium text-boteco-brown dark:text-boteco-beige-100">
                  {card.title}
                </CardTitle>
                {getIcon(card.title)}
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold text-boteco-wine dark:text-boteco-mustard-300">{card.value}</div>
                <p className="text-xs text-boteco-brown/80 dark:text-boteco-beige-300/80">
                  {card.description}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </>
  );
};

export default Painel;