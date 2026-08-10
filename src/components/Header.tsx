import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import LanguageSwitcher from './LanguageSwitcher';
import { Button } from '@/components/ui/button';
import { SignedIn, UserButton } from '@clerk/clerk-react';
import { ThemeToggle } from './ThemeToggle';
import MobileNav from './MobileNav';
import { useIsMobile } from '@/hooks/use-mobile';
import Logo from './Logo'; // Import the new Logo component

const Header: React.FC = () => {
  const { t } = useTranslation();
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || 'pt';
  const isMobile = useIsMobile();
  const [isMobileNavOpen, setIsMobileNavOpen] = React.useState(false);

  const getLocalizedPath = (path: string) => `/${currentLocale}${path}`;

  return (
    <header className="sticky top-0 z-50 bg-boteco-wine text-boteco-wine-foreground p-4 shadow-md">
      <div className="container mx-auto flex justify-between items-center">
        <Logo /> {/* Use the Logo component here */}
        
        {isMobile ? (
          <div className="flex items-center space-x-2">
            <ThemeToggle />
            <SignedIn>
              <UserButton afterSignOutUrl="/" />
            </SignedIn>
            <MobileNav isOpen={isMobileNavOpen} onOpenChange={setIsMobileNavOpen} />
          </div>
        ) : (
          <nav className="flex items-center space-x-4">
            <Link to={getLocalizedPath('/')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
              {t('home:hero.title', { ns: 'home' }).split(':')[0]}
            </Link>
            <Link to={getLocalizedPath('/sobre')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
              {t('about:title', { ns: 'about' })}
            </Link>
            <Link to={getLocalizedPath('/contato')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
              {t('contact:title', { ns: 'contact' })}
            </Link>
            <Link to={getLocalizedPath('/blog')} className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
              {t('blog:title', { ns: 'blog' })}
            </Link>
            <Link to="/painel" className="hover:underline hover:text-boteco-mustard transition-colors dark:hover:text-boteco-mustard-300">
              {t('painel:title', { ns: 'painel' })}
            </Link>
            <a href="https://app.boteco.pt" target="_blank" rel="noopener noreferrer">
              <Button variant="outline" className="bg-boteco-mustard text-boteco-mustard-foreground hover:bg-boteco-mustard/90 active:scale-98 transition-transform duration-100 border-boteco-beige dark:bg-boteco-mustard-400 dark:text-boteco-brown-900 dark:hover:bg-boteco-mustard-300 dark:border-boteco-wine-400">
                {t('home:hero.demoButton', { ns: 'home' })}
              </Button>
            </a>
            <LanguageSwitcher />
            <ThemeToggle />
            <SignedIn>
              <UserButton afterSignOutUrl="/" />
            </SignedIn>
          </nav>
        )}
      </div>
    </header>
  );
};

export default Header;