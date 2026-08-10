import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Importar todos os arquivos de conteúdo para cada idioma
import ptHome from './content/pt/home.json';
import ptAbout from './content/pt/about.json';
import ptContact from './content/pt/contact.json';
import ptBlog from './content/pt/blog.json';
import ptPrivacy from './content/pt/legal/privacy.json';
import ptTerms from './content/pt/legal/terms.json';
import ptPainel from './content/pt/painel.json';
import ptBlogPost1 from './content/pt/blog-posts/5-dicas-para-otimizar-seu-atendimento.json'; // Novo

import enHome from './content/en/home.json';
import enAbout from './content/en/about.json';
import enContact from './content/en/contact.json';
import enBlog from './content/en/blog.json';
import enPrivacy from './content/en/legal/privacy.json';
import enTerms from './content/en/legal/terms.json';
import enPainel from './content/en/painel.json';
import enBlogPost1 from './content/en/blog-posts/5-tips-to-optimize-your-service.json'; // Novo

import esHome from './content/es/home.json';
import esAbout from './content/es/about.json';
import esContact from './content/es/contact.json';
import esBlog from './content/es/blog.json';
import esPrivacy from './content/es/legal/privacy.json';
import esTerms from './content/es/legal/terms.json';
import esPainel from './content/es/painel.json';
import esBlogPost1 from './content/es/blog-posts/5-consejos-para-optimizar-tu-servicio.json'; // Novo

import frHome from './content/fr/home.json';
import frAbout from './content/fr/about.json';
import frContact from './content/fr/contact.json';
import frBlog from './content/fr/blog.json';
import frPrivacy from './content/fr/legal/privacy.json';
import frTerms from './content/fr/legal/terms.json';
import frPainel from './content/fr/painel.json';
import frBlogPost1 from './content/fr/blog-posts/5-astuces-pour-optimiser-votre-service.json'; // Novo

const resources = {
  pt: {
    home: ptHome,
    about: ptAbout,
    contact: ptContact,
    blog: ptBlog,
    privacy: ptPrivacy,
    terms: ptTerms,
    painel: ptPainel,
    "blog-posts": {
      "5-dicas-para-otimizar-seu-atendimento": ptBlogPost1,
    },
  },
  en: {
    home: enHome,
    about: enAbout,
    contact: enContact,
    blog: enBlog,
    privacy: enPrivacy,
    terms: enTerms,
    painel: enPainel,
    "blog-posts": {
      "5-tips-to-optimize-your-service": enBlogPost1,
    },
  },
  es: {
    home: esHome,
    about: esAbout,
    contact: esContact,
    blog: esBlog,
    privacy: esPrivacy,
    terms: esTerms,
    painel: esPainel,
    "blog-posts": {
      "5-consejos-para-optimizar-tu-servicio": esBlogPost1,
    },
  },
  fr: {
    home: frHome,
    about: frAbout,
    contact: frContact,
    blog: frBlog,
    privacy: frPrivacy,
    terms: frTerms,
    painel: frPainel,
    "blog-posts": {
      "5-astuces-pour-optimiser-votre-service": frBlogPost1,
    },
  },
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'pt',
    debug: true,
    interpolation: {
      escapeValue: false, // react already safes from xss
    },
    ns: ['home', 'about', 'contact', 'blog', 'privacy', 'terms', 'painel', 'blog-posts'], // Adicionar 'blog-posts'
    defaultNS: 'home',
    detection: {
      order: ['path', 'localStorage', 'navigator'],
      lookupFromPathIndex: 0, // Look for locale in the first path segment
    },
  });

export default i18n;