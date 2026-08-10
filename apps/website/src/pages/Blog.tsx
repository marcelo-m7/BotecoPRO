import React from 'react';
import { useTranslation } from 'react-i18next';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { CalendarDays } from 'lucide-react';
import Seo from '@/components/Seo'; // Importar o componente Seo
import { Link, useParams } from 'react-router-dom'; // Importar Link e useParams

const Blog: React.FC = () => {
  const { t, i18n } = useTranslation('blog');
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || 'pt';

  const posts = t('posts', { returnObjects: true }) as { id: string; title: string; excerpt: string; date: string }[];

  const pageTitle = t('title');
  const pageDescription = t('description');

  // Função para gerar o slug a partir do título
  const generateSlug = (title: string) => {
    return title
      .toLowerCase()
      .replace(/[^a-z0-9 -]/g, '') // Remove caracteres especiais
      .replace(/\s+/g, '-') // Substitui espaços por hífens
      .replace(/-+/g, '-'); // Remove hífens duplicados
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
        <h1 className="text-4xl font-bold text-center mb-6 text-boteco-wine dark:text-boteco-mustard-300">
          {t('title')}
        </h1>
        <p className="text-xl text-center mb-12 text-boteco-brown/90 dark:text-boteco-beige-200/90">
          {t('description')}
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {posts.map((post) => (
            <Card key={post.id} className="shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-boteco-beige dark:border-boteco-brown-700 dark:bg-boteco-brown-800/60">
              <CardHeader>
                <CardTitle className="text-2xl font-semibold text-boteco-brown dark:text-boteco-beige-100">
                  {post.title}
                </CardTitle>
                <CardDescription className="flex items-center text-boteco-brown/80 dark:text-boteco-beige-300/80">
                  <CalendarDays className="mr-2 h-4 w-4" />
                  {post.date}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <p className="text-boteco-brown/90 dark:text-boteco-beige-300">
                  {post.excerpt}
                </p>
                <Link to={`/${currentLocale}/blog/${generateSlug(post.title)}`} className="text-boteco-mustard hover:underline mt-4 inline-block dark:text-boteco-mustard-300">
                  {t('readMore', { defaultValue: 'Leia Mais' })}
                </Link>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </>
  );
};

export default Blog;