"use client";

import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Menu } from 'lucide-react';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from '@/components/ui/button';
import LanguageSwitcher from './LanguageSwitcher';
import { ThemeToggle } from './ThemeToggle';
import { SignedIn, UserButton } from '@clerk/clerk-react';
import Logo from './Logo'; // Import the new Logo component

interface MobileNavProps {
  onOpenChange: (open: boolean) => void;
  isOpen: boolean;
}

const MobileNav: React.FC<MobileNavProps> = ({ onOpenChange, isOpen }) => {
  const { t } = useTranslation();
  const { locale } = useParams<{ locale: string }>();
  const currentLocale = locale || 'pt';

  const getLocalizedPath = (path: string) => `/${currentLocale}${path}`;

  return (
    <Sheet open={isOpen} onOpenChange={onOpenChange}>
      <SheetTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          className="lg:hidden text-boteco-wine-foreground hover:bg-boteco-wine/80 active:scale-98 dark:hover:bg-boteco-wine-700/80"
        >
          <Menu className="h-6 w-6" />
          <span className="sr-only">{t('openMenu', { defaultValue: 'Abrir menu' })}</span>
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-[250px] sm:w-[300px] bg-background flex flex-col dark:bg-boteco-brown-900">
        <SheetHeader className="mb-6">
          <SheetTitle asChild> {/* Use asChild to pass props to Logo */}
            <Logo />
          </SheetTitle>
        </SheetHeader>
        <nav className="flex flex-col space-y-4 flex-grow">
          <Link
            to={getLocalizedPath('/')}
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('home:hero.title', { ns: 'home' }).split(':')[0]}
          </Link>
          <Link
            to={getLocalizedPath('/sobre')}
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('about:title', { ns: 'about' })}
          </Link>
          <Link
            to={getLocalizedPath('/contato')}
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('contact:title', { ns: 'contact' })}
          </Link>
          <Link
            to={getLocalizedPath('/blog')}
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('blog:title', { ns: 'blog' })}
          </Link>
          <Link
            to="/painel"
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('painel:title', { ns: 'painel' })}
          </Link>
          <a
            href="https://app.boteco.pt"
            target="_blank"
            rel="noopener noreferrer"
            className="text-lg font-medium text-foreground hover:text-boteco-wine transition-colors dark:hover:text-boteco-mustard-300"
            onClick={() => onOpenChange(false)}
          >
            {t('home:hero.demoButton', { ns: 'home' })}
          </a>
        </nav>
        <div className="flex flex-col space-y-4 mt-auto pb-4">
          <LanguageSwitcher />
          <ThemeToggle />
          <SignedIn>
            <div className="flex items-center justify-start">
              <UserButton afterSignOutUrl="/" />
              <span className="ml-2 text-foreground">{t('profile', { defaultValue: 'Perfil' })}</span>
            </div>
          </SignedIn>
        </div>
      </SheetContent>
    </Sheet>
  );
};

export default MobileNav;