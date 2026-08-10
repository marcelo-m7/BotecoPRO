import React from 'react';
import { Helmet } from 'react-helmet-async';

interface SeoProps {
  title: string;
  description: string;
  ogTitle?: string;
  ogDescription?: string;
  ogUrl?: string;
  ogImage?: string;
  locale?: string;
}

const Seo: React.FC<SeoProps> = ({
  title,
  description,
  ogTitle,
  ogDescription,
  ogUrl,
  ogImage = '/og-image.jpg', // Default Open Graph image
  locale = 'pt_BR',
}) => {
  return (
    <Helmet>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta property="og:title" content={ogTitle || title} />
      <meta property="og:description" content={ogDescription || description} />
      <meta property="og:url" content={ogUrl || window.location.href} />
      <meta property="og:image" content={ogImage} />
      <meta property="og:locale" content={locale} />
      <meta property="og:type" content="website" />
      <html lang={locale.split('_')[0]} /> {/* Set HTML lang attribute */}
    </Helmet>
  );
};

export default Seo;