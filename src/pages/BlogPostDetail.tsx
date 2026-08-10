import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Seo from '@/components/Seo';
import { Button } from '@/components/ui/button';
import { ArrowLeft } from 'lucide-react';

interface ContentBlock {
  type: 'paragraph' | 'heading';
  text: string;
}

interface BlogPost {
  title: string;
  date: string;
  author: string;
  image: string;
  content: ContentBlock[];
}

const BlogPostDetail: React.FC = () => {
  const { locale, slug } = useParams<{ locale: string; slug: string }>();
  const { t, i18n } = useTranslation('blog-posts');

  const post: BlogPost | undefined = t(slug || '', { returnObjects: true }) as BlogPost;

  if (!post) {
    // Handle case where post is not found
    return (
      <div className="container mx-auto px-4 py-12 text-center">
        <h1 className="text-4xl font-bold text-boteco-wine mb-4 dark:text-boteco-mustard-300">
          {t('notFoundTitle', { defaultValue: 'Post não encontrado' })}
        </h1>
        <p className="text-lg text-boteco-brown/80 mb-8 dark:text-boteco-beige-300/80">
          {t('notFoundMessage', { defaultValue: 'O post que você está procurando não existe.' })}
        </p>
        <Link to={`/${locale}/blog`}>
          <Button className="bg-boteco-mustard text-boteco-mustard-foreground hover:bg-boteco-mustard/90 active:scale-98 transition-transform duration-100 dark:bg-boteco-mustard-400 dark:text-boteco-brown-900 dark:hover:bg-boteco-mustard-300">
            <ArrowLeft className="mr-2 h-4 w-4" />
            {t('backToBlog', { defaultValue: 'Voltar para o Blog' })}
          </Button>
        </Link>
      </div>
    );
  }

  const pageTitle = post.title;
  const pageDescription = post.content[0]?.text || post.title;

  return (
    <>
      <Seo
        title={pageTitle}
        description={pageDescription}
        ogTitle={pageTitle}
        ogDescription={pageDescription}
        ogImage={post.image}
        locale={i18n.language}
      />
      <div className="container mx-auto px-4 py-12 max-w-4xl">
        <Link to={`/${locale}/blog`} className="inline-flex items-center text-boteco-mustard hover:underline mb-8 dark:text-boteco-mustard-300">
          <ArrowLeft className="mr-2 h-4 w-4" />
          {t('backToBlog', { defaultValue: 'Voltar para o Blog' })}
        </Link>

        <h1 className="text-4xl md:text-5xl font-bold text-boteco-wine mb-6 dark:text-boteco-mustard-300">
          {post.title}
        </h1>
        <p className="text-sm text-boteco-brown/80 mb-2 dark:text-boteco-beige-300/80">
          {t('publishedBy', { defaultValue: 'Publicado por' })} {post.author} em {post.date}
        </p>
        {post.image && (
          <img
            src={post.image}
            alt={post.title}
            className="w-full h-64 object-cover rounded-lg mb-8 shadow-md"
          />
        )}

        <div className="prose prose-lg max-w-none text-boteco-brown dark:text-boteco-beige-200">
          {post.content.map((block, index) => (
            block.type === 'paragraph' ? (
              <p key={index} className="mb-4 leading-relaxed dark:text-boteco-beige-300">
                {block.text}
              </p>
            ) : (
              <h2 key={index} className="text-2xl font-semibold mt-8 mb-4 text-boteco-brown dark:text-boteco-beige-100">
                {block.text}
              </h2>
            )
          ))}
        </div>
      </div>
    </>
  );
};

export default BlogPostDetail;