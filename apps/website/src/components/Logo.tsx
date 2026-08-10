"use client";

import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

// Make Logo a forwardRef component to properly handle `asChild`
const Logo = React.forwardRef<HTMLAnchorElement, React.ComponentPropsWithoutRef<typeof Link>>(
  ({ className, ...props }, ref) => {
    const { locale } = useParams<{ locale: string }>();
    const currentLocale = locale || 'pt';
    const getLocalizedPath = (path: string) => `/${currentLocale}${path}`;

    return (
      <Link
        ref={ref} // Forward the ref
        to={getLocalizedPath('/')}
        className="text-2xl font-bold text-boteco-wine-foreground hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300"
        {...props} // Spread additional props
      >
        Boteco Pro
      </Link>
    );
  }
);

Logo.displayName = "Logo"; // Add display name for better debugging

export default Logo;